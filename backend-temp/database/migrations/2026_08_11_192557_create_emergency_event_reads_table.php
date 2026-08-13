<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('emergency_event_reads', function (Blueprint $table): void {
            $table->uuid('id')->primary();

            $table->uuid('emergency_event_id');
            $table->uuid('guardian_id');

            $table->timestamp('read_at')->useCurrent();

            $table->timestamps();

            $table->foreign('emergency_event_id')
                ->references('id')
                ->on('emergency_events')
                ->cascadeOnDelete();

            $table->foreign('guardian_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->unique(
                ['emergency_event_id', 'guardian_id'],
                'emergency_event_guardian_unique',
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('emergency_event_reads');
    }
};