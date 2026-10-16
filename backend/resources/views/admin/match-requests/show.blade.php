@extends('layouts.admin')
@section('title', 'Match request #' . $item->id)

@section('content')
    <div class="page-head">
        <div>
            <a href="{{ route('admin.matchRequests.index') }}" style="font-size:13px;color:#888;">← Back to requests</a>
            <h1 style="margin-top:4px;">Request #{{ $item->id }}</h1>
            <div style="color:#666;">{{ $item->created_at->format('M j, Y · H:i') }}</div>
        </div>
        <form method="POST" action="{{ route('admin.matchRequests.update', $item) }}" class="filter-row">
            @csrf
            <select name="status">
                <option value="pending"   {{ $item->status==='pending' ? 'selected' : '' }}>Pending</option>
                <option value="reviewed"  {{ $item->status==='reviewed' ? 'selected' : '' }}>Reviewed</option>
                <option value="contacted" {{ $item->status==='contacted' ? 'selected' : '' }}>Contacted</option>
                <option value="closed"    {{ $item->status==='closed' ? 'selected' : '' }}>Closed</option>
            </select>
            <button class="btn primary small" type="submit">Update</button>
        </form>
    </div>

    <div class="panel">
        <div class="panel-head"><h2>Details</h2></div>
        <table class="data">
            <tbody>
                <tr>
                    <th style="width:200px;">Submitter</th>
                    <td>
                        @if ($item->user)
                            <a href="{{ route('admin.users.show', $item->user) }}">{{ $item->user->name }}</a>
                            · {{ $item->user->email }}
                        @else <em>public submission</em> @endif
                    </td>
                </tr>
                @foreach ([
                    'Gender' => $item->gender,
                    'Body type' => $item->body_type,
                    'Religion' => $item->religion,
                    'Contact phone' => $item->phone,
                    'Contact email' => $item->email,
                ] as $label => $value)
                    <tr><th>{{ $label }}</th><td>{{ $value ?: '—' }}</td></tr>
                @endforeach
                <tr>
                    <th>Looking for</th>
                    <td style="white-space:pre-wrap;">{{ $item->looking_for_details ?: '—' }}</td>
                </tr>
            </tbody>
        </table>
    </div>
@endsection
