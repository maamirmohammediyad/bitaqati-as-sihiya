<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
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

        $existingUser = DB::table('users')
            ->where('national_id', $nationalId)
            ->first();

        if ($existingUser) {
            // المستخدم موجود: نحدّث بياناته فقط
            // ولا نغيّر الـ UUID الخاص به لأنه مرتبط بجداول أخرى.
            DB::table('users')
                ->where('id', $existingUser->id)
                ->update([
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
                ]);
        } else {
            // المستخدم غير موجود: ننشئه لأول مرة مع UUID جديد.
            DB::table('users')->insert([
                'id' => (string) Str::uuid(),
                'national_id' => $nationalId,
                'name' => $name,
                'email' => $email,
                'phone' => null,
                'phone_verified_at' => null,
                'password' => Hash::make($password),
                'role' => 'super_admin',
                'patient_code' => null,
                'is_active' => true,
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}