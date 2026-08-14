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
    Schema::create('emergency_event_notes', function (Blueprint $table): void {
        $table->uuid('id')->primary();

        $table->uuid('emergency_event_id');
        $table->uuid('hospital_id');
        $table->uuid('author_id');

        $table->text('note');
        $table->timestamps();

        $table->foreign('emergency_event_id')
            ->references('id')
            ->on('emergency_events')
            ->cascadeOnDelete();

        $table->foreign('hospital_id')
            ->references('id')
            ->on('hospitals')
            ->cascadeOnDelete();

        $table->foreign('author_id')
            ->references('id')
            ->on('users')
            ->cascadeOnDelete();

        $table->index(['emergency_event_id', 'created_at']);
        $table->index(['hospital_id', 'created_at']);
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('emergency_event_notes');
    }
};
