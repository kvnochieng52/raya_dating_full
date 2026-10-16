@extends('layouts.admin')
@section('title', 'Contact #' . $contact->id)

@section('content')
    <div class="page-head">
        <div>
            <a href="{{ route('admin.contact.index') }}" style="font-size:13px;color:#888;">← Back</a>
            <h1 style="margin-top:4px;">{{ $contact->subject }}</h1>
            <div style="color:#666;">
                From <strong>{{ $contact->name }}</strong> &lt;{{ $contact->email }}&gt;
                · {{ $contact->created_at->format('M j, Y · H:i') }}
            </div>
        </div>
        <div style="display:flex;gap:8px;">
            <a href="mailto:{{ $contact->email }}?subject=Re: {{ urlencode($contact->subject) }}" class="btn primary small">Reply</a>
            <form method="POST" action="{{ route('admin.contact.destroy', $contact) }}" onsubmit="return confirm('Delete this message?');">
                @csrf @method('DELETE')
                <button class="btn danger small" type="submit">Delete</button>
            </form>
        </div>
    </div>

    <div class="panel">
        <div style="padding:24px;white-space:pre-wrap;">{{ $contact->message }}</div>
    </div>

    @if ($contact->ip_address || $contact->user_agent)
        <div class="panel">
            <div class="panel-head"><h2>Metadata</h2></div>
            <table class="data">
                @if ($contact->ip_address)
                    <tr><th style="width:200px;">IP address</th><td>{{ $contact->ip_address }}</td></tr>
                @endif
                @if ($contact->user_agent)
                    <tr><th>User agent</th><td style="font-size:12px;color:#666;">{{ $contact->user_agent }}</td></tr>
                @endif
            </table>
        </div>
    @endif
@endsection
