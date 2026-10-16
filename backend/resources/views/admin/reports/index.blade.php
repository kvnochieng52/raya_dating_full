@extends('layouts.admin')
@section('title', 'Reports')

@section('content')
    <div class="page-head">
        <h1>Reports</h1>
        <div style="color:#888;font-size:13px;">{{ $reports->total() }} total</div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <form method="GET" class="filter-row">
                <select name="status" onchange="this.form.submit()">
                    <option value="all"        {{ $status==='all' ? 'selected' : '' }}>All statuses</option>
                    <option value="open"       {{ $status==='open' ? 'selected' : '' }}>Open</option>
                    <option value="reviewing"  {{ $status==='reviewing' ? 'selected' : '' }}>Reviewing</option>
                    <option value="resolved"   {{ $status==='resolved' ? 'selected' : '' }}>Resolved</option>
                    <option value="dismissed"  {{ $status==='dismissed' ? 'selected' : '' }}>Dismissed</option>
                </select>
            </form>
        </div>
        <table class="data">
            <thead>
                <tr><th>Reported user</th><th>Reporter</th><th>Reason</th><th>Status</th><th>Received</th><th></th></tr>
            </thead>
            <tbody>
                @forelse ($reports as $r)
                    <tr>
                        <td>
                            @if ($r->reportedUser)
                                <a href="{{ route('admin.users.show', $r->reportedUser) }}">
                                    <strong>{{ $r->reportedUser->name ?: '—' }}</strong>
                                </a>
                                <div style="font-size:12px;color:#888;">{{ $r->reportedUser->email }}</div>
                            @else — @endif
                        </td>
                        <td>
                            @if ($r->reporter)
                                {{ $r->reporter->name ?: $r->reporter->email }}
                            @else — @endif
                        </td>
                        <td><span class="pill muted">{{ $r->reason }}</span></td>
                        <td>
                            @php $pc = match($r->status) { 'resolved' => 'ok', 'reviewing' => 'info', 'dismissed' => 'muted', default => 'bad' }; @endphp
                            <span class="pill {{ $pc }}">{{ ucfirst($r->status) }}</span>
                        </td>
                        <td>{{ $r->created_at->diffForHumans() }}</td>
                        <td style="text-align:right;"><a href="{{ route('admin.reports.show', $r) }}" class="btn ghost small">Open</a></td>
                    </tr>
                @empty
                    <tr><td colspan="6" style="text-align:center;color:#999;padding:40px;">No reports.</td></tr>
                @endforelse
            </tbody>
        </table>
        <div class="pagination-wrap">{{ $reports->links() }}</div>
    </div>
@endsection
