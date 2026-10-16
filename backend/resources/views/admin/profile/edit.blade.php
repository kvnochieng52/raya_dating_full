@extends('layouts.admin')
@section('title', 'My profile')

@section('content')
    <div class="page-head"><h1>My profile</h1></div>

    <div class="panel">
        <div class="panel-head"><h2>Account</h2></div>
        <form method="POST" action="{{ route('admin.profile.update') }}" style="padding:24px;max-width:520px;">
            @csrf @method('PATCH')
            <div style="margin-bottom:14px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Name</label>
                <input type="text" name="name" required value="{{ old('name', $admin->name) }}" style="width:100%;">
            </div>
            <div style="margin-bottom:14px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Email</label>
                <input type="email" name="email" required value="{{ old('email', $admin->email) }}" style="width:100%;">
            </div>
            <div style="margin-bottom:14px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Phone</label>
                <input type="text" name="phone" value="{{ old('phone', $admin->phone) }}" style="width:100%;">
            </div>
            <button class="btn primary" type="submit">Save</button>
        </form>
    </div>

    <div class="panel">
        <div class="panel-head"><h2>Change password</h2></div>
        <form method="POST" action="{{ route('admin.profile.password') }}" style="padding:24px;max-width:520px;">
            @csrf @method('PATCH')
            <div style="margin-bottom:14px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Current password</label>
                <input type="password" name="current_password" required style="width:100%;">
            </div>
            <div style="margin-bottom:14px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">New password</label>
                <input type="password" name="password" required style="width:100%;">
            </div>
            <div style="margin-bottom:14px;">
                <label style="display:block;font-weight:600;margin-bottom:6px;">Confirm new password</label>
                <input type="password" name="password_confirmation" required style="width:100%;">
            </div>
            <button class="btn primary" type="submit">Update password</button>
        </form>
    </div>
@endsection
