<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Domain\Models\HospitalUser;
use App\Domain\Models\HospitalPatientQrScan;
use App\Domain\Models\PatientQrToken;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
class HospitalPatientQrController extends Controller
{
public function scan(Request $request): JsonResponse
{
    $validated = $request->validate([
        'token' => ['required', 'string', 'max:4096'],
    ]);

    /** @var User|null $staff */
/** @var User|null $staff */
$staff = $request->user();

abort_if($staff === null, 401, 'يرجى تسجيل الدخول أولاً.');

$hospitalMembership = HospitalUser::query()
    ->where('user_id', $staff->id)
    ->where('is_active', true)
    ->whereIn('role', [
        'admin',
        'receptionist',
        'doctor',
        'nurse',
        'staff',
    ])
    ->first();

abort_unless(
    $hospitalMembership !== null,
    403,
    'حسابك غير مرتبط بمستشفى نشط أو لا يملك صلاحية مسح QR.'
);

$hospitalId = $hospitalMembership->hospital_id;

    $token = trim($validated['token']);

    $qr = PatientQrToken::query()
        ->with([
            'user.patientProfile:user_id,full_name,blood_group,allergies,chronic_diseases,medications,emergency_notes',
        ])
        ->where('token', hash('sha256', $token))
        ->where('expires_at', '>', now())
        ->whereNull('used_at')
        ->first();

    if ($qr === null || ! $qr->isValid()) {
        throw ValidationException::withMessages([
            'token' => ['رمز QR غير صالح أو منتهي الصلاحية أو تم استخدامه مسبقًا.'],
        ]);
    }

    $patient = $qr->user;

    if ($patient === null || $patient->role?->value !== 'patient') {
        throw ValidationException::withMessages([
            'token' => ['لا يوجد مريض صالح مرتبط بهذا الرمز.'],
        ]);
    }

    $result = DB::transaction(function () use (
        $qr,
        $patient,
        $hospitalId,
        $staff
    ): array {
        $lockedQr = PatientQrToken::query()
            ->whereKey($qr->id)
            ->lockForUpdate()
            ->firstOrFail();

        if (! $lockedQr->isValid()) {
            throw ValidationException::withMessages([
                'token' => ['رمز QR غير صالح أو منتهي الصلاحية أو تم استخدامه مسبقًا.'],
            ]);
        }

        $scan = HospitalPatientQrScan::query()->create([
            'hospital_id' => $hospitalId,
            'patient_id' => $patient->id,
            'scanned_by_user_id' => $staff->id,
            'patient_qr_token_id' => $lockedQr->id,
            'scanned_at' => now(),
        ]);

        $lockedQr->update([
            'used_at' => now(),
        ]);

        $scanStats = HospitalPatientQrScan::query()
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patient->id)
            ->where('scanned_by_user_id', $staff->id)
            ->selectRaw('COUNT(*) as scan_count, MAX(scanned_at) as last_scanned_at')
            ->first();

        return [
            'scan' => $scan,
            'scan_count' => (int) ($scanStats?->scan_count ?? 1),
            'last_scanned_at' => $scanStats?->last_scanned_at,
        ];
    });

    return response()->json([
        'message' => 'تم مسح رمز QR بنجاح.',
        'data' => [
            'scan_id' => (string) $result['scan']->id,
            'scan_count' => $result['scan_count'],
            'last_scanned_at' => $result['last_scanned_at'],
            'patient' => $this->patientData($patient),
        ],
    ], 201);
}

public function show(Request $request, string $patient): JsonResponse
{
    $staff = $request->user();

    abort_unless(
        $staff !== null && $staff->role?->value === 'health_worker',
        403,
        'غير مصرح لك بالوصول إلى بيانات المريض.',
    );

    $hospitalId = HospitalUser::query()
        ->where('user_id', $staff->id)
        ->where('is_active', true)
        ->whereIn('role', [
            'admin',
            'receptionist',
            'doctor',
            'nurse',
            'staff',
        ])
        ->value('hospital_id');

    abort_if(
        empty($hospitalId),
        403,
        'لا يوجد مستشفى نشط مرتبط بحساب الموظف.',
    );

    $hospitalId = (string) $hospitalId;

    $hasScan = HospitalPatientQrScan::query()
        ->where('hospital_id', $hospitalId)
        ->where('patient_id', $patient)
        ->where('scanned_by_user_id', $staff->id)
        ->exists();

    abort_unless(
        $hasScan,
        403,
        'لا يمكنك الوصول إلى بيانات هذا المريض قبل مسح رمز QR الخاص به.',
    );

    $patientModel = User::query()
        ->with(
            'patientProfile:user_id,full_name,blood_group,allergies,chronic_diseases,medications,emergency_notes',
        )
        ->whereKey($patient)
        ->where('role', 'patient')
        ->firstOrFail();

    $scanStats = HospitalPatientQrScan::query()
        ->where('hospital_id', $hospitalId)
        ->where('patient_id', $patientModel->id)
        ->where('scanned_by_user_id', $staff->id)
        ->selectRaw('COUNT(*) as scan_count, MAX(scanned_at) as last_scanned_at')
        ->first();

    return response()->json([
        'data' => [
            'patient' => $this->patientData($patientModel),
            'scan_count' => (int) ($scanStats?->scan_count ?? 0),
            'last_scanned_at' => $scanStats?->last_scanned_at,
        ],
    ]);
}

    private function patientData(User $patient): array
    {
        $profile = $patient->patientProfile;

        return [
            'id' => (string) $patient->id,
            'name' => $profile?->full_name ?? $patient->name,
            'patient_code' => $patient->patient_code,
            'phone' => $patient->phone,
            'blood_group' => $profile?->blood_group?->value,
            'allergies' => $profile?->allergies,
            'chronic_diseases' => $profile?->chronic_diseases,
            'medications' => $profile?->medications,
            'emergency_notes' => $profile?->emergency_notes,
        ];
    }
}