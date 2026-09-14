@extends('layouts.public')

@section('title', 'Contact — Kingdom Dating')
@section('description', 'Get in touch with the Kingdom Dating team.')

@section('content')
    <h1>Contact Us</h1>
    <p class="updated">We would love to hear from you.</p>

    <p>
        Whether you have a question about your account, feedback on the App, a
        safety concern to report, or a partnership idea to share — reach out and
        our team will get back to you.
    </p>

    <h2>Send us a message</h2>

    @if(session('success'))
        <div class="alert-success">
            {{ session('success') }}
        </div>
    @endif

    @if($errors->any())
        <div class="alert-error">
            <ul style="margin: 0; padding-left: 20px;">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ route('contact.send') }}" class="contact-form">
        @csrf
        <div class="form-group">
            <label for="name">Your name</label>
            <input type="text" id="name" name="name" value="{{ old('name') }}"
                   placeholder="Jane Doe" required maxlength="100">
        </div>
        <div class="form-group">
            <label for="email">Your email</label>
            <input type="email" id="email" name="email" value="{{ old('email') }}"
                   placeholder="jane@example.com" required maxlength="200">
        </div>
        <div class="form-group">
            <label for="subject">Subject</label>
            <select id="subject" name="subject" required>
                <option value="" disabled {{ old('subject') ? '' : 'selected' }}>Select a topic…</option>
                <option value="General enquiry"        {{ old('subject') === 'General enquiry'        ? 'selected' : '' }}>General enquiry</option>
                <option value="Account issue"          {{ old('subject') === 'Account issue'          ? 'selected' : '' }}>Account issue</option>
                <option value="Safety or abuse report" {{ old('subject') === 'Safety or abuse report' ? 'selected' : '' }}>Safety or abuse report</option>
                <option value="Privacy request"        {{ old('subject') === 'Privacy request'        ? 'selected' : '' }}>Privacy request</option>
                <option value="Partnership"            {{ old('subject') === 'Partnership'            ? 'selected' : '' }}>Partnership</option>
                <option value="Other"                  {{ old('subject') === 'Other'                  ? 'selected' : '' }}>Other</option>
            </select>
        </div>
        <div class="form-group">
            <label for="message">Message</label>
            <textarea id="message" name="message" rows="6"
                      placeholder="Describe your question or issue…" required maxlength="3000">{{ old('message') }}</textarea>
        </div>
        <button type="submit" class="btn-submit">Send message</button>
    </form>

    <h2>Email us directly</h2>
    <div class="contact-block">
        <p style="margin: 0;">
            <strong>General:</strong>
            <a href="mailto:kingdomdating31@gmail.com">kingdomdating31@gmail.com</a>
        </p>
        <p style="margin: 12px 0 0;">
            <strong>Safety &amp; abuse reports:</strong>
            <a href="mailto:kingdomdating31@gmail.com?subject=Safety%20report">kingdomdating31@gmail.com</a>
        </p>
        <p style="margin: 12px 0 0;">
            <strong>Privacy requests:</strong>
            <a href="mailto:kingdomdating31@gmail.com?subject=Privacy%20request">kingdomdating31@gmail.com</a>
        </p>
    </div>

    <h2>Response times</h2>
    <p>
        We aim to respond to every message within two business days. Safety and
        abuse reports are prioritised and typically answered the same day.
    </p>

    <h2>Before you write</h2>
    <p>
        If you are having trouble with the App, please include:
    </p>
    <ul>
        <li>The email address on your Kingdom Dating account.</li>
        <li>Your device model and operating system version.</li>
        <li>A short description of what you were trying to do when the issue occurred.</li>
        <li>Screenshots if possible.</li>
    </ul>

    <h2>Business hours</h2>
    <p>
        Monday to Friday, 9:00 AM to 5:00 PM East Africa Time (EAT).
    </p>
@endsection
