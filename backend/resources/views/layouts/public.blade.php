<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Kingdom Dating')</title>
    <meta name="description" content="@yield('description', 'Kingdom Dating — faith-first Christian dating.')">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            font-size: 16px;
            line-height: 1.6;
            color: #2c2c2c;
            background: #fafafa;
        }
        a { color: #C0392B; text-decoration: none; }
        a:hover { text-decoration: underline; }
        header {
            background: #C0392B;
            color: #fff;
            padding: 20px 24px;
        }
        header .brand {
            max-width: 800px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        header .brand a { color: #fff; font-weight: 600; font-size: 20px; text-decoration: none; }
        header .brand a:hover { opacity: 0.9; }
        header nav { margin-left: auto; display: flex; gap: 20px; }
        header nav a { color: #fff; font-size: 14px; }
        main {
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 24px 80px;
            background: #fff;
            min-height: calc(100vh - 200px);
        }
        h1 { color: #C0392B; font-size: 32px; margin: 0 0 8px; }
        h2 { color: #2c2c2c; font-size: 20px; margin: 32px 0 12px; }
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
        footer {
            text-align: center;
            padding: 24px;
            color: #888;
            font-size: 14px;
        }
        /* Contact form */
        .contact-form { margin: 0 0 40px; }
        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            font-weight: 600;
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
            border-radius: 6px;
            font-size: 15px;
            font-weight: 600;
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
        @media (max-width: 600px) {
            h1 { font-size: 24px; }
            header .brand { flex-direction: column; align-items: flex-start; gap: 8px; }
            header nav { margin-left: 0; }
        }
    </style>
</head>
<body>
    <header>
        <div class="brand">
            <a href="{{ url('/') }}">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                     fill="#fff" style="vertical-align:middle;margin-right:6px;flex-shrink:0;">
                    <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5
                             2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09
                             C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5
                             c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>Kingdom Dating
            </a>
            <nav>
                <a href="{{ url('/safety') }}">Safety</a>
                <a href="{{ url('/privacy') }}">Privacy</a>
                <a href="{{ url('/contact') }}">Contact</a>
            </nav>
        </div>
    </header>

    <main>
        @yield('content')
    </main>

    <footer>
        &copy; {{ date('Y') }} Kingdom Dating. All rights reserved.
    </footer>
</body>
</html>
