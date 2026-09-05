<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PasswordResetCode;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'min:3', 'max:255'],
            'email' => ['required', 'string', 'email:rfc', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'min:7', 'max:32'],
            // Relaxed: just a minimum length. No mixed-case / number requirement.
            'password' => ['required', 'confirmed', 'string', 'min:6', 'max:255'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
            'password' => $data['password'],
        ]);

        $user->profile()->create();

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'user' => $user,
            'profile' => $this->profileSummary($user),
            'token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'string', 'email:rfc'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            return response()->json([
                'message' => 'The provided credentials are incorrect.',
            ], 401);
        }

        $deviceName = $request->input('device_name', 'mobile');
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'user' => $user,
            'profile' => $this->profileSummary($user),
            'token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        return response()->json([
            'user' => $user,
            'profile' => $this->profileSummary($user),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out.',
        ]);
    }

    /**
     * Emails a 6-digit reset code to the user if one exists. To avoid leaking
     * which emails are registered, we return the same 200 response either way.
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string', 'email:rfc', 'max:255'],
        ]);

        $genericResponse = response()->json([
            'message' => 'If an account exists for that email, a reset code has been sent.',
        ]);

        $user = User::where('email', $data['email'])->first();
        if (! $user) {
            return $genericResponse;
        }

        $code = (string) random_int(100000, 999999);
        $expiresAt = Carbon::now()->addMinutes(15);

        // One active code per user — wipe older entries.
        PasswordResetCode::where('user_id', $user->id)->delete();
        PasswordResetCode::create([
            'user_id' => $user->id,
            'code' => $code,
            'expires_at' => $expiresAt,
        ]);

        Mail::raw(
            "Your Kingdom Dating password reset code is: $code\n\n" .
            'This code expires in 15 minutes. If you did not request a password reset, you can safely ignore this message.',
            function ($message) use ($user) {
                $message->to($user->email)
                        ->subject('Your Kingdom Dating password reset code');
            }
        );

        return $genericResponse;
    }

    /**
     * Verifies the code, updates the password, and revokes existing sessions so
     * a compromised device is signed out.
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'string', 'email:rfc'],
            'code' => ['required', 'string', 'size:6'],
            'password' => ['required', 'confirmed', 'string', 'min:6', 'max:255'],
        ]);

        $user = User::where('email', $data['email'])->first();
        $entry = $user
            ? PasswordResetCode::where('user_id', $user->id)->latest('id')->first()
            : null;

        if (! $user || ! $entry || $entry->code !== $data['code'] || $entry->isExpired()) {
            return response()->json([
                'message' => 'That code is invalid or expired. Request a new one.',
                'errors' => ['code' => ['Invalid or expired code.']],
            ], 422);
        }

        $user->password = $data['password'];
        $user->save();

        // Burn all reset codes and existing API tokens — force re-login.
        PasswordResetCode::where('user_id', $user->id)->delete();
        $user->tokens()->delete();

        return response()->json([
            'message' => 'Password updated. Please sign in with your new password.',
        ]);
    }

    /**
     * Minimal profile slice clients need to gate features like swiping and
     * messaging.
     */
    private function profileSummary(User $user): array
    {
        $profile = $user->profile()->firstOrCreate(['user_id' => $user->id]);

        return [
            'completed_step' => (int) $profile->completed_step,
            'nickname' => $profile->nickname,
        ];
    }
}
