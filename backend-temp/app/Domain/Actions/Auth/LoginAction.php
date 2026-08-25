<?php

declare(strict_types=1);

namespace App\Domain\Actions\Auth;

use App\Domain\Enums\UserRole;
use App\Domain\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class LoginAction
{
    public function execute(string $nationalId, string $password): array
    {
        $user = User::where('national_id', $nationalId)->first();

        return $this->authenticate(
            user: $user,
            password: $password,
            errorField: 'national_id',
        );
    }

    public function executeWithEmail(string $email, string $password): array
    {
        $user = User::where('email', $email)->first();

        $result = $this->authenticate(
            user: $user,
            password: $password,
            errorField: 'email',
        );

        /** @var User $authenticatedUser */
        $authenticatedUser = $result['user'];

        if ($authenticatedUser->role !== UserRole::SuperAdmin) {
            throw ValidationException::withMessages([
                'email' => ['هذا الحساب ليس حساب مسؤول نظام.'],
            ]);
        }

        return $result;
    }

    public function executeWithEmployeeCode(
        string $employeeCode,
        string $password,
    ): array {
        $user = User::where('employee_code', $employeeCode)->first();

        $result = $this->authenticate(
            user: $user,
            password: $password,
            errorField: 'employee_code',
        );

        /** @var User $authenticatedUser */
        $authenticatedUser = $result['user'];

        if ($authenticatedUser->role !== UserRole::HealthWorker) {
            throw ValidationException::withMessages([
                'employee_code' => ['هذا الحساب ليس حساب موظف صحي.'],
            ]);
        }

        $hasActiveHospital = $authenticatedUser->hospitals()
            ->wherePivot('is_active', true)
            ->where('hospitals.is_active', true)
            ->where('hospitals.status', 'approved')
            ->exists();

        if (! $hasActiveHospital) {
            throw ValidationException::withMessages([
                'employee_code' => [
                    'لا توجد مؤسسة صحية نشطة مرتبطة بهذا الحساب.',
                ],
            ]);
        }

        return $result;
    }

    private function authenticate(
        ?User $user,
        string $password,
        string $errorField,
    ): array {
        if ($user === null || ! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                $errorField => ['بيانات تسجيل الدخول غير صحيحة.'],
            ]);
        }

        if (
    $user->role === UserRole::HealthWorker
    && ! $user->is_active
) {
    throw ValidationException::withMessages([
        $errorField => ['تم تعطيل حساب الموظف الصحي. يرجى التواصل مع الإدارة.'],
    ]);
}

        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'user' => $user->load([
                'patientProfile',
                'patients.patientProfile',
                'guardians.patientProfile',
                'hospitals',
            ]),
            'token' => $token,
        ];
    }
}