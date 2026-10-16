<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin · Kingdom Dating</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #1a1a1a 0%, #3b1a1a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }
        .card {
            width: 100%;
            max-width: 400px;
            background: #fff;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,.3);
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
            font-family: 'Playfair Display', serif;
            font-size: 24px;
            font-weight: 700;
            color: #C0392B;
            margin-bottom: 8px;
        }
        .brand small {
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            font-weight: 600;
            color: #888;
            background: #f0ece9;
            padding: 2px 10px;
            border-radius: 999px;
            text-transform: uppercase;
            letter-spacing: .08em;
            margin-left: auto;
        }
        p.sub { color: #666; margin: 0 0 28px; font-size: 14px; }
        label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: #333; }
        input {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            font-family: inherit;
            margin-bottom: 16px;
        }
        input:focus {
            outline: none;
            border-color: #C0392B;
            box-shadow: 0 0 0 3px rgba(192,57,43,.12);
        }
        button {
            width: 100%;
            padding: 12px;
            background: #C0392B;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            margin-top: 8px;
        }
        button:hover { background: #a93226; }
        .error {
            background: #fdecea;
            color: #a93226;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 20px;
            border-left: 3px solid #C0392B;
        }
        .remember { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #555; margin-bottom: 0; }
        .remember input { width: auto; margin: 0; }
    </style>
</head>
<body>
    <div class="card">
        <div class="brand">
            <svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 24 24" fill="#C0392B">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
            Kingdom Dating
            <small>Admin</small>
        </div>
        <p class="sub">Sign in to the admin dashboard.</p>

        @if ($errors->any())
            <div class="error">{{ $errors->first() }}</div>
        @endif

        <form method="POST" action="{{ route('admin.login.attempt') }}">
            @csrf
            <label for="email">Email</label>
            <input id="email" name="email" type="email" required autofocus value="{{ old('email') }}">

            <label for="password">Password</label>
            <input id="password" name="password" type="password" required>

            <label class="remember">
                <input type="checkbox" name="remember" value="1">
                Keep me signed in
            </label>

            <button type="submit">Sign in</button>
        </form>
    </div>
</body>
</html>
