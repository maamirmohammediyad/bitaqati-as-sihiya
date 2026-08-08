<?php

declare(strict_types=1);

namespace App\Domain\Actions\Auth;

use App\Domain\Enums\UserRole;
use App\Domain\Models\PatientProfile;
use App\Domain\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class RegisterPatientAction
{
    public function execute(array $data): array
    {
        return DB::transaction(function () use ($data): array {
            // بناء الاسم الكامل من first_name + last_name
            $fullName = $data['first_name'].' '.$data['last_name'];

            // توليد كود المريض
            $patientCode = $this->generatePatientCode();

            // إنشاء المستخدم
            $user = User::create([
                'id'           => (string) Str::uuid(),              // لو جدول users يستخدم uuid
                'name'         => $fullName,
                'email'        => null,                              // لا نستخدم email في تسجيل المريض حالياً
                'phone'        => $data['phone'] ?? null,
                'national_id'  => $data['national_id'],
                'password'     => Hash::make($data['password']),
                'role' => UserRole::Patient->value,
                'patient_code' => $patientCode,
                'is_active'    => true,
            ]);

            // إنشاء ملف المريض
            PatientProfile::create([
                'user_id'    => $user->id,
                'first_name' => $data['first_name'],
                'last_name'  => $data['last_name'],
                // لو عندك حقل full_name في الجدول:
                // 'full_name' => $fullName,
            ]);

            // إنشاء access token بواسطة Sanctum
            $token = $user->createToken('auth-token')->plainTextToken;

            return [
                'user'  => $user->load('patientProfile'),
                'token' => $token,
            ];
        });
    }

    private function generatePatientCode(): string
    {
        // يمكنك تغيير الصيغة لاحقاً مثلاً HLT-XXXX-XXXX
        return 'HLT-'.strtoupper(Str::random(4)).'-'.strtoupper(Str::random(4));
    }
}