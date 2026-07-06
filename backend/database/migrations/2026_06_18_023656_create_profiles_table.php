<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')
                ->unique()
                ->constrained()
                ->cascadeOnDelete();

            // Step 1 — Basic Info
            $table->string('nickname')->nullable();
            $table->date('birth_date')->nullable();
            $table->string('gender')->nullable();
            $table->string('marital_status')->nullable();
            $table->string('body_type')->nullable();
            $table->text('bio')->nullable();

            // Step 2 — Faith & Background
            $table->string('kingdom_purpose')->nullable();
            $table->string('relationship_goal')->nullable();
            $table->boolean('is_believer')->nullable();
            $table->string('denomination')->nullable();
            $table->boolean('has_kids')->nullable();
            $table->unsignedTinyInteger('kids_count')->nullable();
            $table->string('education_level')->nullable();
            $table->string('occupation')->nullable();
            $table->string('financial_status')->nullable();
            $table->string('country')->nullable();
            $table->string('county_state')->nullable();
            $table->boolean('willing_to_relocate')->nullable();

            // Step 4 — Interests & Preferences
            $table->json('interests')->nullable();
            $table->string('show_me')->nullable();
            $table->unsignedTinyInteger('age_min')->nullable();
            $table->unsignedTinyInteger('age_max')->nullable();
            $table->unsignedSmallInteger('max_distance')->nullable();
            $table->boolean('admin_contact_consent')->nullable();
            $table->string('admin_contact_time')->nullable();
            $table->string('admin_contact_phone')->nullable();
            $table->string('admin_contact_email')->nullable();
            $table->text('partner_details')->nullable();

            // Step 5 — Verification
            $table->boolean('email_verified')->default(false);
            $table->boolean('phone_verified')->default(false);
            $table->string('verification_phone')->nullable();
            $table->string('selfie_path')->nullable();

            // Progress tracking — highest completed step (0..5)
            $table->unsignedTinyInteger('completed_step')->default(0);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profiles');
    }
};
