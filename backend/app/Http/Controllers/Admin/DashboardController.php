<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ContactMessage;
use App\Models\CounsellingRequest;
use App\Models\Report;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        $now = Carbon::now();

        $stats = [
            'users_total'        => User::count(),
            'users_verified'     => User::whereNotNull('email_verified_at')->count(),
            'users_suspended'    => User::whereNotNull('suspended_at')->count(),
            'users_new_today'    => User::whereDate('created_at', $now->toDateString())->count(),
            'users_new_week'     => User::where('created_at', '>=', $now->copy()->subDays(7))->count(),
            'matches_total'      => $this->safeCount('matches'),
            'messages_total'     => $this->safeCount('messages'),
            'counselling_pending'=> CounsellingRequest::where('status', 'pending')->count(),
            'counselling_total'  => CounsellingRequest::count(),
            'reports_open'       => Report::where('status', 'open')->count(),
            'reports_total'      => Report::count(),
            'contact_unread'     => ContactMessage::whereNull('read_at')->count(),
        ];

        $recentUsers = User::latest()->take(8)->get(['id', 'name', 'email', 'created_at', 'email_verified_at', 'suspended_at']);

        $recentCounselling = CounsellingRequest::with('user:id,name,email')
            ->latest()
            ->take(6)
            ->get();

        // 30-day signup trend
        $signupSeries = User::select(
                DB::raw('DATE(created_at) as day'),
                DB::raw('COUNT(*) as total')
            )
            ->where('created_at', '>=', $now->copy()->subDays(29)->startOfDay())
            ->groupBy('day')
            ->orderBy('day')
            ->pluck('total', 'day');

        return view('admin.dashboard', compact('stats', 'recentUsers', 'recentCounselling', 'signupSeries'));
    }

    private function safeCount(string $table): int
    {
        try {
            return DB::table($table)->count();
        } catch (\Throwable) {
            return 0;
        }
    }
}
