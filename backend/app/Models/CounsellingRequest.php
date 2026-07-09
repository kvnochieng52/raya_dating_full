<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CounsellingRequest extends Model
{
    protected $fillable = [
        'user_id',
        'requester_name',
        'counselor_gender',
        'contact_phone',
        'contact_email',
        'communication_modes',
        'budget_range',
        'counselling_type',
        'session_format',
        'preferred_days',
        'preferred_time',
        'urgency',
        'description',
        'status',
    ];

    protected $casts = [
        'communication_modes' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
