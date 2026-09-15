<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kingdom Dating — Faith-first Christian Dating</title>
    <meta name="description" content="Kingdom Dating is a faith-first dating app for single Christians who want to meet a partner who shares their values. Download free on Google Play.">
    <meta property="og:title" content="Kingdom Dating">
    <meta property="og:description" content="Meet single Christians who share your faith. Free on Google Play.">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://kingdom-dating.co.ke">
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
        img { max-width: 100%; display: block; }
        a { color: #C0392B; text-decoration: none; }

        /* ── Header / Nav ─────────────────────────────────────── */
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
        .brand svg { flex-shrink: 0; }
        .nav-links {
            margin-left: auto;
            display: flex;
            gap: 28px;
            align-items: center;
        }
        .nav-links a {
            color: #555;
            font-size: 14px;
            font-weight: 500;
        }
        .nav-links a:hover { color: #C0392B; }
        .nav-cta {
            background: #C0392B;
            color: #fff !important;
            padding: 8px 18px;
            border-radius: 999px;
            font-weight: 600 !important;
        }
        .nav-cta:hover { background: #a93226; }

        /* ── Hero ──────────────────────────────────────────────── */
        .hero {
            position: relative;
            overflow: hidden;
            padding: 80px 24px 100px;
            background:
                radial-gradient(ellipse at top left, rgba(192,57,43,.08), transparent 55%),
                radial-gradient(ellipse at bottom right, rgba(231,76,60,.08), transparent 55%),
                linear-gradient(180deg, #fffaf9 0%, #fff 100%);
        }
        .hero-inner {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1.1fr 1fr;
            gap: 60px;
            align-items: center;
        }
        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(192,57,43,.08);
            color: #C0392B;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 24px;
        }
        .eyebrow-dot { width: 6px; height: 6px; border-radius: 50%; background: #C0392B; }
        .hero h1 {
            font-family: 'Playfair Display', serif;
            font-size: clamp(38px, 5vw, 62px);
            font-weight: 700;
            line-height: 1.05;
            margin: 0 0 20px;
            color: #1a1a1a;
            letter-spacing: -.02em;
        }
        .hero h1 span { color: #C0392B; font-style: italic; }
        .hero .lede {
            font-size: 19px;
            color: #4a4a4a;
            margin: 0 0 32px;
            max-width: 520px;
        }
        .hero-ctas { display: flex; gap: 16px; flex-wrap: wrap; align-items: center; }
        .btn-primary {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: #C0392B;
            color: #fff;
            padding: 14px 26px;
            border-radius: 999px;
            font-weight: 600;
            font-size: 15px;
            transition: all .2s;
            box-shadow: 0 8px 24px rgba(192,57,43,.25);
        }
        .btn-primary:hover { background: #a93226; transform: translateY(-1px); box-shadow: 0 12px 28px rgba(192,57,43,.35); }

        .play-badge {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            background: #000;
            color: #fff;
            padding: 10px 22px;
            border-radius: 12px;
            transition: all .2s;
        }
        .play-badge:hover { background: #1a1a1a; transform: translateY(-1px); }
        .play-badge .row1 { font-size: 11px; color: #ccc; line-height: 1; }
        .play-badge .row2 { font-size: 18px; font-weight: 600; line-height: 1.2; margin-top: 2px; }

        .hero-social {
            display: flex;
            gap: 24px;
            margin-top: 36px;
            font-size: 14px;
            color: #666;
            flex-wrap: wrap;
        }
        .hero-social strong { color: #1a1a1a; }

        /* ── Phone mockup ──────────────────────────────────────── */
        .phone-wrap { position: relative; display: flex; justify-content: center; }
        .phone {
            position: relative;
            width: 360px;
            height: 740px;
            background: #111;
            border-radius: 52px;
            padding: 14px;
            box-shadow: 0 40px 80px rgba(192,57,43,.15), 0 20px 40px rgba(0,0,0,.15);
            transform: rotate(-3deg);
        }
        .phone-screen {
            width: 100%;
            height: 100%;
            background: linear-gradient(180deg, #C0392B, #7B1F16);
            border-radius: 32px;
            overflow: hidden;
            position: relative;
            color: #fff;
        }
        .phone-notch {
            position: absolute;
            top: 12px;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 26px;
            background: #111;
            border-radius: 14px;
            z-index: 2;
        }
        .phone-card {
            position: absolute;
            top: 60px;
            left: 20px;
            right: 20px;
            bottom: 100px;
            background: rgba(255,255,255,.15);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            border: 1px solid rgba(255,255,255,.2);
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            overflow: hidden;
        }
        .phone-card .avatar {
            position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background: url('{{ asset('images/hero-main.jpg') }}') center/cover no-repeat;
            filter: brightness(.9);
        }
        .phone-card .avatar::after {
            content: '';
            position: absolute; inset: 0;
            background: linear-gradient(180deg, transparent 40%, rgba(0,0,0,.75) 100%);
        }
        .phone-card .info { position: relative; z-index: 1; }
        .phone-card .info h3 {
            margin: 0;
            font-family: 'Playfair Display', serif;
            font-size: 24px;
            font-weight: 700;
        }
        .phone-card .info p { margin: 4px 0 0; font-size: 13px; opacity: .95; }
        .phone-actions {
            position: absolute;
            bottom: 32px;
            left: 0; right: 0;
            display: flex;
            justify-content: center;
            gap: 18px;
        }
        .phone-btn {
            width: 54px; height: 54px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            background: #fff;
            box-shadow: 0 4px 12px rgba(0,0,0,.2);
            color: #C0392B;
        }
        .phone-btn.small { width: 42px; height: 42px; }
        .phone-btn.dislike { color: #888; }

        .floating-badge {
            position: absolute;
            z-index: 5;
            background: #fff;
            padding: 14px 18px;
            border-radius: 14px;
            box-shadow: 0 12px 32px rgba(0,0,0,.15);
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 13px;
            font-weight: 500;
        }
        .fb-match { top: 40px; left: 0; transform: rotate(-5deg); }
        .fb-match .icon {
            width: 34px; height: 34px;
            border-radius: 50%;
            background: #C0392B; color: #fff;
            display: flex; align-items: center; justify-content: center;
        }
        .fb-msg { bottom: 80px; right: 0; transform: rotate(4deg); max-width: 220px; }
        .fb-msg .msg-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            background: url('{{ asset('images/hero-sarah.jpg') }}') center/cover no-repeat;
            flex-shrink: 0;
        }
        .fb-msg .msg-text strong { display: block; color: #1a1a1a; margin-bottom: 2px; }
        .fb-msg .msg-text span { color: #666; font-weight: 400; font-size: 12px; }

        /* ── Section base ──────────────────────────────────────── */
        section { padding: 100px 24px; }
        .section-inner { max-width: 1200px; margin: 0 auto; }
        .section-header { text-align: center; max-width: 700px; margin: 0 auto 60px; }
        .section-header .eyebrow { margin-bottom: 16px; }
        .section-header h2 {
            font-family: 'Playfair Display', serif;
            font-size: clamp(30px, 4vw, 44px);
            font-weight: 700;
            margin: 0 0 16px;
            color: #1a1a1a;
            letter-spacing: -.02em;
            line-height: 1.15;
        }
        .section-header p { font-size: 18px; color: #555; margin: 0; }

        /* ── Features ──────────────────────────────────────────── */
        .features { background: #fafafa; }
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 32px;
        }
        .feature {
            background: #fff;
            padding: 36px 28px;
            border-radius: 20px;
            border: 1px solid rgba(0,0,0,.05);
            transition: all .25s;
        }
        .feature:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(192,57,43,.08);
            border-color: rgba(192,57,43,.2);
        }
        .feature-icon {
            width: 52px; height: 52px;
            border-radius: 14px;
            background: rgba(192,57,43,.1);
            color: #C0392B;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 20px;
        }
        .feature h3 {
            font-family: 'Playfair Display', serif;
            font-size: 22px;
            font-weight: 700;
            margin: 0 0 10px;
            color: #1a1a1a;
        }
        .feature p { margin: 0; color: #555; font-size: 15px; }

        /* ── How it works ──────────────────────────────────────── */
        .steps {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 40px;
            counter-reset: step;
        }
        .step { text-align: center; position: relative; }
        .step::before {
            counter-increment: step;
            content: counter(step);
            display: inline-flex;
            align-items: center; justify-content: center;
            width: 60px; height: 60px;
            background: linear-gradient(135deg, #C0392B, #E74C3C);
            color: #fff;
            border-radius: 50%;
            font-family: 'Playfair Display', serif;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 20px;
            box-shadow: 0 8px 20px rgba(192,57,43,.25);
        }
        .step h3 {
            font-family: 'Playfair Display', serif;
            font-size: 22px;
            font-weight: 700;
            margin: 0 0 10px;
            color: #1a1a1a;
        }
        .step p { margin: 0; color: #555; font-size: 15px; }

        /* ── Values ────────────────────────────────────────────── */
        .values {
            background: linear-gradient(135deg, #C0392B 0%, #7B1F16 100%);
            color: #fff;
        }
        .values .section-header h2 { color: #fff; }
        .values .section-header p { color: rgba(255,255,255,.85); }
        .values .eyebrow { background: rgba(255,255,255,.15); color: #fff; }
        .values .eyebrow-dot { background: #fff; }
        .value-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 24px;
        }
        .value {
            display: flex;
            gap: 20px;
            align-items: flex-start;
            padding: 24px;
            background: rgba(255,255,255,.08);
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,.12);
        }
        .value-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            background: rgba(255,255,255,.2);
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .value h4 {
            font-family: 'Playfair Display', serif;
            font-size: 19px;
            font-weight: 700;
            margin: 0 0 6px;
            color: #fff;
        }
        .value p { margin: 0; font-size: 14px; color: rgba(255,255,255,.85); }

        /* ── Download CTA ──────────────────────────────────────── */
        .download { text-align: center; }
        .download .section-header { margin-bottom: 40px; }
        .download-ctas {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 30px;
        }
        .verse {
            font-family: 'Playfair Display', serif;
            font-style: italic;
            font-size: 20px;
            color: #C0392B;
            max-width: 600px;
            margin: 40px auto 0;
            line-height: 1.5;
        }
        .verse-ref {
            display: block;
            margin-top: 12px;
            font-size: 14px;
            color: #888;
            font-style: normal;
            font-family: 'Inter', sans-serif;
            letter-spacing: .05em;
            text-transform: uppercase;
        }

        /* ── Footer ────────────────────────────────────────────── */
        footer {
            background: #1a1a1a;
            color: rgba(255,255,255,.7);
            padding: 60px 24px 30px;
            font-size: 14px;
        }
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
        footer a { color: rgba(255,255,255,.7); }
        footer a:hover { color: #fff; }
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
            .hero-inner, .feature-grid, .steps, .value-grid, .footer-inner {
                grid-template-columns: 1fr;
            }
            .hero { padding: 60px 24px 80px; }
            .phone-wrap { margin-top: 40px; }
            .phone { transform: rotate(0); }
            .fb-match, .fb-msg { display: none; }
            section { padding: 70px 24px; }
            .nav-links a:not(.nav-cta) { display: none; }
        }
        @media (max-width: 500px) {
            .hero-ctas { flex-direction: column; align-items: stretch; }
            .btn-primary, .play-badge { justify-content: center; }
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
                <a href="#features">Features</a>
                <a href="#how">How it works</a>
                <a href="{{ url('/safety') }}">Safety</a>
                <a href="{{ url('/contact') }}">Contact</a>
                <a href="https://play.google.com/store/apps/details?id=com.kingdomdating.app" class="nav-cta">Get the app</a>
            </div>
        </div>
    </header>

    {{-- ── HERO ──────────────────────────────────────────────── --}}
    <section class="hero">
        <div class="hero-inner">
            <div>
                <div class="eyebrow">
                    <span class="eyebrow-dot"></span>
                    Free on Google Play
                </div>
                <h1>Faith first.<br><span>Love follows.</span></h1>
                <p class="lede">
                    Kingdom Dating is a dating app built for single Christians who want
                    to meet someone who shares their faith, values, and vision for the future.
                </p>
                <div class="hero-ctas">
                    <a href="https://play.google.com/store/apps/details?id=com.kingdomdating.app" class="play-badge" target="_blank" rel="noopener">
                        <svg width="26" height="28" viewBox="0 0 512 512">
                            <path d="M99.6 12.4c-8.2 4.7-13.6 13.7-13.6 24v439.2c0 10.3 5.4 19.3 13.6 24l219.7-243.6L99.6 12.4z" fill="#EA4335"/>
                            <path d="M366.6 165.1L282 213.1l30.2 33.5-30.2 33.5 84.6 48c9.9-8.4 15.8-20.9 15.8-33.5V198.6c0-12.6-5.9-25.1-15.8-33.5z" fill="#FBBC04"/>
                            <path d="M99.6 12.4l219.7 243.6L282 213.1l84.6-48-267-152.7z" fill="#34A853"/>
                            <path d="M99.6 499.6l267-152.7-84.6-48-37.3 42.9L99.6 499.6z" fill="#4285F4"/>
                        </svg>
                        <div>
                            <div class="row1">GET IT ON</div>
                            <div class="row2">Google Play</div>
                        </div>
                    </a>
                    <a href="#features" class="btn-primary">
                        Explore features
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                            <path d="M5 12h14M13 5l7 7-7 7"/>
                        </svg>
                    </a>
                </div>
                <div class="hero-social">
                    <div>⭐️⭐️⭐️⭐️⭐️ &nbsp;<strong>Highly rated</strong></div>
                    <div><strong>18+</strong> only • verified profiles</div>
                </div>
            </div>

            <div class="phone-wrap">
                <div class="floating-badge fb-match">
                    <div class="icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                        </svg>
                    </div>
                    It's a match!
                </div>
                <div class="floating-badge fb-msg">
                    <div class="msg-avatar"></div>
                    <div class="msg-text">
                        <strong>Sarah</strong>
                        <span>Coffee Sunday? 🙌</span>
                    </div>
                </div>
                <div class="phone">
                    <div class="phone-screen">
                        <div class="phone-notch"></div>
                        <div class="phone-card">
                            <div class="avatar"></div>
                            <div class="info">
                                <h3>Sarah, 27</h3>
                                <p>Non-denominational · Nairobi</p>
                                <p style="margin-top:8px;">"Every love story begins with prayer."</p>
                            </div>
                        </div>
                        <div class="phone-actions">
                            <div class="phone-btn small dislike">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                                    <path d="M18 6L6 18M6 6l12 12"/>
                                </svg>
                            </div>
                            <div class="phone-btn">
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                                </svg>
                            </div>
                            <div class="phone-btn small" style="color:#f39c12;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                                </svg>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ── FEATURES ─────────────────────────────────────────── --}}
    <section class="features" id="features">
        <div class="section-inner">
            <div class="section-header">
                <div class="eyebrow"><span class="eyebrow-dot"></span> Features</div>
                <h2>Built for Christ-centred connection.</h2>
                <p>Everything you need to meet the right person — and nothing you don't.</p>
            </div>
            <div class="feature-grid">
                <div class="feature">
                    <div class="feature-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                        </svg>
                    </div>
                    <h3>Shared faith</h3>
                    <p>Filter by denomination, spiritual journey, and relationship goals so every match starts on common ground.</p>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"/>
                            <path d="M9 12l2 2 4-4"/>
                        </svg>
                    </div>
                    <h3>Verified profiles</h3>
                    <p>Email and optional selfie verification mean the person on the other side of the screen is exactly who they say they are.</p>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                        </svg>
                    </div>
                    <h3>Real conversations</h3>
                    <p>Chat unlocks only after a mutual match. No spam, no unsolicited messages — just meaningful conversations.</p>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                    </div>
                    <h3>Purpose-driven matching</h3>
                    <p>Tell us whether you're seeking friendship, dating, or marriage — and match with people who want the same.</p>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </div>
                    <h3>Safe by design</h3>
                    <p>Block, report, and control your visibility. Our moderation team responds to safety concerns the same day.</p>
                </div>
                <div class="feature">
                    <div class="feature-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 2v20M2 12h20"/>
                        </svg>
                    </div>
                    <h3>Christian counselling</h3>
                    <p>Request a session with a trained Christian counsellor when your relationship needs a wise, prayerful voice.</p>
                </div>
            </div>
        </div>
    </section>

    {{-- ── HOW IT WORKS ─────────────────────────────────────── --}}
    <section id="how">
        <div class="section-inner">
            <div class="section-header">
                <div class="eyebrow"><span class="eyebrow-dot"></span> How it works</div>
                <h2>Three steps to your next chapter.</h2>
                <p>No games, no gimmicks. Just an honest way to meet the right person.</p>
            </div>
            <div class="steps">
                <div class="step">
                    <h3>Create your profile</h3>
                    <p>Sign up in minutes. Add photos, share your faith journey, and tell us what matters most to you.</p>
                </div>
                <div class="step">
                    <h3>Discover &amp; connect</h3>
                    <p>Browse profiles filtered by your preferences. Like the ones who catch your heart — when they like you back, you match.</p>
                </div>
                <div class="step">
                    <h3>Start a real conversation</h3>
                    <p>Chat freely once you match. Pray, laugh, learn about each other — and see where God takes it.</p>
                </div>
            </div>
        </div>
    </section>

    {{-- ── VALUES ────────────────────────────────────────────── --}}
    <section class="values">
        <div class="section-inner">
            <div class="section-header">
                <div class="eyebrow"><span class="eyebrow-dot"></span> Our values</div>
                <h2>A community you can trust.</h2>
                <p>We believe love deserves better than an algorithm. Here's what makes Kingdom Dating different.</p>
            </div>
            <div class="value-grid">
                <div class="value">
                    <div class="value-icon">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                        </svg>
                    </div>
                    <div>
                        <h4>Faith is the foundation</h4>
                        <p>Every profile is built around what you believe, not just what you look like.</p>
                    </div>
                </div>
                <div class="value">
                    <div class="value-icon">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                        </svg>
                    </div>
                    <div>
                        <h4>Intentional, not endless</h4>
                        <p>We help you find one meaningful connection, not doom-scroll through a thousand.</p>
                    </div>
                </div>
                <div class="value">
                    <div class="value-icon">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14M22 4L12 14.01l-3-3"/>
                        </svg>
                    </div>
                    <div>
                        <h4>Real people, verified</h4>
                        <p>Selfie verification and manual review keep the community authentic and safe.</p>
                    </div>
                </div>
                <div class="value">
                    <div class="value-icon">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M18 8h1a4 4 0 0 1 0 8h-1M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8zM6 1v3M10 1v3M14 1v3"/>
                        </svg>
                    </div>
                    <div>
                        <h4>Christ-centred community</h4>
                        <p>Discussion topics, prayer requests, and counselling — dating rooted in something bigger than an app.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ── DOWNLOAD CTA ─────────────────────────────────────── --}}
    <section class="download">
        <div class="section-inner">
            <div class="section-header">
                <div class="eyebrow"><span class="eyebrow-dot"></span> Get started</div>
                <h2>Your story could start today.</h2>
                <p>Download Kingdom Dating free on Google Play and take the first step towards a Christ-centred relationship.</p>
            </div>
            <div class="download-ctas">
                <a href="https://play.google.com/store/apps/details?id=com.kingdomdating.app" class="play-badge" target="_blank" rel="noopener">
                    <svg width="26" height="28" viewBox="0 0 512 512">
                        <path d="M99.6 12.4c-8.2 4.7-13.6 13.7-13.6 24v439.2c0 10.3 5.4 19.3 13.6 24l219.7-243.6L99.6 12.4z" fill="#EA4335"/>
                        <path d="M366.6 165.1L282 213.1l30.2 33.5-30.2 33.5 84.6 48c9.9-8.4 15.8-20.9 15.8-33.5V198.6c0-12.6-5.9-25.1-15.8-33.5z" fill="#FBBC04"/>
                        <path d="M99.6 12.4l219.7 243.6L282 213.1l84.6-48-267-152.7z" fill="#34A853"/>
                        <path d="M99.6 499.6l267-152.7-84.6-48-37.3 42.9L99.6 499.6z" fill="#4285F4"/>
                    </svg>
                    <div>
                        <div class="row1">GET IT ON</div>
                        <div class="row2">Google Play</div>
                    </div>
                </a>
            </div>
            <div class="verse">
                "Above all else, guard your heart, for everything you do flows from it."
                <span class="verse-ref">Proverbs 4:23</span>
            </div>
        </div>
    </section>

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
                    <li><a href="#features">Features</a></li>
                    <li><a href="#how">How it works</a></li>
                    <li><a href="https://play.google.com/store/apps/details?id=com.kingdomdating.app" target="_blank" rel="noopener">Google Play</a></li>
                </ul>
            </div>
            <div>
                <h5>Company</h5>
                <ul>
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
