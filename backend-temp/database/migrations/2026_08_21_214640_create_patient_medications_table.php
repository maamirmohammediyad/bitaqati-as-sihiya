<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_medications', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->uuid('patient_id');
            $table->uuid('hospital_medication_id');
            $table->uuid('added_by');

            $table->string('dose', 255);
            $table->string('instructions', 500)->nullable();

            $table->timestamps();

            $table->foreign('patient_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->foreign('hospital_medication_id')
                ->references('id')
                ->on('hospital_medications')
                ->restrictOnDelete();

            $table->foreign('added_by')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->unique(
                ['patient_id', 'hospital_medication_id', 'dose'],
                'patient_medications_patient_drug_dose_unique'
            );

            $table->index(['patient_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_medications');
    }
};