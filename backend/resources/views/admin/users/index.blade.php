@extends('layouts.admin')
@section('title', 'Users')

@section('content')
    <div class="page-head">
        <h1>Users</h1>
        <div style="display:flex;gap:12px;align-items:center;">
            <span style="color:#888;font-size:13px;">{{ $users->total() }} total</span>
            <a href="{{ route('admin.users.export') }}" class="btn ghost small">Export CSV</a>
        </div>
    </div>

    <div class="panel">
        <div class="panel-head">
            <form method="GET" action="{{ route('admin.users.index') }}" class="filter-row" style="flex:1;">
                <input type="text" name="q" placeholder="Search name, email, phone…" value="{{ $q }}" style="flex:1;min-width:200px;">
                <select name="filter">
                    <option value="all"        {{ $filter==='all' ? 'selected' : '' }}>All</option>
                    <option value="verified"   {{ $filter==='verified' ? 'selected' : '' }}>Verified</option>
                    <option value="unverified" {{ $filter==='unverified' ? 'selected' : '' }}>Unverified</option>
                    <option value="suspended"  {{ $filter==='suspended' ? 'selected' : '' }}>Suspended</option>
                    <option value="admins"     {{ $filter==='admins' ? 'selected' : '' }}>Admins</option>
                </select>
                <button class="btn primary small" type="submit">Filter</button>
                @if ($q || $filter !== 'all')
                    <a href="{{ route('admin.users.index') }}" class="btn ghost small">Reset</a>
                @endif
            </form>
        </div>
        <table class="data">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Joined</th>
                    <th>Status</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                @forelse ($users as $u)
                    <tr>
                        <td>
                            <a href="{{ route('admin.users.show', $u) }}"><strong>{{ $u->name ?: '—' }}</strong></a>
                            @if ($u->is_admin)
                                <span class="pill info" style="margin-left:4px;">Admin</span>
                            @endif
                        </td>
                        <td>{{ $u->email }}</td>
                        <td>{{ $u->phone ?: '—' }}</td>
                        <td>{{ $u->created_at->format('M j, Y') }}</td>
                        <td>
                            @if ($u->suspended_at)
                                <span class="pill bad">Suspended</span>
                            @elseif ($u->email_verified_at)
                                <span class="pill ok">Verified</span>
                            @else
                                <span class="pill warn">Unverified</span>
                            @endif
                        </td>
                        <td style="text-align:right;">
                            <a href="{{ route('admin.users.show', $u) }}" class="btn ghost small">Open</a>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="6" style="text-align:center;color:#999;padding:40px;">No users match.</td></tr>
                @endforelse
            </tbody>
        </table>
        <div class="pagination-wrap">{{ $users->links() }}</div>
    </div>
@endsection
