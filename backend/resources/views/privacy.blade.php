@extends('layouts.public')

@section('title', 'Privacy Policy — Kingdom Dating')
@section('description', 'How Kingdom Dating collects, uses, and protects your personal information.')

@section('content')
    <h1>Privacy Policy</h1>
    <p class="updated">Last updated: {{ date('F j, Y') }}</p>

    <p>
        This Privacy Policy describes how Kingdom Dating ("we", "us", or "our")
        collects, uses, and shares information when you use the Kingdom Dating
        mobile application (the "App"). By using the App, you agree to the
        collection and use of information in accordance with this policy.
    </p>

    <h2>1. Information We Collect</h2>
    <p>We collect the following categories of information:</p>
    <ul>
        <li>
            <strong>Account information</strong> you provide during sign-up:
            name, email address, phone number (optional), and password.
        </li>
        <li>
            <strong>Profile information</strong> you choose to add: date of
            birth, gender, photos, bio, denomination, marital status, education,
            occupation, interests, and relationship preferences.
        </li>
        <li>
            <strong>Verification data</strong>: a verification code sent to your
            email and, optionally, a selfie used solely to confirm your identity.
        </li>
        <li>
            <strong>Activity data</strong>: likes, matches, and messages you
            exchange with other users through the App.
        </li>
        <li>
            <strong>Device and log data</strong>: IP address, device type,
            operating system version, and app crash logs collected automatically
            when you use the App.
        </li>
    </ul>

    <h2>2. Photos and Media</h2>
    <p>
        The App requests permission to access photos on your device so you can
        select images for your profile and verification selfie. The App only
        reads images you explicitly pick using the system photo picker. We do
        not scan, index, or upload any other content from your photo library.
    </p>

    <h2>3. How We Use Your Information</h2>
    <ul>
        <li>To create and manage your account and profile.</li>
        <li>To show you potential matches and enable connections with other users.</li>
        <li>To deliver messages between matched users.</li>
        <li>To verify your identity and prevent fraud, abuse, or unsafe behaviour.</li>
        <li>To improve the App and diagnose technical issues.</li>
        <li>To communicate with you about your account, updates, and support.</li>
    </ul>

    <h2>4. Information We Share</h2>
    <p>We share limited information in the following circumstances:</p>
    <ul>
        <li>
            <strong>With other users</strong>: profile details you choose to
            display (nickname, photos, age, bio, interests, etc.) are visible to
            other users of the App as part of the discovery and matching feature.
        </li>
        <li>
            <strong>With service providers</strong> who help us operate the App
            (for example, hosting and email delivery). These providers only
            access data as needed to perform their services.
        </li>
        <li>
            <strong>For legal reasons</strong>: to comply with lawful requests
            or protect the rights, safety, and property of Kingdom Dating and
            its users.
        </li>
    </ul>
    <p>
        We do <strong>not</strong> sell your personal information to third
        parties.
    </p>

    <h2>5. Data Retention</h2>
    <p>
        We retain your account information for as long as your account is active.
        You may delete your account at any time by contacting us. When you
        delete your account, we remove your profile from public view and delete
        or anonymise your personal information within a reasonable period,
        except where retention is required by law.
    </p>

    <h2>6. Security</h2>
    <p>
        We use industry-standard measures — including encrypted transport (HTTPS)
        and hashed password storage — to protect your information. No method of
        transmission over the Internet is 100% secure, and we cannot guarantee
        absolute security.
    </p>

    <h2>7. Children</h2>
    <p>
        Kingdom Dating is intended for users aged 18 and older. We do not
        knowingly collect personal information from anyone under 18. If you
        believe a minor has provided us with personal information, please
        contact us and we will delete it promptly.
    </p>

    <h2>8. Your Rights</h2>
    <p>You may:</p>
    <ul>
        <li>Access, update, or correct the information in your profile from within the App.</li>
        <li>Request a copy of the personal information we hold about you.</li>
        <li>Request deletion of your account and personal information.</li>
        <li>Withdraw consent for optional features (such as photo verification) at any time.</li>
    </ul>
    <p>
        To exercise any of these rights, contact us at the address below.
    </p>

    <h2>9. Changes to This Policy</h2>
    <p>
        We may update this Privacy Policy from time to time. When we do, we will
        revise the "Last updated" date at the top of this page. Significant
        changes will be communicated through the App.
    </p>

    <h2>10. Contact Us</h2>
    <div class="contact-block">
        <p style="margin: 0;">
            If you have questions about this Privacy Policy or how your data is
            handled, contact us:
        </p>
        <p style="margin: 12px 0 0;">
            <strong>Email:</strong> <a href="mailto:dev@ke.wananchi.com">dev@ke.wananchi.com</a>
        </p>
    </div>
@endsection
