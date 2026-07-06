<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Stores mutual likes as a single row with the smaller user id
        // in user_low_id. Enforces uniqueness regardless of who liked first.
        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_low_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('user_high_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('matched_at')->useCurrent();
            $table->timestamps();

            $table->unique(['user_low_id', 'user_high_id']);
            $table->index('user_high_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('matches');
    }
};
