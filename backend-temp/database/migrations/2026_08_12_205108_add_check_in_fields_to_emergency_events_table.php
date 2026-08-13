<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('emergency_events', function (Blueprint $table) {
            $table->foreignUuid('checked_in_hospital_id')
                ->nullable()
                ->after('notified_guardians')
                ->constrained('hospitals')
                ->nullOnDelete();

            $table->timestamp('checked_in_at')
                ->nullable()
                ->after('checked_in_hospital_id');
        });
    }

    public function down(): void
    {
        Schema::table('emergency_events', function (Blueprint $table) {
            $table->dropConstrainedForeignId('checked_in_hospital_id');
            $table->dropColumn('checked_in_at');
        });
    }
};