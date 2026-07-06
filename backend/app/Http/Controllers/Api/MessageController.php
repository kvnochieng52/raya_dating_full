<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MatchRecord;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function index(Request $request, MatchRecord $match): JsonResponse
    {
        $this->authorizeAccess($request, $match);

        $data = $request->validate([
            'after_id' => ['sometimes', 'integer', 'min:0'],
            'limit' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $limit = $data['limit'] ?? 50;

        $query = Message::where('match_id', $match->id);
        if (! empty($data['after_id'])) {
            // "Tail" mode: poll for messages newer than the last one we have.
            $messages = $query
                ->where('id', '>', $data['after_id'])
                ->orderBy('id')
                ->limit($limit)
                ->get();
        } else {
            // Initial load: latest N, returned in chronological order.
            $messages = $query
                ->orderByDesc('id')
                ->limit($limit)
                ->get()
                ->reverse()
                ->values();
        }

        return response()->json(['messages' => $messages]);
    }

    public function store(Request $request, MatchRecord $match): JsonResponse
    {
        $this->authorizeAccess($request, $match);

        $user = $request->user();
        $profile = $user->profile()->firstOrCreate(['user_id' => $user->id]);
        if ($profile->completed_step < 4) {
            return response()->json([
                'message' => 'Finish your profile to start chatting.',
                'profile_incomplete' => true,
            ], 403);
        }

        $data = $request->validate([
            'body' => ['required', 'string', 'min:1', 'max:2000'],
        ]);

        $message = Message::create([
            'match_id' => $match->id,
            'sender_id' => $user->id,
            'body' => $data['body'],
        ]);

        return response()->json(['message' => $message], 201);
    }

    /**
     * Marks all messages in this thread sent by the OTHER party as read.
     */
    public function markRead(Request $request, MatchRecord $match): JsonResponse
    {
        $this->authorizeAccess($request, $match);
        $userId = (int) $request->user()->id;

        $updated = Message::where('match_id', $match->id)
            ->where('sender_id', '!=', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['marked_read' => $updated]);
    }

    private function authorizeAccess(Request $request, MatchRecord $match): void
    {
        if (! $match->involves((int) $request->user()->id)) {
            abort(403, 'You are not a member of this match.');
        }
    }
}
