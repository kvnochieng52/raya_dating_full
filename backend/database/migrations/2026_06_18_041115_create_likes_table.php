<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('likes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('target_user_id')->constrained('users')->cascadeOnDelete();
            // 'like' | 'super_like' | 'pass'
            $table->string('action', 16);
            $table->timestamps();

            $table->unique(['user_id', 'target_user_id']);
            $table->index(['target_user_id', 'action']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('likes');
    }
};
