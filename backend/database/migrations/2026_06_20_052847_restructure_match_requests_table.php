<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('match_requests', function (Blueprint $table) {
            // Drop the original (overly broad) submitter fields.
            $table->dropColumn([
                'gender_preference',
                'age_min',
                'age_max',
                'location',
                'occupation',
                'interests',
                'personality',
                'additional_notes',
            ]);
        });

        Schema::table('match_requests', function (Blueprint $table) {
            // New, minimal schema — what the submitter is and what they want.
            $table->string('gender', 32)->nullable()->after('user_id');
            $table->string('body_type', 64)->nullable()->after('gender');
            $table->string('religion', 64)->nullable()->after('body_type');
            $table->string('phone', 32)->nullable()->after('religion');
            $table->string('email')->nullable()->after('phone');
            $table->text('looking_for_details')->nullable()->after('email');
        });
    }

    public function down(): void
    {
        Schema::table('match_requests', function (Blueprint $table) {
            $table->dropColumn([
                'gender',
                'body_type',
                'religion',
                'phone',
                'email',
                'looking_for_details',
            ]);
        });

        Schema::table('match_requests', function (Blueprint $table) {
            $table->string('gender_preference', 32)->nullable();
            $table->unsignedTinyInteger('age_min')->nullable();
            $table->unsignedTinyInteger('age_max')->nullable();
            $table->string('location')->nullable();
            $table->string('occupation')->nullable();
            $table->json('interests')->nullable();
            $table->text('personality')->nullable();
            $table->text('additional_notes')->nullable();
        });
    }
};
