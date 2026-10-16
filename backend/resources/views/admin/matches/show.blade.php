@extends('layouts.admin')
@section('title', 'Match #' . $match->id)

@section('content')
    <div class="page-head">
        <div>
            <a href="{{ route('admin.matches.index') }}" style="font-size:13px;color:#888;">← Back to matches</a>
            <h1 style="margin-top:4px;">Match #{{ $match->id }}</h1>
            <div style="color:#666;">
                <a href="{{ route('admin.users.show', $match->userLow) }}">{{ $match->userLow->name }}</a>
                &amp;
                <a href="{{ route('admin.users.show', $match->userHigh) }}">{{ $match->userHigh->name }}</a>
                · matched {{ $match->matched_at->format('M j, Y') }}
            </div>
        </div>
        <form method="POST" action="{{ route('admin.matches.destroy', $match) }}"
              onsubmit="return confirm('Delete this match and all its messages?');">
            @csrf
            @method('DELETE')
            <button class="btn danger small" type="submit">Unmatch &amp; delete</button>
        </form>
    </div>

    <div class="panel">
        <div class="panel-head"><h2>Conversation ({{ $messages->count() }} messages)</h2></div>
        <div style="padding:20px;max-height:600px;overflow-y:auto;">
            @forelse ($messages as $msg)
                @php $isLow = $msg->sender_id === $match->user_low_id; @endphp
                <div style="display:flex;margin-bottom:12px;{{ $isLow ? '' : 'justify-content:flex-end;' }}">
                    <div style="max-width:70%;background:{{ $isLow ? '#f0f0f0' : '#fff4f0' }};padding:10px 14px;border-radius:12px;{{ $isLow ? 'border-top-left-radius:4px;' : 'border-top-right-radius:4px;' }}">
                        <div style="font-size:11px;color:#888;margin-bottom:2px;">
                            <strong style="color:#333;">{{ $msg->sender->name ?? '—' }}</strong>
                            · {{ $msg->created_at->format('M j · H:i') }}
                        </div>
                        <div style="white-space:pre-wrap;">{{ $msg->body }}</div>
                        <form method="POST" action="{{ route('admin.messages.destroy', $msg) }}" style="margin-top:4px;"
                              onsubmit="return confirm('Delete this message?');">
                            @csrf @method('DELETE')
                            <button type="submit" style="background:none;border:none;color:#a93226;font-size:11px;cursor:pointer;padding:0;">Delete</button>
                        </form>
                    </div>
                </div>
            @empty
                <p style="color:#999;text-align:center;">No messages yet.</p>
            @endforelse
        </div>
    </div>
@endsection
