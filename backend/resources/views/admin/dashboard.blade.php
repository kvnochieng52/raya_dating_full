@extends('layouts.admin')
@section('title', 'Dashboard')

@section('content')
    <div class="page-head">
        <h1>Dashboard</h1>
        <div style="font-size:13px;color:#888">As of {{ now()->format('M j, Y · H:i') }}</div>
    </div>

    <div class="stat-grid">
        <div class="stat-card">
            <div class="label">Total users</div>
            <div class="value">{{ number_format($stats['users_total']) }}</div>
            <div class="sub">{{ $stats['users_new_today'] }} today · {{ $stats['users_new_week'] }} this week</div>
        </div>
        <div class="stat-card">
            <div class="label">Verified</div>
            <div class="value">{{ number_format($stats['users_verified']) }}</div>
            <div class="sub">
                @php $pct = $stats['users_total'] ? round($stats['users_verified'] / $stats['users_total'] * 100) : 0; @endphp
                {{ $pct }}% of users
            </div>
        </div>
        <div class="stat-card">
            <div class="label">Suspended</div>
            <div class="value">{{ number_format($stats['users_suspended']) }}</div>
            <div class="sub">—</div>
        </div>
        <div class="stat-card">
            <div class="label">Matches</div>
            <div class="value">{{ number_format($stats['matches_total']) }}</div>
            <div class="sub">All-time pairs</div>
        </div>
        <div class="stat-card">
            <div class="label">Messages</div>
            <div class="value">{{ number_format($stats['messages_total']) }}</div>
            <div class="sub">All-time sent</div>
        </div>
        <div class="stat-card">
            <div class="label">Counselling</div>
            <div class="value">{{ number_format($stats['counselling_pending']) }}</div>
            <div class="sub">Pending of {{ $stats['counselling_total'] }} total</div>
        </div>
        <div class="stat-card">
            <div class="label">Open reports</div>
            <div class="value" style="color:{{ $stats['reports_open'] > 0 ? '#C0392B' : '#1a1a1a' }};">{{ number_format($stats['reports_open']) }}</div>
            <div class="sub">{{ $stats['reports_total'] }} all-time</div>
        </div>
        <div class="stat-card">
            <div class="label">Unread contact</div>
            <div class="value">{{ number_format($stats['contact_unread']) }}</div>
            <div class="sub">Website form</div>
        </div>
    </div>

    @if ($signupSeries->isNotEmpty())
        @php
            $max = max($signupSeries->toArray()) ?: 1;
            $days = collect(range(0, 29))->map(fn($i) => now()->subDays(29 - $i)->toDateString());
        @endphp
        <div class="panel">
            <div class="panel-head"><h2>Signups — last 30 days</h2></div>
            <div style="padding:20px;">
                <div style="display:flex;align-items:flex-end;gap:4px;height:140px;">
                    @foreach ($days as $day)
                        @php $v = (int)($signupSeries[$day] ?? 0); @endphp
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:4px;" title="{{ $day }}: {{ $v }}">
                            <div style="width:100%;height:{{ max(2, round($v / $max * 120)) }}px;background:linear-gradient(180deg,#C0392B,#e05742);border-radius:3px 3px 0 0;"></div>
                        </div>
                    @endforeach
                </div>
                <div style="display:flex;justify-content:space-between;color:#888;font-size:11px;margin-top:6px;">
                    <span>{{ $days->first() }}</span>
                    <span>{{ $days->last() }}</span>
                </div>
            </div>
        </div>
    @endif

    <div class="panel">
        <div class="panel-head">
            <h2>Recent signups</h2>
            <a href="{{ route('admin.users.index') }}" class="btn ghost small">View all</a>
        </div>
        <table class="data">
            <thead>
                <tr><th>Name</th><th>Email</th><th>Joined</th><th>Status</th></tr>
            </thead>
            <tbody>
                @forelse ($recentUsers as $u)
                    <tr>
                        <td><a href="{{ route('admin.users.show', $u) }}">{{ $u->name ?: '—' }}</a></td>
                        <td>{{ $u->email }}</td>
                        <td>{{ $u->created_at->diffForHumans() }}</td>
                        <td>
                            @if ($u->suspended_at)
                                <span class="pill bad">Suspended</span>
                            @elseif ($u->email_verified_at)
                                <span class="pill ok">Verified</span>
                            @else
                                <span class="pill warn">Unverified</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="4" style="text-align:center;color:#999;">No users yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="panel">
        <div class="panel-head">
            <h2>Recent counselling requests</h2>
            <a href="{{ route('admin.counselling.index') }}" class="btn ghost small">View all</a>
        </div>
        <table class="data">
            <thead>
                <tr><th>Requester</th><th>Type</th><th>Urgency</th><th>Status</th><th>Received</th></tr>
            </thead>
            <tbody>
                @forelse ($recentCounselling as $r)
                    <tr>
                        <td>
                            <a href="{{ route('admin.counselling.show', $r) }}">
                                {{ $r->user->name ?? $r->requester_name ?? '—' }}
                            </a>
                        </td>
                        <td>{{ $r->counselling_type }}</td>
                        <td>{{ $r->urgency }}</td>
                        <td>
                            @php $pillClass = match($r->status) { 'resolved' => 'ok', 'contacted' => 'info', default => 'warn' }; @endphp
                            <span class="pill {{ $pillClass }}">{{ ucfirst($r->status) }}</span>
                        </td>
                        <td>{{ $r->created_at->diffForHumans() }}</td>
                    </tr>
                @empty
                    <tr><td colspan="5" style="text-align:center;color:#999;">No requests yet.</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
