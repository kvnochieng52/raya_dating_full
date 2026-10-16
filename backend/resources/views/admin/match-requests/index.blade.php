@extends('layouts.admin')
@section('title', 'Match requests')

@section('content')
    <div class="page-head">
        <h1>Match-finder requests</h1>
        <div style="color:#888;font-size:13px;">{{ $items->total() }} total</div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <form method="GET" class="filter-row">
                <select name="status" onchange="this.form.submit()">
                    <option value="all"       {{ $status==='all' ? 'selected' : '' }}>All</option>
                    <option value="pending"   {{ $status==='pending' ? 'selected' : '' }}>Pending</option>
                    <option value="reviewed"  {{ $status==='reviewed' ? 'selected' : '' }}>Reviewed</option>
                    <option value="contacted" {{ $status==='contacted' ? 'selected' : '' }}>Contacted</option>
                    <option value="closed"    {{ $status==='closed' ? 'selected' : '' }}>Closed</option>
                </select>
            </form>
        </div>
        <table class="data">
            <thead>
                <tr><th>Submitter</th><th>Gender</th><th>Religion</th><th>Status</th><th>Received</th><th></th></tr>
            </thead>
            <tbody>
                @forelse ($items as $r)
                    <tr>
                        <td>
                            <strong>{{ $r->user->name ?? '—' }}</strong>
                            <div style="font-size:12px;color:#888;">{{ $r->email ?: $r->user->email ?? '' }}</div>
                        </td>
                        <td>{{ $r->gender ?: '—' }}</td>
                        <td>{{ $r->religion ?: '—' }}</td>
                        <td>
                            @php $pc = match($r->status) { 'closed' => 'ok', 'contacted' => 'info', 'reviewed' => 'muted', default => 'warn' }; @endphp
                            <span class="pill {{ $pc }}">{{ ucfirst($r->status) }}</span>
                        </td>
                        <td>{{ $r->created_at->diffForHumans() }}</td>
                        <td style="text-align:right;"><a href="{{ route('admin.matchRequests.show', $r) }}" class="btn ghost small">Open</a></td>
                    </tr>
                @empty
                    <tr><td colspan="6" style="text-align:center;color:#999;padding:40px;">No requests.</td></tr>
                @endforelse
            </tbody>
        </table>
        <div class="pagination-wrap">{{ $items->links() }}</div>
    </div>
@endsection
