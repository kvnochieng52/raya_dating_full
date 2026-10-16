<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class BroadcastController extends Controller
{
    public function create()
    {
        $counts = [
            'all'        => User::whereNull('suspended_at')->count(),
            'verified'   => User::whereNotNull('email_verified_at')->whereNull('suspended_at')->count(),
            'unverified' => User::whereNull('email_verified_at')->whereNull('suspended_at')->count(),
        ];
        return view('admin.broadcasts.create', compact('counts'));
    }

    public function send(Request $request)
    {
        $data = $request->validate([
            'audience' => ['required', 'in:all,verified,unverified'],
            'subject'  => ['required', 'string', 'max:150'],
            'body'     => ['required', 'string', 'max:10000'],
            'confirm'  => ['accepted'],
        ]);

        $query = User::query()
            ->whereNull('suspended_at')
            ->whereNotNull('email');

        if ($data['audience'] === 'verified') {
            $query->whereNotNull('email_verified_at');
        } elseif ($data['audience'] === 'unverified') {
            $query->whereNull('email_verified_at');
        }

        $sent = 0;
        $failed = 0;
        $query->chunk(200, function ($users) use ($data, &$sent, &$failed) {
            foreach ($users as $user) {
                try {
                    Mail::raw($data['body'], function ($mail) use ($user, $data) {
                        $mail->to($user->email)->subject($data['subject']);
                    });
                    $sent++;
                } catch (\Throwable) {
                    $failed++;
                }
            }
        });

        return back()->with('status', "Broadcast queued. Sent to {$sent} users, {$failed} failed.");
    }
}
