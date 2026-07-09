<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('counselling_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            $table->string('counselor_gender');            // Male | Female | No preference
            $table->string('contact_phone')->nullable();
            $table->string('contact_email')->nullable();
            $table->json('communication_modes');           // ['Call','Text','Email','Video Call']
            $table->string('budget_range');
            $table->string('counselling_type');            // Relationship | Pre-marital | Marriage | Personal | Grief | Anxiety
            $table->string('session_format');              // Online | In-person | Either
            $table->string('preferred_days')->nullable();  // Weekdays | Weekends | Flexible
            $table->string('preferred_time')->nullable();  // Morning | Afternoon | Evening
            $table->string('urgency');                     // This week | Within a month | No rush
            $table->text('description')->nullable();
            $table->string('status')->default('pending');  // pending | contacted | resolved

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('counselling_requests');
    }
};
