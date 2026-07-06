<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MatchRecord extends Model
{
    // 'matches' is a SQL reserved word in some contexts but acceptable here.
    protected $table = 'matches';

    protected $fillable = ['user_low_id', 'user_high_id', 'matched_at'];

    protected $casts = [
        'matched_at' => 'datetime',
    ];

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class, 'match_id');
    }

    /**
     * Whether [$userId] is one of the two parties in this match.
     */
    public function involves(int $userId): bool
    {
        return $this->user_low_id === $userId || $this->user_high_id === $userId;
    }

    public function userLow(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_low_id');
    }

    public function userHigh(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_high_id');
    }

    /**
     * Returns the User on the "other" side of this match for the given viewer.
     */
    public function partnerFor(int $viewerId): ?User
    {
        if ($this->user_low_id === $viewerId) {
            return $this->userHigh;
        }
        if ($this->user_high_id === $viewerId) {
            return $this->userLow;
        }
        return null;
    }

    /**
     * Helper: pair two user IDs into low/high so unique constraint works.
     */
    public static function pairIds(int $a, int $b): array
    {
        return $a < $b ? [$a, $b] : [$b, $a];
    }
}
