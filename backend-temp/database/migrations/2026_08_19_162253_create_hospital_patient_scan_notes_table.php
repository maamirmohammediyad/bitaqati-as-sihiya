<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('hospital_patient_scan_notes', function (Blueprint $table): void {
            $table->uuid('id')->primary();

            $table->foreignUuid('hospital_id')
                ->constrained('hospitals')
                ->cascadeOnDelete();

            $table->foreignUuid('patient_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignUuid('hospital_patient_qr_scan_id')
                ->constrained('hospital_patient_qr_scans')
                ->cascadeOnDelete();

            $table->foreignUuid('created_by_user_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->text('note');
            $table->timestamps();

            $table->index([
                'hospital_id',
                'patient_id',
                'created_at',
            ]);

            $table->index([
                'hospital_patient_qr_scan_id',
                'created_at',
            ]);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hospital_patient_scan_notes');
    }
};