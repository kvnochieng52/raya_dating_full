<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ContactMessage extends Model
{
    protected $fillable = [
        'name', 'email', 'subject', 'message',
        'ip_address', 'user_agent', 'read_at',
    ];

    protected $casts = [
        'read_at' => 'datetime',
    ];
}
