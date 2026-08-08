<?php

declare(strict_types=1);

namespace App\Domain\Actions\Auth;

use App\Domain\Models\GuardianPatient;
use App\Domain\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class RegisterGuardianAction
{
    public function execute(array $data): array
    {
        return DB::transaction(function () use ($data): array {
            $patient = User::where('patient_code', $data['patient_code'])
                ->where('role', 'patient')
                ->firstOrFail();

            $guardian = User::create([
                'id'           => (string) Str::uuid(),
                'name'         => trim($data['first_name'].' '.$data['last_name']),
                'email'        => $data['email'] ?? null,
                'phone'        => $data['phone'],
                'national_id'  => $data['national_id'],
                'password'     => Hash::make($data['password']),
                'role'         => 'guardian',
                'is_active'    => true,
            ]);

            GuardianPatient::create([
                'guardian_id'        => $guardian->id,
                'patient_id'         => $patient->id,
                'relationship'       => $data['relationship'],
                'can_access_location'=> $data['can_access_location'] ?? false,
            ]);

            $token = $guardian->createToken('auth-token')->plainTextToken;

            return [
                'user'  => $guardian, 
                'token' => $token,
            ];
        });
    }
}