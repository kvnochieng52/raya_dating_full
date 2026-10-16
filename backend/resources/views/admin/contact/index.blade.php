@extends('layouts.admin')
@section('title', 'Contact messages')

@section('content')
    <div class="page-head">
        <h1>Contact messages</h1>
        <div style="color:#888;font-size:13px;">{{ $messages->total() }} total</div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <form method="GET" class="filter-row">
                <select name="filter" onchange="this.form.submit()">
                    <option value="all"    {{ $filter==='all' ? 'selected' : '' }}>All</option>
                    <option value="unread" {{ $filter==='unread' ? 'selected' : '' }}>Unread</option>
                    <option value="read"   {{ $filter==='read' ? 'selected' : '' }}>Read</option>
                </select>
            </form>
        </div>
        <table class="data">
            <thead>
                <tr><th>From</th><th>Subject</th><th>Received</th><th></th><th></th></tr>
            </thead>
            <tbody>
                @forelse ($messages as $m)
                    <tr style="{{ $m->read_at ? '' : 'font-weight:600;' }}">
                        <td>
                            {{ $m->name }}
                            <div style="font-size:12px;color:#888;font-weight:400;">{{ $m->email }}</div>
                        </td>
                        <td>{{ $m->subject }}</td>
                        <td>{{ $m->created_at->diffForHumans() }}</td>
                        <td>
                            @if (! $m->read_at)<span class="pill info">New</span>@endif
                        </td>
                        <td style="text-align:right;">
                            <a href="{{ route('admin.contact.show', $m) }}" class="btn ghost small">Open</a>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="5" style="text-align:center;color:#999;padding:40px;">No messages.</td></tr>
                @endforelse
            </tbody>
        </table>
        <div class="pagination-wrap">{{ $messages->links() }}</div>
    </div>
@endsection
