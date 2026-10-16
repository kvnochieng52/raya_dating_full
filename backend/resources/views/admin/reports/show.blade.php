@extends('layouts.admin')
@section('title', 'Report #' . $report->id)

@section('content')
    <div class="page-head">
        <div>
            <a href="{{ route('admin.reports.index') }}" style="font-size:13px;color:#888;">← Back to reports</a>
            <h1 style="margin-top:4px;">Report #{{ $report->id }}</h1>
            <div style="color:#666;">{{ $report->created_at->format('M j, Y · H:i') }}</div>
        </div>
    </div>

    <div class="panel">
        <div class="panel-head"><h2>Summary</h2></div>
        <table class="data">
            <tr>
                <th style="width:200px;">Reported user</th>
                <td>
                    @if ($report->reportedUser)
                        <a href="{{ route('admin.users.show', $report->reportedUser) }}">
                            <strong>{{ $report->reportedUser->name ?: '—' }}</strong>
                        </a>
                        · {{ $report->reportedUser->email }}
                    @else <em>deleted</em> @endif
                </td>
            </tr>
            <tr>
                <th>Reporter</th>
                <td>
                    @if ($report->reporter)
                        <a href="{{ route('admin.users.show', $report->reporter) }}">
                            {{ $report->reporter->name ?: $report->reporter->email }}
                        </a>
                    @else <em>deleted</em> @endif
                </td>
            </tr>
            <tr><th>Reason</th><td><span class="pill muted">{{ $report->reason }}</span></td></tr>
            <tr>
                <th>Status</th>
                <td>
                    @php $pc = match($report->status) { 'resolved' => 'ok', 'reviewing' => 'info', 'dismissed' => 'muted', default => 'bad' }; @endphp
                    <span class="pill {{ $pc }}">{{ ucfirst($report->status) }}</span>
                    @if ($report->resolved_at)
                        <small style="color:#888;margin-left:8px;">
                            by {{ $report->resolver->name ?? '—' }} · {{ $report->resolved_at->diffForHumans() }}
                        </small>
                    @endif
                </td>
            </tr>
            <tr><th>Details</th><td style="white-space:pre-wrap;">{{ $report->details ?: '—' }}</td></tr>
        </table>
    </div>

    <div class="panel">
        <div class="panel-head"><h2>Action</h2></div>
        <form method="POST" action="{{ route('admin.reports.update', $report) }}" style="padding:20px;">
            @csrf
            <div style="margin-bottom:12px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Status</label>
                <select name="status">
                    @foreach (\App\Models\Report::STATUSES as $s)
                        <option value="{{ $s }}" {{ $report->status === $s ? 'selected' : '' }}>{{ ucfirst($s) }}</option>
                    @endforeach
                </select>
            </div>
            <div style="margin-bottom:12px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Internal notes</label>
                <textarea name="admin_notes" rows="4" style="width:100%;">{{ old('admin_notes', $report->admin_notes) }}</textarea>
            </div>
            <button class="btn primary" type="submit">Save</button>
        </form>
    </div>

    @if ($alsoReported->isNotEmpty())
        <div class="panel">
            <div class="panel-head"><h2>Other reports against this user</h2></div>
            <table class="data">
                <thead><tr><th>#</th><th>Reason</th><th>Reporter</th><th>Status</th><th>When</th></tr></thead>
                <tbody>
                    @foreach ($alsoReported as $r)
                        <tr>
                            <td><a href="{{ route('admin.reports.show', $r) }}">#{{ $r->id }}</a></td>
                            <td>{{ $r->reason }}</td>
                            <td>{{ $r->reporter->name ?? '—' }}</td>
                            <td>{{ $r->status }}</td>
                            <td>{{ $r->created_at->diffForHumans() }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    @endif
@endsection
