<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CounsellingRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class CounsellingController extends Controller
{
    // POST /api/counselling          (auth:sanctum)
    public function store(Request $request)
    {
        $data = $this->validated($request, requireName: false);

        $record = $request->user()->counsellingRequests()->create($data);

        $this->notifyAdmin($record, $request->user()->name);

        return response()->json([
            'message' => 'Your counselling request has been received. We will be in touch soon.',
            'id'      => $record->id,
        ], 201);
    }

    // POST /api/counselling/public   (no auth)
    public function publicStore(Request $request)
    {
        $data = $this->validated($request, requireName: true);

        $record = CounsellingRequest::create($data);

        $this->notifyAdmin($record, $data['requester_name']);

        return response()->json([
            'message' => 'Your counselling request has been received. We will be in touch soon.',
            'id'      => $record->id,
        ], 201);
    }

    // GET /api/counselling           (auth:sanctum)
    public function index(Request $request)
    {
        $rows = $request->user()
            ->counsellingRequests()
            ->latest()
            ->get(['id', 'counselling_type', 'urgency', 'status', 'created_at']);

        return response()->json(['data' => $rows]);
    }

    // ── Private helpers ────────────────────────────────────────────────────

    private function validated(Request $request, bool $requireName): array
    {
        return $request->validate([
            'requester_name'      => $requireName ? 'required|string|max:150' : 'nullable|string|max:150',
            'counselor_gender'    => 'required|in:Male,Female,No preference',
            'contact_phone'       => 'nullable|string|max:20',
            'contact_email'       => 'nullable|email|max:255',
            'communication_modes' => 'required|array|min:1',
            'communication_modes.*' => 'in:Call,Text,Email,Video Call',
            'budget_range'        => 'required|string|max:100',
            'counselling_type'    => 'required|in:Relationship,Pre-marital,Marriage,Personal,Grief,Anxiety,Other',
            'session_format'      => 'required|in:Online,In-person,Either',
            'preferred_days'      => 'nullable|in:Weekdays,Weekends,Flexible',
            'preferred_time'      => 'nullable|in:Morning,Afternoon,Evening,Flexible',
            'urgency'             => 'required|in:This week,Within a month,No rush',
            'description'         => 'nullable|string|max:1000',
        ]);
    }

    private function notifyAdmin(CounsellingRequest $record, string $name): void
    {
        $adminEmail = env('MATCH_FIND_EMAIL');
        if (! $adminEmail) return;

        $modes = is_array($record->communication_modes)
            ? implode(', ', $record->communication_modes)
            : $record->communication_modes;

        $body = <<<TEXT
        ╔══════════════════════════════════════════╗
              NEW COUNSELLING REQUEST — Raya Dating
        ╚══════════════════════════════════════════╝

        Name            : {$name}
        Registered user : {$record->user_id}

        ── What they need ──────────────────────────
        Area            : {$record->counselling_type}
        Urgency         : {$record->urgency}
        Session format  : {$record->session_format}

        ── Counsellor preference ───────────────────
        Gender pref.    : {$record->counselor_gender}

        ── Availability ────────────────────────────
        Preferred days  : {$record->preferred_days}
        Preferred time  : {$record->preferred_time}

        ── Budget ──────────────────────────────────
        Budget/session  : {$record->budget_range}

        ── How to reach them ───────────────────────
        Communication   : {$modes}
        Phone           : {$record->contact_phone}
        Email           : {$record->contact_email}

        ── Their note ──────────────────────────────
        {$record->description}

        ─────────────────────────────────────────────
        Request ID #{$record->id} — submitted {$record->created_at->toDateTimeString()}
        TEXT;

        Mail::raw(
            $body,
            fn ($msg) => $msg
                ->to($adminEmail)
                ->subject("🫶 Counselling Request from {$name} — Raya Dating")
        );
    }
}
