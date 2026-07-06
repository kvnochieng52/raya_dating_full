<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('match_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();
            $table->string('gender_preference', 32);
            $table->unsignedTinyInteger('age_min');
            $table->unsignedTinyInteger('age_max');
            $table->string('location')->nullable();
            $table->string('occupation')->nullable();
            $table->json('interests')->nullable();
            $table->text('personality')->nullable();
            $table->text('additional_notes')->nullable();
            // pending | reviewed | contacted | closed
            $table->string('status', 16)->default('pending');
            $table->timestamps();

            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('match_requests');
    }
};
