<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class ProfilePhoto extends Model
{
    protected $fillable = ['profile_id', 'position', 'path', 'is_main'];

    protected $casts = [
        'position' => 'integer',
        'is_main' => 'boolean',
    ];

    protected $appends = ['url'];

    public function profile(): BelongsTo
    {
        return $this->belongsTo(Profile::class);
    }

    protected function url(): Attribute
    {
        return Attribute::get(function (): string {
            if (str_starts_with($this->path, 'http://') ||
                str_starts_with($this->path, 'https://')) {
                return $this->path;
            }
            return Storage::disk('public')->url($this->path);
        });
    }
}
