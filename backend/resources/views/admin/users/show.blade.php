@extends('layouts.admin')
@section('title', $user->name . ' · User')

@section('content')
    <div class="page-head">
        <div>
            <a href="{{ route('admin.users.index') }}" style="font-size:13px;color:#888;">← Back to users</a>
            <h1 style="margin-top:4px;">{{ $user->name ?: 'Unnamed user' }}</h1>
            <div style="color:#666;">{{ $user->email }} · {{ $user->phone ?: 'no phone' }}</div>
        </div>
        <div style="display:flex;gap:8px;flex-wrap:wrap;">
            <form method="POST" action="{{ route('admin.users.suspend', $user) }}">
                @csrf
                <button class="btn small {{ $user->suspended_at ? '' : 'danger' }}" type="submit">
                    {{ $user->suspended_at ? 'Reinstate' : 'Suspend' }}
                </button>
            </form>
            @if ($user->id !== auth()->id())
                <form method="POST" action="{{ route('admin.users.impersonate', $user) }}">
                    @csrf
                    <button class="btn small ghost" type="submit">Impersonation token</button>
                </form>
                <form method="POST" action="{{ route('admin.users.toggleAdmin', $user) }}">
                    @csrf
                    <button class="btn small" type="submit">
                        {{ $user->is_admin ? 'Revoke admin' : 'Grant admin' }}
                    </button>
                </form>
                @if (! $user->is_admin)
                    <form method="POST" action="{{ route('admin.users.destroy', $user) }}"
                        onsubmit="return confirm('Delete this user and all of their data? This cannot be undone.');">
                        @csrf
                        @method('DELETE')
                        <button class="btn small danger" type="submit">Delete</button>
                    </form>
                @endif
            @endif
        </div>
    </div>

    @if (session('impersonation_token'))
        <div class="alert success" style="word-break:break-all;">
            <strong>Impersonation token (valid 2 hours):</strong><br>
            <code style="user-select:all;">{{ session('impersonation_token') }}</code>
            <div style="font-size:12px;margin-top:6px;">
                Use with <code>Authorization: Bearer &lt;token&gt;</code> for Sanctum endpoints. Delete when done.
            </div>
        </div>
    @endif

    <div class="stat-grid">
        <div class="stat-card">
            <div class="label">Status</div>
            <div class="value" style="font-size:18px;">
                @if ($user->suspended_at)
                    <span class="pill bad">Suspended</span>
                @elseif ($user->email_verified_at)
                    <span class="pill ok">Verified</span>
                @else
                    <span class="pill warn">Unverified</span>
                @endif
                @if ($user->is_admin) <span class="pill info">Admin</span> @endif
            </div>
            <div class="sub">Joined {{ $user->created_at->format('M j, Y') }}</div>
        </div>
        <div class="stat-card">
            <div class="label">Matches</div>
            <div class="value">{{ number_format($matchCount) }}</div>
        </div>
        <div class="stat-card">
            <div class="label">Messages sent</div>
            <div class="value">{{ number_format($messageCount) }}</div>
        </div>
        <div class="stat-card">
            <div class="label">Onboarding step</div>
            <div class="value">{{ $user->profile?->completed_step ?? '—' }}</div>
            <div class="sub">Highest completed</div>
        </div>
    </div>

    {{-- ─── Verification controls (what discovery actually gates on) ─── --}}
    <div class="panel">
        <div class="panel-head">
            <h2>Verification</h2>
            <small style="color:#888;">The discovery feed shows profiles with any of: email verified, phone verified, or selfie present.</small>
        </div>
        <div style="padding:20px;display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:16px;">

            {{-- Email --}}
            <div style="border:1px solid rgba(0,0,0,.06);border-radius:10px;padding:14px;">
                <div style="font-size:12px;text-transform:uppercase;color:#888;letter-spacing:.06em;font-weight:600;">Email</div>
                <div style="margin-top:4px;">
                    @if ($user->profile?->email_verified)
                        <span class="pill ok">Verified</span>
                    @else
                        <span class="pill warn">Not verified</span>
                    @endif
                    @if ($user->email_verified_at)
                        <small style="color:#888;margin-left:6px;">OTP: {{ $user->email_verified_at->diffForHumans() }}</small>
                    @endif
                </div>
                <div style="font-size:12px;color:#666;margin:6px 0 10px;">{{ $user->email }}</div>
                <form method="POST" action="{{ route('admin.users.verifyProfileEmail', $user) }}">
                    @csrf
                    <button type="submit" class="btn small primary">
                        {{ $user->profile?->email_verified ? 'Mark unverified' : 'Mark verified' }}
                    </button>
                </form>
            </div>

            {{-- Phone --}}
            <div style="border:1px solid rgba(0,0,0,.06);border-radius:10px;padding:14px;">
                <div style="font-size:12px;text-transform:uppercase;color:#888;letter-spacing:.06em;font-weight:600;">Phone</div>
                <div style="margin-top:4px;">
                    @if ($user->profile?->phone_verified)
                        <span class="pill ok">Verified</span>
                    @else
                        <span class="pill warn">Not verified</span>
                    @endif
                </div>
                <div style="font-size:12px;color:#666;margin:6px 0 10px;">{{ $user->profile?->verification_phone ?: $user->phone ?: 'no phone on file' }}</div>
                <form method="POST" action="{{ route('admin.users.verifyProfilePhone', $user) }}">
                    @csrf
                    <button type="submit" class="btn small primary">
                        {{ $user->profile?->phone_verified ? 'Mark unverified' : 'Mark verified' }}
                    </button>
                </form>
            </div>

            {{-- Selfie --}}
            <div style="border:1px solid rgba(0,0,0,.06);border-radius:10px;padding:14px;">
                <div style="font-size:12px;text-transform:uppercase;color:#888;letter-spacing:.06em;font-weight:600;">Selfie</div>
                <div style="margin-top:4px;">
                    @if (! $user->profile?->selfie_path)
                        <span class="pill muted">Not uploaded</span>
                    @elseif ($user->profile->selfie_verified_at)
                        <span class="pill ok">Approved</span>
                    @else
                        <span class="pill warn">Awaiting review</span>
                    @endif
                </div>
                @if ($user->profile?->selfie_path)
                    <div style="margin:10px 0;">
                        <a href="{{ $user->profile->selfie_url }}" target="_blank">
                            <img src="{{ $user->profile->selfie_url }}" alt="selfie"
                                 style="width:100%;max-height:160px;object-fit:cover;border-radius:8px;">
                        </a>
                    </div>
                    <div style="display:flex;gap:6px;">
                        <form method="POST" action="{{ route('admin.users.verifySelfie', $user) }}">
                            @csrf
                            <button class="btn small primary" type="submit">
                                {{ $user->profile->selfie_verified_at ? 'Revoke' : 'Approve' }}
                            </button>
                        </form>
                        <form method="POST" action="{{ route('admin.users.rejectSelfie', $user) }}"
                              onsubmit="return confirm('Delete this selfie and ask the user to resubmit?');">
                            @csrf
                            <button class="btn small danger" type="submit">Reject &amp; delete</button>
                        </form>
                    </div>
                @else
                    <div style="font-size:12px;color:#888;margin-top:6px;">User must upload a selfie before you can approve.</div>
                @endif
            </div>
        </div>
    </div>

    <div class="panel">
        <div class="panel-head"><h2>Profile</h2></div>
        <div style="padding:20px;">
            @if ($user->profile)
                @php $p = $user->profile; @endphp
                <table class="data" style="box-shadow:none;">
                    <tbody>
                        @foreach ([
                            'Nickname' => $p->nickname,
                            'Birth date' => $p->birth_date?->format('M j, Y'),
                            'Gender' => $p->gender,
                            'Looking for' => $p->show_me,
                            'City / County' => $p->county_state,
                            'Country' => $p->country,
                            'Believer' => $p->is_believer ? 'Yes' : 'No',
                            'Denomination' => $p->denomination,
                            'Has kids' => $p->has_kids ? 'Yes' : 'No',
                            'Kids count' => $p->kids_count,
                            'Willing to relocate' => $p->willing_to_relocate ? 'Yes' : 'No',
                            'Age range' => ($p->age_min && $p->age_max) ? "$p->age_min – $p->age_max" : null,
                            'Education' => $p->education_level,
                            'Occupation' => $p->occupation,
                            'Marital status' => $p->marital_status,
                            'Bio' => $p->bio,
                        ] as $label => $value)
                            <tr>
                                <th style="width:200px;">{{ $label }}</th>
                                <td>{{ $value ?: '—' }}</td>
                            </tr>
                        @endforeach
                        @if (is_array($p->interests) && count($p->interests))
                            <tr>
                                <th>Interests</th>
                                <td>
                                    @foreach ($p->interests as $int)
                                        <span class="pill muted">{{ $int }}</span>
                                    @endforeach
                                </td>
                            </tr>
                        @endif
                    </tbody>
                </table>
            @else
                <p style="color:#999;">No profile created yet.</p>
            @endif
        </div>
    </div>

    @if ($user->profile && $user->profile->photos->isNotEmpty())
        <div class="panel">
            <div class="panel-head"><h2>Photos ({{ $user->profile->photos->count() }})</h2></div>
            <div style="padding:20px;display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:12px;">
                @foreach ($user->profile->photos as $photo)
                    <div style="position:relative;aspect-ratio:3/4;border-radius:8px;overflow:hidden;background:#eee;">
                        <img src="{{ $photo->url }}" alt="" style="width:100%;height:100%;object-fit:cover;display:block;">
                        @if ($photo->is_main)
                            <span class="pill ok" style="position:absolute;top:8px;left:8px;">Main</span>
                        @endif
                        <form method="POST" action="{{ route('admin.users.deletePhoto', [$user, $photo]) }}"
                              style="position:absolute;bottom:6px;right:6px;"
                              onsubmit="return confirm('Delete this photo?');">
                            @csrf @method('DELETE')
                            <button type="submit" class="btn small danger"
                                    style="padding:4px 8px;font-size:11px;">Delete</button>
                        </form>
                    </div>
                @endforeach
            </div>
        </div>
    @endif
@endsection
