@extends('layouts.public')

@section('title', 'About Us — Kingdom Dating')
@section('description', 'Kingdom Dating exists to help single Christians meet a partner who shares their faith and values.')

@section('content')
    <h1>About Us</h1>
    <p class="updated">Our story, our mission, and why we built Kingdom Dating.</p>

    <h2>Our story</h2>
    <p>
        Kingdom Dating was born out of a simple observation: single Christians
        looking for a serious partner often find themselves on secular apps
        having to explain, over and over again, that their faith is not
        negotiable. We wanted to build something better — a space where faith
        is the starting point, not something you hope the other person will
        eventually understand.
    </p>

    <h2>Our mission</h2>
    <p>
        To help single Christians meet a partner who shares their faith,
        values, and vision for the future — through a platform that is safe,
        respectful, and rooted in Christian community.
    </p>

    <h2>What we believe</h2>
    <ul>
        <li>
            <strong>Faith first.</strong> Every profile is built around what
            you believe, not just how you look. Real compatibility begins
            with a shared foundation.
        </li>
        <li>
            <strong>Intentional, not endless.</strong> We are not here to
            keep you scrolling. We are here to help you find one meaningful
            connection.
        </li>
        <li>
            <strong>Safety without compromise.</strong> Verified profiles,
            active moderation, and a zero-tolerance policy for abuse. Your
            safety is non-negotiable.
        </li>
        <li>
            <strong>Community over algorithm.</strong> We offer counselling,
            discussion topics, and space for real relationships — because
            dating is not a transaction.
        </li>
    </ul>

    <h2>Who we serve</h2>
    <p>
        Kingdom Dating is for single Christians aged 18 and older across
        Kenya and beyond who are ready to meet a partner intentionally.
        Whether you are looking for friendship, a serious relationship,
        or marriage — if faith is central to who you are, Kingdom Dating
        is for you.
    </p>

    <h2>Built in Kenya, for the world</h2>
    <p>
        We are a Kenyan team building for our community first — but faith
        knows no borders. Our platform is open to Christians everywhere
        who share our values and want to build something lasting.
    </p>

    <h2>Get in touch</h2>
    <div class="contact-block">
        <p style="margin: 0;">
            We would love to hear from you — questions, feedback, partnership
            ideas, or just to say hello:
        </p>
        <p style="margin: 12px 0 0;">
            <strong>Email:</strong>
            <a href="mailto:kingdomdating31@gmail.com">kingdomdating31@gmail.com</a>
        </p>
        <p style="margin: 8px 0 0;">
            <strong>Or use our</strong>
            <a href="{{ url('/contact') }}">contact form</a>.
        </p>
    </div>
@endsection
