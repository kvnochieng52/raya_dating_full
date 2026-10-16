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
            <form method="POST" action="{{ route('admin.users.verify', $user) }}">
                @csrf
                <button class="btn small" type="submit">
                    {{ $user->email_verified_at ? 'Mark unverified' : 'Mark verified' }}
                </button>
            </form>
            <form method="POST" action="{{ route('admin.users.suspend', $user) }}">
                @csrf
                <button class="btn small {{ $user->suspended_at ? '' : 'danger' }}" type="submit">
                    {{ $user->suspended_at ? 'Reinstate' : 'Suspend' }}
                </button>
            </form>
            @if ($user->id !== auth()->id())
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
                            'Looking for' => $p->looking_for,
                            'City' => $p->city,
                            'Country' => $p->country,
                            'Believer' => $p->is_believer ? 'Yes' : 'No',
                            'Denomination' => $p->denomination,
                            'Has kids' => $p->has_kids ? 'Yes' : 'No',
                            'Kids count' => $p->kids_count,
                            'Willing to relocate' => $p->willing_to_relocate ? 'Yes' : 'No',
                            'Age range' => ($p->age_min && $p->age_max) ? "$p->age_min – $p->age_max" : null,
                            'Email verified' => $p->email_verified ? 'Yes' : 'No',
                            'Phone verified' => $p->phone_verified ? 'Yes' : 'No',
                            'Selfie uploaded' => $p->selfie_uploaded ? 'Yes' : 'No',
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
            <div class="panel-head"><h2>Photos</h2></div>
            <div style="padding:20px;display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:12px;">
                @foreach ($user->profile->photos as $photo)
                    <div style="position:relative;aspect-ratio:3/4;border-radius:8px;overflow:hidden;background:#eee;">
                        <img src="{{ $photo->url }}" alt="" style="width:100%;height:100%;object-fit:cover;display:block;">
                        @if ($photo->is_main)
                            <span class="pill ok" style="position:absolute;top:8px;left:8px;">Main</span>
                        @endif
                    </div>
                @endforeach
            </div>
        </div>
    @endif
@endsection
