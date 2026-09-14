@extends('layouts.public')

@section('title', 'Safety Standards — Kingdom Dating')
@section('description', 'Kingdom Dating safety standards, child protection policy, and how to report concerns.')

@section('content')
    <h1>Safety Standards</h1>
    <p class="updated">Last updated: {{ date('F j, Y') }}</p>

    <p>
        Kingdom Dating is committed to maintaining a safe, respectful, and
        faith-centred community for all users. This page sets out our safety
        standards, our zero-tolerance policy on child exploitation, and how to
        report concerns.
    </p>

    <h2>1. Age Requirement</h2>
    <p>
        Kingdom Dating is strictly for users aged <strong>18 years and older</strong>.
        We do not knowingly allow anyone under 18 to register or use the App.
        During sign-up we collect date of birth to enforce this requirement.
        If we discover that a user is under 18, their account is permanently
        removed immediately.
    </p>

    <h2>2. Child Safety &amp; Zero-Tolerance Policy</h2>
    <p>
        We have a <strong>zero-tolerance policy</strong> for child sexual abuse
        material (CSAM) and any content that sexualises, exploits, or endangers
        minors. This includes but is not limited to:
    </p>
    <ul>
        <li>Any image, video, text, or link that sexually exploits a minor.</li>
        <li>Any attempt by an adult to solicit, groom, or make contact with a
            minor for sexual purposes.</li>
        <li>Sharing, distributing, or requesting CSAM or any content involving
            the sexual exploitation of children.</li>
        <li>Misrepresenting age to gain access to the platform.</li>
    </ul>
    <p>
        Accounts found to be in violation are permanently banned and, where
        required by law, reported to the relevant national authorities and
        the <strong>National Center for Missing &amp; Exploited Children
        (NCMEC)</strong> or the equivalent authority in the user's country.
    </p>

    <h2>3. Content Moderation</h2>
    <p>
        All profile photos submitted for verification are reviewed before
        the verified badge is awarded. We monitor reports from users and act
        on credible safety concerns within <strong>24 hours</strong>. Accounts
        under active review are suspended pending investigation.
    </p>
    <ul>
        <li>Profile photos must show a real person aged 18 or older.</li>
        <li>Nude, sexually explicit, or otherwise inappropriate content is
            prohibited and will result in immediate removal.</li>
        <li>Harassment, threats, and hate speech are prohibited.</li>
        <li>Impersonation of another person or creating fake profiles is
            prohibited.</li>
    </ul>

    <h2>4. User Verification</h2>
    <p>
        We require email verification for all accounts. An optional selfie
        verification step is available to confirm that the profile photo
        matches the account holder. Verified accounts display a badge so
        other users can identify them.
    </p>

    <h2>5. Reporting a Safety Concern</h2>
    <p>
        If you encounter content or behaviour that you believe violates these
        standards — especially anything involving a minor — please report it
        immediately. You can report directly inside the App by tapping the
        flag icon on any profile or message, or contact us by email:
    </p>
    <div class="contact-block">
        <p style="margin: 0;">
            <strong>Safety &amp; abuse reports:</strong>
            <a href="mailto:kingdomdating31@gmail.com?subject=Safety%20report">kingdomdating31@gmail.com</a>
        </p>
        <p style="margin: 12px 0 0;">
            <strong>Child safety concerns:</strong>
            <a href="mailto:kingdomdating31@gmail.com?subject=Child%20safety%20concern">kingdomdating31@gmail.com</a>
        </p>
    </div>
    <p>
        Safety reports are treated as the highest priority and are reviewed
        the same day they are received, including weekends and public holidays.
    </p>
    <p>
        If you believe a child is in immediate danger, contact your local
        emergency services first.
    </p>

    <h2>6. External Reporting Resources</h2>
    <p>
        In addition to reporting to us, you may report child sexual abuse
        material or exploitation to the following organisations:
    </p>
    <ul>
        <li>
            <strong>Kenya:</strong> Directorate of Criminal Investigations (DCI)
            cyber-crime unit — <a href="https://www.dci.go.ke" target="_blank" rel="noopener">dci.go.ke</a>
        </li>
        <li>
            <strong>Global:</strong> National Center for Missing &amp; Exploited Children (NCMEC)
            CyberTipline — <a href="https://www.missingkids.org/gethelpnow/cybertipline" target="_blank" rel="noopener">missingkids.org/gethelpnow/cybertipline</a>
        </li>
        <li>
            <strong>Global:</strong> Internet Watch Foundation —
            <a href="https://www.iwf.org.uk/report" target="_blank" rel="noopener">iwf.org.uk/report</a>
        </li>
    </ul>

    <h2>7. Blocking &amp; Restricting Users</h2>
    <p>
        Every user can block another user at any time from within the App.
        Blocked users can no longer view your profile, send messages, or
        appear in your discovery feed. Blocks are immediate and permanent
        unless you choose to unblock.
    </p>

    <h2>8. Data Related to Safety Incidents</h2>
    <p>
        When a safety report is filed we retain relevant account data,
        message logs, and profile information for the period required to
        investigate the report and, where applicable, cooperate with law
        enforcement — even if the reported account has been deleted.
    </p>

    <h2>9. Contact &amp; Accountability</h2>
    <div class="contact-block">
        <p style="margin: 0;">
            Questions about these safety standards or our child protection
            policy can be directed to:
        </p>
        <p style="margin: 12px 0 0;">
            <strong>Email:</strong>
            <a href="mailto:kingdomdating31@gmail.com">kingdomdating31@gmail.com</a>
        </p>
        <p style="margin: 8px 0 0;">
            <strong>Response time:</strong> Safety matters are answered the same day.
            General enquiries within two business days.
        </p>
        <p style="margin: 8px 0 0;">
            <strong>Business hours:</strong> Monday – Friday, 9:00 AM – 5:00 PM
            East Africa Time (EAT).
        </p>
    </div>
@endsection
