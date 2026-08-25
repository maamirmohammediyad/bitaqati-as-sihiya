<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::dropIfExists('hospital_patient_accesses');
    }

    public function down(): void
    {
        // لا نعيد إنشاء الجدول لأنه غير مستخدم في النظام.
    }
};