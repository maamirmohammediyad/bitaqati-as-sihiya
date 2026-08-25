<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('hospital_patient_qr_scans', function (Blueprint $table): void {
            $table->uuid('id')->primary();

            $table->foreignUuid('hospital_id')
                ->constrained('hospitals')
                ->cascadeOnDelete();

            $table->foreignUuid('patient_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignUuid('scanned_by_user_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignUuid('patient_qr_token_id')
                ->nullable()
                ->constrained('patient_qr_tokens')
                ->nullOnDelete();

            $table->timestamp('scanned_at');
            $table->timestamps();

            $table->index(['hospital_id', 'scanned_at']);
            $table->index(['scanned_by_user_id', 'scanned_at']);
            $table->index(['patient_id', 'scanned_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hospital_patient_qr_scans');
    }
};