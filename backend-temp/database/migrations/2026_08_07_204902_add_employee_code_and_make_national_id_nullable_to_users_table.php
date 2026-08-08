<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->string('national_id', 50)->nullable()->change();

            $table->string('employee_code', 50)
                ->nullable()
                ->unique()
                ->after('patient_code');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->dropUnique(['employee_code']);
            $table->dropColumn('employee_code');

            $table->string('national_id', 50)->nullable(false)->change();
        });
    }
};