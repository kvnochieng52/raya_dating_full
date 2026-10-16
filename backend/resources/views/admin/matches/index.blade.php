@extends('layouts.admin')
@section('title', 'Matches')

@section('content')
    <div class="page-head">
        <h1>Matches</h1>
        <div style="color:#888;font-size:13px;">{{ $matches->total() }} total</div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <form method="GET" class="filter-row" style="flex:1;">
                <input type="text" name="q" placeholder="Search by participant name or email…" value="{{ $q }}" style="flex:1;min-width:260px;">
                <button class="btn primary small" type="submit">Search</button>
                @if ($q)<a href="{{ route('admin.matches.index') }}" class="btn ghost small">Reset</a>@endif
            </form>
        </div>
        <table class="data">
            <thead>
                <tr><th>Match #</th><th>Participants</th><th>Messages</th><th>Matched</th><th></th></tr>
            </thead>
            <tbody>
                @forelse ($matches as $m)
                    <tr>
                        <td><a href="{{ route('admin.matches.show', $m) }}">#{{ $m->id }}</a></td>
                        <td>
                            {{ $m->userLow->name ?? '—' }} <span style="color:#888;">&amp;</span>
                            {{ $m->userHigh->name ?? '—' }}
                            <div style="font-size:12px;color:#888;">
                                {{ $m->userLow->email ?? '' }} · {{ $m->userHigh->email ?? '' }}
                            </div>
                        </td>
                        <td class="num">{{ $m->messages_count }}</td>
                        <td>{{ $m->matched_at->diffForHumans() }}</td>
                        <td style="text-align:right;">
                            <a href="{{ route('admin.matches.show', $m) }}" class="btn ghost small">Open</a>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="5" style="text-align:center;color:#999;padding:40px;">No matches.</td></tr>
                @endforelse
            </tbody>
        </table>
        <div class="pagination-wrap">{{ $matches->links() }}</div>
    </div>
@endsection
