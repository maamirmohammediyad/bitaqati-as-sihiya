<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('medical_files', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('original_name');
            $table->string('storage_path');
            $table->string('mime_type')->nullable();
            $table->unsignedBigInteger('size_bytes')->default(0);
            $table->string('file_type')->default('other');
            $table->text('description')->nullable();
            $table->softDeletes();
            $table->timestamps();

            $table->index(['user_id', 'file_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medical_files');
    }
};
