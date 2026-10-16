<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\StreamedResponse;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $q      = trim((string) $request->get('q', ''));
        $filter = $request->get('filter', 'all');

        $users = User::with('profile')
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($sub) use ($q) {
                    $sub->where('name', 'like', "%{$q}%")
                        ->orWhere('email', 'like', "%{$q}%")
                        ->orWhere('phone', 'like', "%{$q}%");
                });
            })
            ->when($filter === 'verified', fn($qq) => $qq->whereNotNull('email_verified_at'))
            ->when($filter === 'unverified', fn($qq) => $qq->whereNull('email_verified_at'))
            ->when($filter === 'suspended', fn($qq) => $qq->whereNotNull('suspended_at'))
            ->when($filter === 'admins', fn($qq) => $qq->where('is_admin', true))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.users.index', compact('users', 'q', 'filter'));
    }

    public function show(User $user)
    {
        $user->load(['profile.photos']);
        $messageCount = DB::table('messages')->where('sender_id', $user->id)->count();
        $matchCount   = DB::table('matches')
            ->where('user_low_id', $user->id)
            ->orWhere('user_high_id', $user->id)
            ->count();

        return view('admin.users.show', compact('user', 'messageCount', 'matchCount'));
    }

    public function verify(User $user)
    {
        $user->email_verified_at = $user->email_verified_at ? null : Carbon::now();
        $user->save();
        return back()->with('status', 'Email verification updated.');
    }

    public function suspend(User $user)
    {
        if ($user->is_admin) {
            return back()->withErrors(['user' => 'Admins cannot be suspended from the dashboard.']);
        }
        $user->suspended_at = $user->suspended_at ? null : Carbon::now();
        $user->save();
        return back()->with('status', $user->suspended_at ? 'User suspended.' : 'User reinstated.');
    }

    public function toggleAdmin(Request $request, User $user)
    {
        if ($user->id === $request->user()->id) {
            return back()->withErrors(['user' => 'You cannot change your own admin flag.']);
        }
        $user->is_admin = ! $user->is_admin;
        $user->save();
        return back()->with('status', $user->is_admin ? 'Granted admin access.' : 'Revoked admin access.');
    }

    public function destroy(Request $request, User $user)
    {
        if ($user->id === $request->user()->id) {
            return back()->withErrors(['user' => 'You cannot delete your own account.']);
        }
        if ($user->is_admin) {
            return back()->withErrors(['user' => 'Revoke admin before deleting.']);
        }
        $user->delete();
        return redirect()->route('admin.users.index')->with('status', 'User deleted.');
    }

    public function export(): StreamedResponse
    {
        $filename = 'users-' . now()->format('Y-m-d') . '.csv';

        return response()->streamDownload(function () {
            $out = fopen('php://output', 'w');
            fputcsv($out, [
                'id', 'name', 'email', 'phone', 'is_admin',
                'email_verified_at', 'suspended_at', 'completed_step',
                'nickname', 'gender', 'city', 'country', 'birth_date',
                'created_at',
            ]);

            User::with('profile')->orderBy('id')->chunk(500, function ($users) use ($out) {
                foreach ($users as $u) {
                    fputcsv($out, [
                        $u->id,
                        $u->name,
                        $u->email,
                        $u->phone,
                        $u->is_admin ? 'yes' : '',
                        optional($u->email_verified_at)->toIso8601String(),
                        optional($u->suspended_at)->toIso8601String(),
                        $u->profile?->completed_step,
                        $u->profile?->nickname,
                        $u->profile?->gender,
                        $u->profile?->city,
                        $u->profile?->country,
                        optional($u->profile?->birth_date)->toDateString(),
                        $u->created_at->toIso8601String(),
                    ]);
                }
            });
            fclose($out);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=utf-8',
        ]);
    }
}
