<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class CounsellingController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
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

        $record = $request->user()->counsellingRequests()->create($data);

        // Notify admin
        $adminEmail = env('COUNSELLING_ADMIN_EMAIL', env('MATCH_FIND_EMAIL'));
        if ($adminEmail) {
            $user = $request->user();
            $modes = implode(', ', $data['communication_modes']);
            Mail::raw(
                "New counselling request from {$user->name} (#{$user->id})\n\n"
                . "Type:            {$data['counselling_type']}\n"
                . "Counselor pref:  {$data['counselor_gender']}\n"
                . "Session format:  {$data['session_format']}\n"
                . "Communication:   {$modes}\n"
                . "Budget:          {$data['budget_range']}\n"
                . "Urgency:         {$data['urgency']}\n"
                . "Preferred days:  " . ($data['preferred_days'] ?? '—') . "\n"
                . "Preferred time:  " . ($data['preferred_time'] ?? '—') . "\n"
                . "Phone:           " . ($data['contact_phone'] ?? '—') . "\n"
                . "Email:           " . ($data['contact_email'] ?? '—') . "\n\n"
                . "Note:\n" . ($data['description'] ?? '—'),
                fn ($msg) => $msg->to($adminEmail)->subject("Counselling Request — {$user->name}")
            );
        }

        return response()->json([
            'message' => 'Your counselling request has been received. We will be in touch soon.',
            'id'      => $record->id,
        ], 201);
    }

    public function index(Request $request)
    {
        $requests = $request->user()
            ->counsellingRequests()
            ->latest()
            ->get(['id', 'counselling_type', 'urgency', 'status', 'created_at']);

        return response()->json(['data' => $requests]);
    }
}
