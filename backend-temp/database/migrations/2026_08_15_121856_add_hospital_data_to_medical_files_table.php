<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('medical_files', function (Blueprint $table): void {
            $table->foreignUuid('hospital_id')
                ->nullable()
                ->after('user_id')
                ->constrained('hospitals')
                ->nullOnDelete();

            $table->foreignUuid('uploaded_by')
                ->nullable()
                ->after('hospital_id')
                ->constrained('users')
                ->nullOnDelete();

            $table->index(['hospital_id', 'user_id']);
            $table->index(['uploaded_by', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::table('medical_files', function (Blueprint $table): void {
            $table->dropIndex(['hospital_id', 'user_id']);
            $table->dropIndex(['uploaded_by', 'created_at']);

            $table->dropConstrainedForeignId('uploaded_by');
            $table->dropConstrainedForeignId('hospital_id');
        });
    }
};