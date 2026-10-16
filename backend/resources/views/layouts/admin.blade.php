<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Admin') · Kingdom Dating</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f6f4f2;
            color: #1f1f1f;
            -webkit-font-smoothing: antialiased;
        }
        a { color: #C0392B; text-decoration: none; }
        a:hover { text-decoration: underline; }

        .shell { display: flex; min-height: 100vh; }

        /* ── Sidebar ───────────────────────────────────────────── */
        aside.sidebar {
            width: 240px;
            background: #1a1a1a;
            color: #e5e5e5;
            padding: 24px 0;
            display: flex;
            flex-direction: column;
        }
        .brand {
            padding: 0 24px 24px;
            border-bottom: 1px solid rgba(255,255,255,.08);
            font-family: 'Playfair Display', serif;
            font-size: 20px;
            font-weight: 700;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .brand small { font-family: 'Inter', sans-serif; font-size: 11px; color: rgba(255,255,255,.5); font-weight: 500; margin-left: auto; letter-spacing: .08em; text-transform: uppercase; }
        nav.side-nav { padding: 16px 0; flex: 1; }
        nav.side-nav a {
            display: flex; align-items: center; gap: 12px;
            padding: 10px 24px;
            color: rgba(255,255,255,.75);
            font-size: 14px;
            font-weight: 500;
            border-left: 3px solid transparent;
        }
        nav.side-nav a:hover { background: rgba(255,255,255,.05); color: #fff; text-decoration: none; }
        nav.side-nav a.active {
            background: rgba(192,57,43,.1);
            color: #fff;
            border-left-color: #C0392B;
        }
        .side-foot {
            padding: 16px 24px;
            border-top: 1px solid rgba(255,255,255,.08);
            font-size: 13px;
            color: rgba(255,255,255,.6);
        }
        .side-foot form { margin-top: 8px; }
        .side-foot button {
            background: none; border: 1px solid rgba(255,255,255,.2);
            color: rgba(255,255,255,.85);
            padding: 6px 12px; border-radius: 999px;
            font-size: 12px; cursor: pointer;
        }
        .side-foot button:hover { background: rgba(255,255,255,.08); }

        /* ── Main ──────────────────────────────────────────────── */
        main.content {
            flex: 1;
            padding: 32px 40px;
            max-width: 100%;
            overflow-x: auto;
        }
        .page-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }
        .page-head h1 {
            font-family: 'Playfair Display', serif;
            font-size: 28px;
            margin: 0;
            color: #1a1a1a;
        }

        /* ── Stat cards ────────────────────────────────────────── */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin-bottom: 32px;
        }
        .stat-card {
            background: #fff;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid rgba(0,0,0,.06);
        }
        .stat-card .label { font-size: 12px; text-transform: uppercase; letter-spacing: .08em; color: #888; font-weight: 600; }
        .stat-card .value { font-size: 28px; font-weight: 700; color: #1a1a1a; margin-top: 6px; }
        .stat-card .sub { font-size: 12px; color: #888; margin-top: 4px; }

        /* ── Cards / panels ────────────────────────────────────── */
        .panel {
            background: #fff;
            border-radius: 12px;
            border: 1px solid rgba(0,0,0,.06);
            overflow: hidden;
            margin-bottom: 24px;
        }
        .panel-head {
            padding: 16px 20px;
            border-bottom: 1px solid rgba(0,0,0,.06);
            display: flex; justify-content: space-between; align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }
        .panel-head h2 {
            font-family: 'Playfair Display', serif;
            margin: 0;
            font-size: 18px;
            color: #1a1a1a;
        }

        /* ── Tables ────────────────────────────────────────────── */
        table.data {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        table.data th, table.data td {
            padding: 12px 20px;
            text-align: left;
            border-bottom: 1px solid rgba(0,0,0,.05);
        }
        table.data th {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #666;
            font-weight: 600;
            background: #fafafa;
        }
        table.data tbody tr:hover { background: #fafafa; }
        table.data td.num { text-align: right; font-variant-numeric: tabular-nums; }

        /* ── Pills / badges ────────────────────────────────────── */
        .pill {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        .pill.ok { background: #eafaf1; color: #1e8449; }
        .pill.warn { background: #fff4e5; color: #a05a00; }
        .pill.bad { background: #fdecea; color: #a93226; }
        .pill.muted { background: #eceae7; color: #666; }
        .pill.info { background: #e8f0fe; color: #1a5fb4; }

        /* ── Buttons ───────────────────────────────────────────── */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 600;
            border: 1px solid transparent;
            cursor: pointer;
            background: #fff;
            color: #1a1a1a;
            text-decoration: none !important;
        }
        .btn:hover { background: #fafafa; }
        .btn.primary { background: #C0392B; color: #fff; border-color: #C0392B; }
        .btn.primary:hover { background: #a93226; }
        .btn.ghost { background: transparent; border-color: rgba(0,0,0,.12); }
        .btn.danger { background: #fff; color: #a93226; border-color: rgba(169,50,38,.3); }
        .btn.danger:hover { background: #fdecea; }
        .btn.small { padding: 5px 10px; font-size: 12px; }

        /* ── Form controls ─────────────────────────────────────── */
        input[type=text], input[type=email], input[type=password], select, textarea {
            padding: 9px 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            font-family: inherit;
            background: #fff;
            color: #1a1a1a;
        }
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #C0392B;
            box-shadow: 0 0 0 3px rgba(192,57,43,.12);
        }
        .filter-row { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }

        /* ── Alerts ────────────────────────────────────────────── */
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .alert.success { background: #eafaf1; color: #1e8449; border-left: 3px solid #27ae60; }
        .alert.error { background: #fdecea; color: #a93226; border-left: 3px solid #C0392B; }

        /* ── Pagination (Laravel default) ──────────────────────── */
        .pagination-wrap { padding: 16px 20px; }
        nav[role=navigation] svg { height: 14px; width: 14px; }
        .pagination { display: flex; gap: 4px; list-style: none; padding: 0; margin: 0; }
        .pagination li a, .pagination li span {
            display: inline-flex; min-width: 32px; height: 32px; align-items: center; justify-content: center;
            padding: 0 10px;
            border: 1px solid rgba(0,0,0,.08);
            border-radius: 6px;
            font-size: 13px;
            background: #fff;
            color: #1a1a1a;
        }
        .pagination li.active span { background: #C0392B; color: #fff; border-color: #C0392B; }
        .pagination li.disabled span { color: #aaa; background: #fafafa; }

        /* ── Responsive ────────────────────────────────────────── */
        @media (max-width: 900px) {
            .shell { flex-direction: column; }
            aside.sidebar { width: 100%; }
            nav.side-nav { display: flex; flex-wrap: wrap; }
            nav.side-nav a { border-left: none; border-bottom: 3px solid transparent; }
            nav.side-nav a.active { border-left-color: transparent; border-bottom-color: #C0392B; }
            main.content { padding: 24px 20px; }
        }
    </style>
    @stack('head')
</head>
<body>
<div class="shell">
    <aside class="sidebar">
        <div class="brand">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="#C0392B">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
            Kingdom
            <small>Admin</small>
        </div>
        <nav class="side-nav">
            @php
                $route = request()->route()?->getName();
                $openReports = \App\Models\Report::where('status', 'open')->count();
                $pendingCounselling = \App\Models\CounsellingRequest::where('status', 'pending')->count();
                $unreadContact = \App\Models\ContactMessage::whereNull('read_at')->count();
            @endphp
            <a href="{{ route('admin.dashboard') }}" class="{{ $route === 'admin.dashboard' ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>
                Dashboard
            </a>
            <a href="{{ route('admin.users.index') }}" class="{{ str_starts_with($route ?? '', 'admin.users') ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><path d="M20 8v6M23 11h-6"/></svg>
                Users
            </a>
            <a href="{{ route('admin.matches.index') }}" class="{{ str_starts_with($route ?? '', 'admin.matches') ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                Matches
            </a>
            <a href="{{ route('admin.reports.index') }}" class="{{ str_starts_with($route ?? '', 'admin.reports') ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg>
                Reports
                @if ($openReports > 0)<span class="pill bad" style="margin-left:auto;">{{ $openReports }}</span>@endif
            </a>
            <a href="{{ route('admin.counselling.index') }}" class="{{ str_starts_with($route ?? '', 'admin.counselling') ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                Counselling
                @if ($pendingCounselling > 0)<span class="pill warn" style="margin-left:auto;">{{ $pendingCounselling }}</span>@endif
            </a>
            <a href="{{ route('admin.contact.index') }}" class="{{ str_starts_with($route ?? '', 'admin.contact') ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                Contact
                @if ($unreadContact > 0)<span class="pill info" style="margin-left:auto;">{{ $unreadContact }}</span>@endif
            </a>
            <a href="{{ route('admin.broadcast.create') }}" class="{{ str_starts_with($route ?? '', 'admin.broadcast') ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 11l18-8-5 18-5-7-8-3z"/></svg>
                Broadcast
            </a>
            <a href="{{ route('admin.profile.edit') }}" class="{{ str_starts_with($route ?? '', 'admin.profile') ? 'active' : '' }}">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="7" r="4"/><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/></svg>
                My profile
            </a>
        </nav>
        <div class="side-foot">
            <div><strong style="color:#fff">{{ auth()->user()->name }}</strong></div>
            <div style="font-size:12px">{{ auth()->user()->email }}</div>
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit">Sign out</button>
            </form>
        </div>
    </aside>

    <main class="content">
        @if (session('status'))
            <div class="alert success">{{ session('status') }}</div>
        @endif
        @if ($errors->any())
            <div class="alert error">{{ $errors->first() }}</div>
        @endif

        @yield('content')
    </main>
</div>
</body>
</html>
