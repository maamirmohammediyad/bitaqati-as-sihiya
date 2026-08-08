<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('hospitals', function (Blueprint $table): void {
            $table->string('type')
                ->default('hospital')
                ->after('name');

            $table->string('license_number')
                ->nullable()
                ->unique()
                ->after('type');

            $table->string('status')
                ->default('approved')
                ->index()
                ->after('is_active');

            $table->foreignUuid('created_by')
                ->nullable()
                ->after('status')
                ->constrained('users')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('hospitals', function (Blueprint $table): void {
            $table->dropForeign(['created_by']);
            $table->dropColumn([
                'created_by',
                'status',
                'license_number',
                'type',
            ]);
        });
    }
};