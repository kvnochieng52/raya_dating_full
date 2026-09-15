<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Kingdom Dating')</title>
    <meta name="description" content="@yield('description', 'Kingdom Dating — faith-first Christian dating.')">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body {
            margin: 0;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            font-size: 16px;
            line-height: 1.6;
            color: #2c2c2c;
            background: #fff;
            -webkit-font-smoothing: antialiased;
        }
        a { color: #C0392B; text-decoration: none; }
        a:hover { text-decoration: underline; }

        /* ── Header / Nav (matches landing page) ───────────────── */
        .site-header {
            position: sticky;
            top: 0;
            z-index: 50;
            background: rgba(255,255,255,.95);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(0,0,0,.06);
        }
        .nav {
            max-width: 1200px;
            margin: 0 auto;
            padding: 16px 24px;
            display: flex;
            align-items: center;
            gap: 32px;
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
            font-family: 'Playfair Display', serif;
            font-weight: 700;
            font-size: 22px;
            color: #C0392B;
            letter-spacing: -.01em;
        }
        .brand:hover { text-decoration: none; }
        .brand svg { flex-shrink: 0; }
        .nav-links {
            margin-left: auto;
            display: flex;
            gap: 28px;
            align-items: center;
        }
        .nav-links a {
            color: #333;
            font-size: 14px;
            font-weight: 700;
        }
        .nav-links a:hover { color: #C0392B; text-decoration: none; }
        .nav-cta {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #C0392B;
            color: #fff !important;
            padding: 8px 18px;
            border-radius: 999px;
            font-weight: 700 !important;
        }
        .nav-cta:hover { background: #a93226; text-decoration: none; }
        .nav-cta svg { flex-shrink: 0; }

        /* ── Main content ──────────────────────────────────────── */
        main {
            max-width: 800px;
            margin: 0 auto;
            padding: 60px 24px 80px;
            min-height: calc(100vh - 400px);
        }
        h1 {
            font-family: 'Playfair Display', serif;
            color: #1a1a1a;
            font-size: 42px;
            font-weight: 700;
            margin: 0 0 10px;
            letter-spacing: -.02em;
        }
        h2 {
            font-family: 'Playfair Display', serif;
            color: #1a1a1a;
            font-size: 24px;
            font-weight: 700;
            margin: 40px 0 14px;
        }
        p, ul, ol { margin: 0 0 16px; }
        ul, ol { padding-left: 24px; }
        li { margin-bottom: 6px; }
        .updated { color: #888; font-size: 14px; margin-bottom: 32px; }
        .contact-block {
            background: #fdf5f4;
            border-left: 4px solid #C0392B;
            padding: 16px 20px;
            margin: 24px 0;
            border-radius: 4px;
        }
        .contact-block strong { display: inline-block; min-width: 80px; }

        /* ── Contact form ──────────────────────────────────────── */
        .contact-form { margin: 0 0 40px; }
        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            font-weight: 700;
            font-size: 14px;
            margin-bottom: 6px;
            color: #2c2c2c;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 15px;
            font-family: inherit;
            color: #2c2c2c;
            background: #fff;
            transition: border-color .15s;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #C0392B;
            box-shadow: 0 0 0 3px rgba(192,57,43,.12);
        }
        .form-group textarea { resize: vertical; min-height: 130px; }
        .btn-submit {
            background: #C0392B;
            color: #fff;
            border: none;
            padding: 12px 28px;
            border-radius: 999px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: background .15s;
        }
        .btn-submit:hover { background: #a93226; }
        .alert-success {
            background: #eafaf1;
            border-left: 4px solid #27ae60;
            padding: 14px 18px;
            border-radius: 4px;
            margin-bottom: 24px;
            color: #1e8449;
            font-weight: 500;
        }
        .alert-error {
            background: #fdf2f2;
            border-left: 4px solid #C0392B;
            padding: 14px 18px;
            border-radius: 4px;
            margin-bottom: 24px;
            color: #922b21;
        }

        /* ── Footer (matches landing page) ─────────────────────── */
        footer {
            background: #1a1a1a;
            color: rgba(255,255,255,.7);
            padding: 60px 24px 30px;
            font-size: 14px;
        }
        footer a { color: rgba(255,255,255,.7); }
        footer a:hover { color: #fff; text-decoration: none; }
        .footer-inner {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1.5fr 1fr 1fr;
            gap: 40px;
        }
        .footer-brand {
            font-family: 'Playfair Display', serif;
            font-weight: 700;
            font-size: 22px;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
        }
        .footer-tag { max-width: 320px; margin: 0; }
        footer h5 {
            color: #fff;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: .08em;
            margin: 0 0 16px;
        }
        footer ul { list-style: none; padding: 0; margin: 0; }
        footer li { margin-bottom: 10px; }
        .footer-bottom {
            max-width: 1200px;
            margin: 40px auto 0;
            padding-top: 24px;
            border-top: 1px solid rgba(255,255,255,.1);
            text-align: center;
            color: rgba(255,255,255,.5);
            font-size: 13px;
        }

        /* ── Responsive ────────────────────────────────────────── */
        @media (max-width: 900px) {
            .footer-inner { grid-template-columns: 1fr; }
            .nav-links a:not(.nav-cta) { display: none; }
        }
        @media (max-width: 600px) {
            h1 { font-size: 30px; }
            main { padding: 40px 24px 60px; }
        }
    </style>
</head>
<body>

    {{-- ── HEADER ────────────────────────────────────────────── --}}
    <header class="site-header">
        <div class="nav">
            <a href="{{ url('/') }}" class="brand">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="#C0392B">
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>
                Kingdom Dating
            </a>
            <div class="nav-links">
                <a href="{{ url('/') }}">Home</a>
                <a href="{{ url('/about') }}">About</a>
                <a href="{{ url('/therapy') }}">Counselling</a>
                <a href="{{ url('/safety') }}">Safety</a>
                <a href="{{ url('/contact') }}">Contact</a>
                <a href="https://play.google.com/store/apps/details?id=com.kingdomdating.app" class="nav-cta" target="_blank" rel="noopener">
                    <svg width="16" height="18" viewBox="0 0 512 512">
                        <path d="M99.6 12.4c-8.2 4.7-13.6 13.7-13.6 24v439.2c0 10.3 5.4 19.3 13.6 24l219.7-243.6L99.6 12.4z" fill="#EA4335"/>
                        <path d="M366.6 165.1L282 213.1l30.2 33.5-30.2 33.5 84.6 48c9.9-8.4 15.8-20.9 15.8-33.5V198.6c0-12.6-5.9-25.1-15.8-33.5z" fill="#FBBC04"/>
                        <path d="M99.6 12.4l219.7 243.6L282 213.1l84.6-48-267-152.7z" fill="#34A853"/>
                        <path d="M99.6 499.6l267-152.7-84.6-48-37.3 42.9L99.6 499.6z" fill="#4285F4"/>
                    </svg>
                    Get the app
                </a>
            </div>
        </div>
    </header>

    {{-- ── MAIN CONTENT ─────────────────────────────────────── --}}
    <main>
        @yield('content')
    </main>

    {{-- ── FOOTER ───────────────────────────────────────────── --}}
    <footer>
        <div class="footer-inner">
            <div>
                <div class="footer-brand">
                    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="#C0392B">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                    </svg>
                    Kingdom Dating
                </div>
                <p class="footer-tag">A faith-first dating app for single Christians ready to meet a partner who shares their walk with Christ.</p>
            </div>
            <div>
                <h5>Product</h5>
                <ul>
                    <li><a href="{{ url('/') }}#features">Features</a></li>
                    <li><a href="{{ url('/') }}#how">How it works</a></li>
                    <li><a href="https://play.google.com/store/apps/details?id=com.kingdomdating.app" target="_blank" rel="noopener">Google Play</a></li>
                </ul>
            </div>
            <div>
                <h5>Company</h5>
                <ul>
                    <li><a href="{{ url('/about') }}">About us</a></li>
                    <li><a href="{{ url('/therapy') }}">Counselling</a></li>
                    <li><a href="{{ url('/safety') }}">Safety standards</a></li>
                    <li><a href="{{ url('/privacy') }}">Privacy policy</a></li>
                    <li><a href="{{ url('/contact') }}">Contact us</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            &copy; {{ date('Y') }} Kingdom Dating. All rights reserved.
        </div>
    </footer>

</body>
</html>
