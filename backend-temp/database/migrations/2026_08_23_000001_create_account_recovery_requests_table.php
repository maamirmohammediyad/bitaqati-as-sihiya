<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('account_recovery_requests', function (Blueprint $table): void {
            $table->uuid('id')->primary();

            $table->uuid('user_id')->nullable()->index();
            $table->string('national_id', 50)->index();
            $table->string('full_name', 255);
            $table->string('phone', 30)->nullable();
            $table->text('note')->nullable();

            $table->string('identity_document_path');
            $table->string('identity_document_name');
            $table->string('identity_document_mime', 100);
            $table->unsignedBigInteger('identity_document_size');

            $table->string('status', 20)->default('pending')->index();
            $table->text('admin_note')->nullable();

            $table->uuid('reviewed_by')->nullable()->index();
            $table->timestamp('reviewed_at')->nullable();

            $table->string('completion_token_hash', 64)->nullable()->unique();
            $table->timestamp('completion_token_expires_at')->nullable();
            $table->timestamp('completion_token_used_at')->nullable();

            $table->timestamps();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->nullOnDelete();

            $table->foreign('reviewed_by')
                ->references('id')
                ->on('users')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('account_recovery_requests');
    }
};