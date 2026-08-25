<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('medical_files', function (Blueprint $table): void {
            $table->string('file_type')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('medical_files', function (Blueprint $table): void {
            $table->string('file_type')->nullable(false)->change();
        });
    }
};