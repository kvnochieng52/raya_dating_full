@extends('layouts.admin')
@section('title', 'Broadcast')

@section('content')
    <div class="page-head">
        <h1>Send broadcast email</h1>
    </div>

    <div class="panel">
        <form method="POST" action="{{ route('admin.broadcast.send') }}" style="padding:24px;max-width:720px;">
            @csrf
            <div style="margin-bottom:16px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Audience</label>
                <select name="audience" required>
                    <option value="all">All active users ({{ $counts['all'] }})</option>
                    <option value="verified">Verified users only ({{ $counts['verified'] }})</option>
                    <option value="unverified">Unverified users only ({{ $counts['unverified'] }})</option>
                </select>
            </div>
            <div style="margin-bottom:16px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Subject</label>
                <input type="text" name="subject" required maxlength="150" style="width:100%;" value="{{ old('subject') }}">
            </div>
            <div style="margin-bottom:16px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Message</label>
                <textarea name="body" required rows="12" style="width:100%;">{{ old('body') }}</textarea>
                <small style="color:#888;">Plain text. Keep it short.</small>
            </div>
            <div style="margin-bottom:20px;">
                <label style="display:inline-flex;align-items:center;gap:8px;">
                    <input type="checkbox" name="confirm" value="1" required>
                    I understand this will send email to the selected audience immediately.
                </label>
            </div>
            <button class="btn primary" type="submit">Send broadcast</button>
        </form>
    </div>
@endsection
