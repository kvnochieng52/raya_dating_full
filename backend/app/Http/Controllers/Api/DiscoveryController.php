<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Like;
use App\Models\MatchRecord;
use App\Models\Message;
use App\Models\Profile;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class DiscoveryController extends Controller
{
    /**
     * Minimum completed profile step required before a user shows up in
     * other users' discovery feeds (everything except verification).
     */
    private const MIN_DISCOVERY_STEP = 4;

    public function feed(Request $request): JsonResponse
    {
        $user = $request->user();
        // Auto-create an empty profile so users registered before the profile
        // hook existed (or via factory) can still browse.
        $profile = $user->profile()->firstOrCreate(['user_id' => $user->id]);

        $filters = $request->validate([
            'limit' => ['sometimes', 'integer', 'min:1', 'max:50'],
            'min_age' => ['sometimes', 'integer', 'min:18', 'max:120'],
            'max_age' => ['sometimes', 'integer', 'min:18', 'max:120', 'gte:min_age'],
            'show_me' => ['sometimes', Rule::in(['Men', 'Women', 'Everyone'])],
            'interests' => ['sometimes', 'array', 'max:50'],
            'interests.*' => ['string', 'max:50'],
            'verified_only' => ['sometimes', 'boolean'],
        ]);

        $limit = $filters['limit'] ?? 20;
        $minAge = $filters['min_age'] ?? $profile->age_min ?? 18;
        $maxAge = $filters['max_age'] ?? $profile->age_max ?? 99;
        $showMe = $filters['show_me'] ?? $profile->show_me ?? 'Everyone';
        $interestFilters = $filters['interests'] ?? null;
        $verifiedOnly = $request->boolean('verified_only');

        $cutoffMaxBirth = Carbon::today()->subYears($minAge);
        $cutoffMinBirth = Carbon::today()->subYears($maxAge + 1)->addDay();

        $alreadyDecidedIds = Like::where('user_id', $user->id)->pluck('target_user_id');

        $query = Profile::query()
            ->with(['photos', 'user:id,name,email'])
            ->where('user_id', '!=', $user->id)
            ->where('completed_step', '>=', self::MIN_DISCOVERY_STEP)
            ->whereNotNull('birth_date')
            ->whereBetween('birth_date', [$cutoffMinBirth, $cutoffMaxBirth])
            ->whereNotIn('user_id', $alreadyDecidedIds)
            // Only surface profiles with at least one photo — a card with
            // no photo isn't actionable for the viewer.
            ->whereHas('photos');

        if ($showMe === 'Men') {
            $query->where('gender', 'Man');
        } elseif ($showMe === 'Women') {
            $query->where('gender', 'Woman');
        }

        if ($verifiedOnly) {
            $query->where(function ($q) {
                $q->where('email_verified', true)
                  ->orWhere('phone_verified', true)
                  ->orWhereNotNull('selfie_path');
            });
        }

        if (! empty($interestFilters)) {
            // Match profiles that share at least one of the requested interests.
            // Uses MySQL 8 JSON_OVERLAPS — falls back to multiple JSON_CONTAINS
            // OR clauses on older engines.
            $query->where(function ($q) use ($interestFilters) {
                foreach ($interestFilters as $interest) {
                    $q->orWhereJsonContains('interests', $interest);
                }
            });
        }

        $candidates = $query->limit($limit * 3)->get();

        $results = $candidates->map(function (Profile $p) {
            $arr = $p->toArray();
            $arr['age'] = $p->birth_date ? $p->birth_date->age : null;
            return $arr;
        });

        return response()->json([
            'profiles' => $results->take($limit)->values(),
        ]);
    }

    public function swipe(Request $request): JsonResponse
    {
        $data = $request->validate([
            'target_user_id' => ['required', 'integer', 'exists:users,id'],
            'action' => ['required', Rule::in([Like::ACTION_LIKE, Like::ACTION_SUPER_LIKE, Like::ACTION_PASS])],
        ]);

        $user = $request->user();
        $profile = $user->profile()->firstOrCreate(['user_id' => $user->id]);
        if ($profile->completed_step < self::MIN_DISCOVERY_STEP) {
            return response()->json([
                'message' => 'Finish your profile to start matching.',
                'profile_incomplete' => true,
            ], 403);
        }

        if ((int) $data['target_user_id'] === (int) $user->id) {
            return response()->json([
                'message' => 'You cannot swipe on yourself.',
                'errors' => ['target_user_id' => ['You cannot swipe on yourself.']],
            ], 422);
        }

        $isMatch = false;
        $match = null;

        DB::transaction(function () use ($user, $data, &$isMatch, &$match) {
            $like = Like::updateOrCreate(
                ['user_id' => $user->id, 'target_user_id' => $data['target_user_id']],
                ['action' => $data['action']]
            );

            if (! $like->isPositive()) {
                return;
            }

            $reciprocal = Like::where('user_id', $data['target_user_id'])
                ->where('target_user_id', $user->id)
                ->whereIn('action', [Like::ACTION_LIKE, Like::ACTION_SUPER_LIKE])
                ->exists();

            if (! $reciprocal) {
                return;
            }

            [$low, $high] = MatchRecord::pairIds($user->id, (int) $data['target_user_id']);
            $match = MatchRecord::firstOrCreate(
                ['user_low_id' => $low, 'user_high_id' => $high],
                ['matched_at' => now()]
            );
            $isMatch = true;
        });

        return response()->json([
            'is_match' => $isMatch,
            'match' => $match ? $this->serializeMatch($match, $user) : null,
        ]);
    }

    public function sentLikes(Request $request): JsonResponse
    {
        $user = $request->user();
        $likes = Like::query()
            ->where('user_id', $user->id)
            ->whereIn('action', [Like::ACTION_LIKE, Like::ACTION_SUPER_LIKE])
            ->latest()
            ->get();

        $targetIds = $likes->pluck('target_user_id');
        $profiles = Profile::with(['photos', 'user:id,name,email'])
            ->whereIn('user_id', $targetIds)
            ->get()
            ->keyBy('user_id');

        $result = $likes->map(function (Like $like) use ($profiles) {
            $profile = $profiles->get($like->target_user_id);
            return [
                'liked_at' => $like->created_at,
                'action' => $like->action,
                'profile' => $profile,
            ];
        })->filter(fn ($row) => $row['profile'] !== null)->values();

        return response()->json(['likes' => $result]);
    }

    public function receivedLikes(Request $request): JsonResponse
    {
        $user = $request->user();
        $likes = Like::query()
            ->where('target_user_id', $user->id)
            ->whereIn('action', [Like::ACTION_LIKE, Like::ACTION_SUPER_LIKE])
            ->latest()
            ->get();

        $sourceIds = $likes->pluck('user_id');
        $profiles = Profile::with(['photos', 'user:id,name,email'])
            ->whereIn('user_id', $sourceIds)
            ->get()
            ->keyBy('user_id');

        $result = $likes->map(function (Like $like) use ($profiles) {
            $profile = $profiles->get($like->user_id);
            return [
                'liked_at' => $like->created_at,
                'action' => $like->action,
                'profile' => $profile,
            ];
        })->filter(fn ($row) => $row['profile'] !== null)->values();

        return response()->json(['likes' => $result]);
    }

    public function matches(Request $request): JsonResponse
    {
        $user = $request->user();

        $records = MatchRecord::query()
            ->where(function ($q) use ($user) {
                $q->where('user_low_id', $user->id)
                  ->orWhere('user_high_id', $user->id);
            })
            ->orderByDesc('matched_at')
            ->get();

        $partnerIds = $records->map(
            fn ($m) => $m->user_low_id === $user->id ? $m->user_high_id : $m->user_low_id
        );

        $profiles = Profile::with(['photos', 'user:id,name,email'])
            ->whereIn('user_id', $partnerIds)
            ->get()
            ->keyBy('user_id');

        // Latest message per match in one query.
        $matchIds = $records->pluck('id');
        $latestMessageIds = Message::whereIn('match_id', $matchIds)
            ->selectRaw('MAX(id) AS id, match_id')
            ->groupBy('match_id')
            ->pluck('id');
        $lastMessages = Message::whereIn('id', $latestMessageIds)
            ->get()
            ->keyBy('match_id');

        // Unread (sent by the partner, not yet read by me) count per match.
        $unreadCounts = Message::query()
            ->whereIn('match_id', $matchIds)
            ->where('sender_id', '!=', $user->id)
            ->whereNull('read_at')
            ->selectRaw('match_id, COUNT(*) AS c')
            ->groupBy('match_id')
            ->pluck('c', 'match_id');

        $result = $records->map(function (MatchRecord $m) use ($user, $profiles, $lastMessages, $unreadCounts) {
            $partnerId = $m->user_low_id === $user->id ? $m->user_high_id : $m->user_low_id;
            $lastMsg = $lastMessages->get($m->id);
            return [
                'id' => $m->id,
                'matched_at' => $m->matched_at,
                'profile' => $profiles->get($partnerId),
                'last_message' => $lastMsg ? [
                    'id' => $lastMsg->id,
                    'sender_id' => $lastMsg->sender_id,
                    'body' => $lastMsg->body,
                    'created_at' => $lastMsg->created_at,
                    'is_mine' => $lastMsg->sender_id === $user->id,
                ] : null,
                'last_activity_at' => $lastMsg ? $lastMsg->created_at : $m->matched_at,
                'unread_count' => (int) ($unreadCounts[$m->id] ?? 0),
            ];
        })->filter(fn ($row) => $row['profile'] !== null)
          // Reorder by activity so conversations bubble to the top.
          ->sortByDesc(fn ($row) => $row['last_activity_at'])
          ->values();

        return response()->json(['matches' => $result]);
    }

    private function serializeMatch(MatchRecord $match, User $viewer): array
    {
        $partnerId = $match->user_low_id === $viewer->id
            ? $match->user_high_id
            : $match->user_low_id;
        $partnerProfile = Profile::with(['photos', 'user:id,name,email'])
            ->where('user_id', $partnerId)
            ->first();

        return [
            'id' => $match->id,
            'matched_at' => $match->matched_at,
            'profile' => $partnerProfile,
        ];
    }
}
