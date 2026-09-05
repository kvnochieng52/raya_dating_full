<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;

class Profile extends Model
{
    protected $guarded = ['id', 'user_id', 'created_at', 'updated_at'];

    protected $casts = [
        'birth_date' => 'date',
        'is_believer' => 'boolean',
        'has_kids' => 'boolean',
        'willing_to_relocate' => 'boolean',
        'admin_contact_consent' => 'boolean',
        'email_verified' => 'boolean',
        'phone_verified' => 'boolean',
        'kids_count' => 'integer',
        'age_min' => 'integer',
        'age_max' => 'integer',
        'completed_step' => 'integer',
        'interests' => 'array',
    ];

    protected $appends = ['selfie_url', 'selfie_uploaded'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function photos(): HasMany
    {
        return $this->hasMany(ProfilePhoto::class)->orderBy('position');
    }

    public function markStepComplete(int $step): void
    {
        if ($step > $this->completed_step) {
            $this->completed_step = $step;
            $this->save();
        }
    }

    protected function selfieUrl(): Attribute
    {
        return Attribute::get(function (): ?string {
            if ($this->selfie_path === null) return null;
            if (str_starts_with($this->selfie_path, 'http://') ||
                str_starts_with($this->selfie_path, 'https://')) {
                return $this->selfie_path;
            }
            return Storage::disk('public')->url($this->selfie_path);
        });
    }

    protected function selfieUploaded(): Attribute
    {
        return Attribute::get(fn (): bool => $this->selfie_path !== null);
    }
}
