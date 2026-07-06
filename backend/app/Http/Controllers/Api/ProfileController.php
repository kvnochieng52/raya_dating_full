<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EmailVerificationCode;
use App\Models\Profile;
use App\Models\ProfilePhoto;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    private const GENDERS = ['Man', 'Woman', 'Prefer not to say'];
    private const MARITAL = ['Single', 'Divorced', 'Widowed'];
    private const BODY_TYPES = [
        'Slim', 'Athletic', 'Average', 'Curvy', 'Thick', 'Fit',
        'Muscular', 'Plus-size', 'Petite',
    ];
    private const PURPOSES = ['Counseling', 'Dating', 'Friendship'];
    private const RELATIONSHIP_GOALS = [
        'Casual dating', 'Long-term relationship', 'Marriage',
        'New friends', 'Networking', "Don't know yet",
    ];
    private const EDUCATION = [
        'High School', 'Some College', 'Undergraduate Degree',
        'Graduate Degree', 'PhD/Doctoral', 'Trade School', 'Other',
    ];
    private const OCCUPATIONS = [
        'Student', 'Technology', 'Healthcare', 'Education', 'Finance',
        'Arts & Entertainment', 'Business', 'Engineering', 'Legal',
        'Marketing', 'Sales', 'Other',
    ];
    private const FINANCIAL = [
        'Student', 'Just starting out', 'Financially stable',
        'Doing well', 'Prefer not to say',
    ];
    private const SHOW_ME = ['Men', 'Women', 'Everyone'];
    private const MAX_PHOTOS = 6;

    public function show(Request $request): JsonResponse
    {
        $profile = $this->profileFor($request);
        $profile->load('photos');

        return response()->json(['profile' => $profile]);
    }

    public function update(Request $request): JsonResponse
    {
        $profile = $this->profileFor($request);

        $data = $request->validate([
            // Step 1
            'nickname' => ['sometimes', 'string', 'min:2', 'max:50'],
            'birth_date' => ['sometimes', 'date', 'before:-18 years'],
            'gender' => ['sometimes', Rule::in(self::GENDERS)],
            'marital_status' => ['sometimes', Rule::in(self::MARITAL)],
            'body_type' => ['sometimes', Rule::in(self::BODY_TYPES)],
            'bio' => ['sometimes', 'nullable', 'string', 'max:500'],

            // Step 2
            'kingdom_purpose' => ['sometimes', Rule::in(self::PURPOSES)],
            'relationship_goal' => [
                'sometimes', 'nullable',
                Rule::in(self::RELATIONSHIP_GOALS),
                Rule::requiredIf(fn () => $request->input('kingdom_purpose') === 'Dating'),
            ],
            'is_believer' => ['sometimes', 'boolean'],
            'denomination' => [
                'sometimes', 'nullable', 'string', 'max:100',
                Rule::requiredIf(fn () => $request->boolean('is_believer')),
            ],
            'has_kids' => ['sometimes', 'boolean'],
            'kids_count' => [
                'sometimes', 'nullable', 'integer', 'min:1', 'max:20',
                Rule::requiredIf(fn () => $request->boolean('has_kids')),
            ],
            'education_level' => ['sometimes', Rule::in(self::EDUCATION)],
            'occupation' => ['sometimes', Rule::in(self::OCCUPATIONS)],
            'financial_status' => ['sometimes', Rule::in(self::FINANCIAL)],
            'country' => ['sometimes', 'string', 'max:100'],
            'county_state' => ['sometimes', 'string', 'max:100'],
            'willing_to_relocate' => ['sometimes', 'boolean'],

            // Step 4
            'interests' => ['sometimes', 'array', 'min:3', 'max:50'],
            'interests.*' => ['string', 'max:50'],
            'show_me' => ['sometimes', Rule::in(self::SHOW_ME)],
            'age_min' => ['sometimes', 'integer', 'min:18', 'max:120'],
            'age_max' => ['sometimes', 'integer', 'min:18', 'max:120', 'gte:age_min'],
            'max_distance' => ['sometimes', 'integer', 'min:1', 'max:500'],
            'admin_contact_consent' => ['sometimes', 'boolean'],
            'admin_contact_time' => [
                'sometimes', 'nullable', 'string', 'max:100',
                Rule::requiredIf(fn () => $request->boolean('admin_contact_consent')),
            ],
            'admin_contact_phone' => [
                'sometimes', 'nullable', 'string', 'max:30',
                Rule::requiredIf(fn () => $request->boolean('admin_contact_consent')),
            ],
            'admin_contact_email' => [
                'sometimes', 'nullable', 'email', 'max:255',
                Rule::requiredIf(fn () => $request->boolean('admin_contact_consent')),
            ],
            'partner_details' => ['sometimes', 'nullable', 'string', 'max:500'],

            // Progress
            'completed_step' => ['sometimes', 'integer', 'min:0', 'max:5'],
        ]);

        // If admin contact consent is being set to false, clear contact fields.
        if (array_key_exists('admin_contact_consent', $data) && ! $data['admin_contact_consent']) {
            $data['admin_contact_time'] = null;
            $data['admin_contact_phone'] = null;
            $data['admin_contact_email'] = null;
        }

        // If user marks themselves as not a believer, clear denomination.
        if (array_key_exists('is_believer', $data) && ! $data['is_believer']) {
            $data['denomination'] = null;
        }

        // If user marks no kids, clear count.
        if (array_key_exists('has_kids', $data) && ! $data['has_kids']) {
            $data['kids_count'] = null;
        }

        // completed_step only ratchets forward.
        if (isset($data['completed_step']) && $data['completed_step'] < $profile->completed_step) {
            unset($data['completed_step']);
        }

        $profile->fill($data)->save();
        $profile->load('photos');

        return response()->json(['profile' => $profile]);
    }

    public function uploadPhoto(Request $request): JsonResponse
    {
        $profile = $this->profileFor($request);

        $data = $request->validate([
            'photo' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
            'position' => ['required', 'integer', 'min:0', 'max:' . (self::MAX_PHOTOS - 1)],
            'is_main' => ['sometimes', 'boolean'],
        ]);

        $path = $request->file('photo')->store(
            "profiles/{$profile->id}/photos",
            'public'
        );

        // Replace any existing photo at this position.
        $existing = $profile->photos()->where('position', $data['position'])->first();
        if ($existing) {
            Storage::disk('public')->delete($existing->path);
            $existing->delete();
        }

        $isMain = ($data['is_main'] ?? false) || $data['position'] === 0;
        if ($isMain) {
            $profile->photos()->update(['is_main' => false]);
        }

        $photo = $profile->photos()->create([
            'position' => $data['position'],
            'path' => $path,
            'is_main' => $isMain,
        ]);

        return response()->json(['photo' => $photo], 201);
    }

    public function deletePhoto(Request $request, ProfilePhoto $photo): JsonResponse
    {
        $profile = $this->profileFor($request);
        if ($photo->profile_id !== $profile->id) {
            abort(403);
        }

        Storage::disk('public')->delete($photo->path);
        $photo->delete();

        // If we deleted the main photo, promote the lowest-position remaining one.
        if ($photo->is_main) {
            $next = $profile->photos()->orderBy('position')->first();
            if ($next) {
                $next->update(['is_main' => true]);
            }
        }

        return response()->json(['deleted' => true]);
    }

    public function setMainPhoto(Request $request, ProfilePhoto $photo): JsonResponse
    {
        $profile = $this->profileFor($request);
        if ($photo->profile_id !== $profile->id) {
            abort(403);
        }

        $profile->photos()->update(['is_main' => false]);
        $photo->update(['is_main' => true]);

        return response()->json(['photo' => $photo]);
    }

    /**
     * Generates a fresh 6-digit code, replaces any previous code for this
     * user, and emails it. In dev (MAIL_MAILER=log) the message lands in
     * storage/logs/laravel.log.
     */
    public function requestEmailCode(Request $request): JsonResponse
    {
        $user = $request->user();
        $code = (string) random_int(100000, 999999);
        $expiresAt = Carbon::now()->addMinutes(10);

        // One active code per user — wipe older entries.
        EmailVerificationCode::where('user_id', $user->id)->delete();
        EmailVerificationCode::create([
            'user_id' => $user->id,
            'code' => $code,
            'expires_at' => $expiresAt,
        ]);

        Mail::raw(
            "Your Kingdom Dating verification code is: $code\n\n" .
            'This code expires in 10 minutes. If you did not request it, you can safely ignore this message.',
            function ($message) use ($user) {
                $message->to($user->email)
                        ->subject('Your Kingdom Dating verification code');
            }
        );

        return response()->json([
            'message' => 'Verification code sent.',
            'expires_at' => $expiresAt->toIso8601String(),
        ]);
    }

    /**
     * Validates the most recent code for the user and, if it matches and is
     * unexpired, marks their email as verified.
     */
    public function verifyEmail(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'size:6'],
        ]);

        $user = $request->user();
        $entry = EmailVerificationCode::where('user_id', $user->id)
            ->latest('id')
            ->first();

        if (! $entry || $entry->code !== $data['code'] || $entry->isExpired()) {
            return response()->json([
                'message' => 'That code is invalid or expired. Request a new one.',
                'errors' => ['code' => ['Invalid or expired code.']],
            ], 422);
        }

        $profile = $this->profileFor($request);
        $profile->email_verified = true;
        $profile->save();

        // Burn the code after a successful verify.
        EmailVerificationCode::where('user_id', $user->id)->delete();

        return response()->json(['profile' => $profile->fresh()]);
    }

    public function uploadSelfie(Request $request): JsonResponse
    {
        $data = $request->validate([
            'selfie' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:5120'],
        ]);

        $profile = $this->profileFor($request);

        if ($profile->selfie_path) {
            Storage::disk('public')->delete($profile->selfie_path);
        }

        $path = $data['selfie']->store(
            "profiles/{$profile->id}/selfie",
            'public'
        );

        $profile->selfie_path = $path;
        $profile->save();

        return response()->json(['profile' => $profile->fresh()]);
    }

    private function profileFor(Request $request): Profile
    {
        $user = $request->user();
        return $user->profile()->firstOrCreate(['user_id' => $user->id]);
    }
}
