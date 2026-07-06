<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('match_id')
                ->constrained('matches')
                ->cascadeOnDelete();
            $table->foreignId('sender_id')
                ->constrained('users')
                ->cascadeOnDelete();
            $table->text('body');
            $table->timestamps();

            // Newest-first scans within a thread.
            $table->index(['match_id', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
