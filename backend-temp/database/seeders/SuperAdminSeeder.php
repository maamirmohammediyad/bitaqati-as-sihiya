<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        $nationalId = env('SUPERADMIN_NATIONAL_ID');
        $name = env('SUPERADMIN_NAME', 'DZ-HEALTH Super Admin');
        $email = env('SUPERADMIN_EMAIL');
        $password = env('SUPERADMIN_PASSWORD');

        if (!$nationalId || !$email || !$password) {
            throw new \RuntimeException(
                'SUPERADMIN_NATIONAL_ID, SUPERADMIN_EMAIL and SUPERADMIN_PASSWORD must be set.'
            );
        }

        DB::table('users')->updateOrInsert(
            ['national_id' => $nationalId],
            [
                'id' => (string) Str::uuid(),
                'name' => $name,
                'email' => $email,
                'phone' => null,
                'phone_verified_at' => null,
                'password' => Hash::make($password),
                'role' => 'super_admin',
                'patient_code' => null,
                'is_active' => true,
                'email_verified_at' => now(),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );
    }
}