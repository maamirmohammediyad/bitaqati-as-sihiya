<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hospital_medications', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->uuid('hospital_id');
            $table->uuid('created_by');

            $table->string('name', 150);
            $table->string('generic_name', 150)->nullable();

            $table->json('recommended_doses');
            $table->boolean('is_active')->default(true);

            $table->timestamps();

            $table->foreign('hospital_id')
                ->references('id')
                ->on('hospitals')
                ->cascadeOnDelete();

            $table->foreign('created_by')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->index(['hospital_id', 'is_active']);
            $table->index(['hospital_id', 'name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hospital_medications');
    }
};