<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guardian_patient', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('guardian_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('patient_id')->constrained('users')->cascadeOnDelete();
            $table->string('relationship')->nullable();
            $table->boolean('can_access_location')->default(false);
            $table->boolean('is_verified')->default(false);
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();

            $table->unique(['guardian_id', 'patient_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guardian_patient');
    }
};
