<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MatchRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\Rule;

class MatchRequestController extends Controller
{
    private const GENDERS = ['Man', 'Woman', 'Prefer not to say'];
    private const BODY_TYPES = [
        'Slim', 'Athletic', 'Average', 'Curvy', 'Thick', 'Fit',
        'Muscular', 'Plus-size', 'Petite',
    ];

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'gender' => ['required', Rule::in(self::GENDERS)],
            'body_type' => ['required', Rule::in(self::BODY_TYPES)],
            'religion' => ['required', 'string', 'max:64'],
            'phone' => ['required', 'string', 'min:7', 'max:32'],
            'email' => ['required', 'email', 'max:255'],
            'looking_for_details' => ['required', 'string', 'min:10', 'max:2000'],
        ]);

        $matchRequest = MatchRequest::create([
            ...$data,
            'user_id' => $request->user()?->id,
            'status' => MatchRequest::STATUS_PENDING,
        ]);

        $this->notifyAdmin($matchRequest, $request->user());

        return response()->json(['match_request' => $matchRequest], 201);
    }

    /**
     * Emails the form contents to the configured matchmaking inbox so the
     * team can follow up with the requester.
     */
    private function notifyAdmin(MatchRequest $req, $user): void
    {
        $to = config('mail.match_find_email') ?: env('MATCH_FIND_EMAIL');
        if (empty($to)) {
            Log::warning('MATCH_FIND_EMAIL is not configured; skipping match-request notification.');
            return;
        }

        $userLine = $user
            ? "Submitted by: {$user->name} ({$user->email}) [user_id={$user->id}]"
            : 'Submitted by: guest';

        $body = <<<TEXT
New match request received.

$userLine
Submitted at: {$req->created_at}

— About them —
Gender:       {$req->gender}
Body type:    {$req->body_type}
Religion:     {$req->religion}
Phone:        {$req->phone}
Email:        {$req->email}

— Who they are looking for —
{$req->looking_for_details}

Request ID: {$req->id}
TEXT;

        try {
            Mail::raw($body, function ($message) use ($to, $req) {
                $message->to($to)
                        ->subject("New match request #{$req->id}");
            });
        } catch (\Throwable $e) {
            Log::error('Failed to send match-request notification: ' . $e->getMessage());
        }
    }
}
