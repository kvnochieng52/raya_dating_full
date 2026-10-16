@extends('layouts.admin')
@section('title', 'Counselling')

@section('content')
    <div class="page-head">
        <h1>Counselling requests</h1>
        <div style="color:#888;font-size:13px;">{{ $requests->total() }} total</div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <form method="GET" class="filter-row">
                <select name="status" onchange="this.form.submit()">
                    <option value="all"       {{ $status==='all' ? 'selected' : '' }}>All statuses</option>
                    <option value="pending"   {{ $status==='pending' ? 'selected' : '' }}>Pending</option>
                    <option value="contacted" {{ $status==='contacted' ? 'selected' : '' }}>Contacted</option>
                    <option value="resolved"  {{ $status==='resolved' ? 'selected' : '' }}>Resolved</option>
                </select>
            </form>
        </div>
        <table class="data">
            <thead>
                <tr><th>Requester</th><th>Type</th><th>Format</th><th>Urgency</th><th>Status</th><th>Received</th><th></th></tr>
            </thead>
            <tbody>
                @forelse ($requests as $r)
                    <tr>
                        <td>
                            <strong>{{ $r->user->name ?? $r->requester_name ?? '—' }}</strong>
                            <div style="font-size:12px;color:#888;">{{ $r->contact_email ?: $r->user->email ?? '—' }}</div>
                        </td>
                        <td>{{ $r->counselling_type }}</td>
                        <td>{{ $r->session_format }}</td>
                        <td>{{ $r->urgency }}</td>
                        <td>
                            @php $pillClass = match($r->status) { 'resolved' => 'ok', 'contacted' => 'info', default => 'warn' }; @endphp
                            <span class="pill {{ $pillClass }}">{{ ucfirst($r->status) }}</span>
                        </td>
                        <td>{{ $r->created_at->diffForHumans() }}</td>
                        <td style="text-align:right;">
                            <a href="{{ route('admin.counselling.show', $r) }}" class="btn ghost small">Open</a>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="7" style="text-align:center;color:#999;padding:40px;">No requests.</td></tr>
                @endforelse
            </tbody>
        </table>
        <div class="pagination-wrap">{{ $requests->links() }}</div>
    </div>
@endsection
