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
       Schema::table('emergency_events', function (Blueprint $table): void {
    $table->index(
        ['checked_in_hospital_id', 'status', 'checked_in_at'],
        'emergency_events_hospital_status_checkin_index',
    );
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('emergency_events', function (Blueprint $table) {
            //
        });
    }
};
