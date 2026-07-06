<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Like extends Model
{
    public const ACTION_LIKE = 'like';
    public const ACTION_SUPER_LIKE = 'super_like';
    public const ACTION_PASS = 'pass';

    protected $fillable = ['user_id', 'target_user_id', 'action'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function targetUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'target_user_id');
    }

    public function isPositive(): bool
    {
        return in_array($this->action, [self::ACTION_LIKE, self::ACTION_SUPER_LIKE], true);
    }
}
