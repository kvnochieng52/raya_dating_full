@extends('layouts.admin')
@section('title', 'Counselling request')

@section('content')
    <div class="page-head">
        <div>
            <a href="{{ route('admin.counselling.index') }}" style="font-size:13px;color:#888;">← Back to requests</a>
            <h1 style="margin-top:4px;">Request #{{ $counselling->id }}</h1>
            <div style="color:#666;">{{ $counselling->created_at->format('M j, Y · H:i') }}</div>
        </div>
        <form method="POST" action="{{ route('admin.counselling.status', $counselling) }}" class="filter-row">
            @csrf
            <select name="status">
                <option value="pending"   {{ $counselling->status==='pending' ? 'selected' : '' }}>Pending</option>
                <option value="contacted" {{ $counselling->status==='contacted' ? 'selected' : '' }}>Contacted</option>
                <option value="resolved"  {{ $counselling->status==='resolved' ? 'selected' : '' }}>Resolved</option>
            </select>
            <button type="submit" class="btn primary small">Update status</button>
        </form>
    </div>

    <div class="panel">
        <div class="panel-head"><h2>Details</h2></div>
        <table class="data">
            <tbody>
                @foreach ([
                    'Requester' => $counselling->user->name ?? $counselling->requester_name ?? '—',
                    'Account email' => $counselling->user->email ?? 'public submission',
                    'Contact email' => $counselling->contact_email,
                    'Contact phone' => $counselling->contact_phone,
                    'Counsellor gender' => $counselling->counselor_gender,
                    'Counselling type' => $counselling->counselling_type,
                    'Session format' => $counselling->session_format,
                    'Preferred days' => $counselling->preferred_days,
                    'Preferred time' => $counselling->preferred_time,
                    'Budget range' => $counselling->budget_range,
                    'Urgency' => $counselling->urgency,
                ] as $label => $value)
                    <tr><th style="width:200px;">{{ $label }}</th><td>{{ $value ?: '—' }}</td></tr>
                @endforeach
                <tr>
                    <th>Communication</th>
                    <td>
                        @foreach ((array)$counselling->communication_modes as $mode)
                            <span class="pill muted">{{ $mode }}</span>
                        @endforeach
                    </td>
                </tr>
                <tr>
                    <th>Description</th>
                    <td style="white-space:pre-wrap;">{{ $counselling->description ?: '—' }}</td>
                </tr>
            </tbody>
        </table>
    </div>
@endsection
