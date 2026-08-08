<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hospital_users', function (Blueprint $table): void {
            $table->uuid('id')->primary();

            $table->foreignUuid('hospital_id')
                ->constrained('hospitals')
                ->cascadeOnDelete();

            $table->foreignUuid('user_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->string('role')->default('staff');
            $table->boolean('is_active')->default(true);
            $table->timestamp('joined_at')->nullable();
            $table->timestamps();

            $table->unique(['hospital_id', 'user_id']);
            $table->index(['hospital_id', 'role']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hospital_users');
    }
};