<?php

declare(strict_types=1);
use App\Http\Controllers\Api\HospitalStaffController;
use App\Http\Controllers\Api\HospitalEmergencyController;
use App\Http\Controllers\Api\Admin\HospitalController as AdminHospitalController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EmergencyController;
use App\Http\Controllers\Api\HospitalController;
use App\Http\Controllers\Api\PatientController;
use App\Http\Controllers\Api\PatientQrController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\HospitalDashboardController;
// ─── Public Routes ─────────────────────────────────────────────────────────

Route::get('/ping', function () {
    return response()->json([
        'message' => 'pong',
    ]);
});

Route::get('/', function () {
    return response()->json([
        'message' => 'Bitaqati As-Sihiya API',
        'version' => '1.0.0',
    ]);
});

Route::post('auth/register/patient', [AuthController::class, 'registerPatient']);
Route::post('auth/register/guardian', [AuthController::class, 'registerGuardian']);
Route::post('auth/login', [AuthController::class, 'login']);

// ─── Authenticated Routes ──────────────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function (): void {
    // ─── Auth ─────────────────────────────────────────────────────────────

    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('auth/me', [AuthController::class, 'me']);
    Route::put('auth/profile', [AuthController::class, 'updateProfile']);
    Route::put('auth/password', [AuthController::class, 'updatePassword']);

    Route::middleware('role:guardian')->get('/test-role', function () {
        return response()->json([
            'ok' => true,
        ]);
    });

    // ─── Hospitals ────────────────────────────────────────────────────────

    Route::get('hospitals/nearby', [HospitalController::class, 'nearby']);
    Route::post('hospital/staff',[HospitalStaffController::class, 'store'],)->middleware('hospital.staff:admin');
    // ─── Hospital Dashboard ────────────────────────────────────────────────────

    Route::middleware([
    'role:health_worker',
    'hospital.staff:admin,receptionist,doctor,nurse',
])->group(function (): void {
    Route::get(
        'hospital/dashboard',
        [HospitalDashboardController::class, 'index'],
    );

    Route::get(
        'hospital/emergencies',
        [HospitalEmergencyController::class, 'index'],
    );

    Route::post(
        'hospital/emergencies/{id}/resolve',
        [EmergencyController::class, 'resolveByHospital'],
    );
    Route::get(
        'hospital/staff',
        [HospitalStaffController::class, 'index'],
    );
    Route::get(
    'hospital/emergencies/{id}/notes',
    [HospitalEmergencyController::class, 'notes'],
    )->whereUuid('id');

    Route::post(
    'hospital/emergencies/{id}/notes',
    [HospitalEmergencyController::class, 'storeNote'],
)->middleware('hospital.staff:admin,doctor,nurse')
  ->whereUuid('id');
    Route::get(
    'hospital/emergencies/{id}',
    [HospitalEmergencyController::class, 'show'],
    )->whereUuid('id');
});
    
    // ─── Emergency: Patient / Guardian ────────────────────────────────────

    // المسارات الثابتة يجب أن تكون قبل emergency/{id}.
    Route::get('emergency/current', [EmergencyController::class, 'current']);
    Route::get('emergency/history', [EmergencyController::class, 'history']);
    Route::get('emergency/guardians', [EmergencyController::class, 'guardians']);
    Route::post('emergency/sos', [EmergencyController::class, 'trigger']);

    Route::delete('emergency/{id}/cancel', [EmergencyController::class, 'cancel']);
    Route::get('emergency/{id}', [EmergencyController::class, 'show']);

    // ─── Emergency: Hospital Staff ────────────────────────────────────────

    Route::middleware([
        'role:health_worker',
        'hospital.staff:admin,receptionist',
    ])->group(function (): void {
        Route::post(
            'emergency/{id}/check-in',
            [EmergencyController::class, 'checkIn'],
        );
    });
Route::patch(
    'hospital/staff/{id}',
    [HospitalStaffController::class, 'update'],
)->middleware('hospital.staff:admin');
    // ─── Patient QR ───────────────────────────────────────────────────────

    Route::post('patient/qr-token', [PatientQrController::class, 'issue']);
    Route::get('patient/qr/{token}', [PatientQrController::class, 'show']);

    // ─── Patient Profile and Records ──────────────────────────────────────

    Route::put('patient/email', [PatientController::class, 'updateMyEmail']);
    Route::post('patient/profile/complete', [PatientController::class, 'completeProfile']);
    Route::get('patient/profile', [PatientController::class, 'showProfile']);
    Route::get('patient/medical-files', [PatientController::class, 'myMedicalFiles']);
    Route::get('patient/emergencies', [PatientController::class, 'myEmergencies']);

    // ─── Guardian ─────────────────────────────────────────────────────────

    Route::get('guardian/patients', [PatientController::class, 'myPatients']);
    Route::post(
        'guardian/patient/{id}/qr-token',
        [PatientQrController::class, 'issueForGuardian'],
    );

    Route::get(
        'guardian/patient/{id}/dashboard',
        [PatientController::class, 'guardianPatientDashboard'],
    );
    Route::get(
        'guardian/patient/{id}/medical-files',
        [PatientController::class, 'patientMedicalFiles'],
    );
    Route::post(
        'guardian/patient/{id}/medical-files',
        [PatientController::class, 'uploadMedicalFile'],
    );
    Route::get(
        'guardian/patient/{id}/emergencies',
        [PatientController::class, 'guardianPatientEmergencies'],
    );
    Route::get(
        'guardian/patient/{patientId}/emergencies/{eventId}',
        [PatientController::class, 'guardianPatientEmergencyDetail'],
    );
    Route::post(
        'guardian/patient/{patientId}/emergencies/{eventId}/read',
        [PatientController::class, 'markGuardianEmergencyAsRead'],
    );
    Route::get(
        'guardian/patient/{id}',
        [PatientController::class, 'guardianShowPatient'],
    );

    // ─── Super Admin ──────────────────────────────────────────────────────

    Route::prefix('admin')
        ->middleware('role:super_admin')
        ->group(function (): void {
            Route::get('hospitals', [AdminHospitalController::class, 'index']);
            Route::post('hospitals', [AdminHospitalController::class, 'store']);
            Route::get('hospitals/{hospital}', [AdminHospitalController::class, 'show']);
            Route::post(
                'hospitals/{hospital}/admins',
                [AdminHospitalController::class, 'storeAdmin'],
            );

            Route::get('users', [AdminController::class, 'users'])
                ->name('admin.users');

            Route::get(
                'emergency-events',
                [AdminController::class, 'emergencyEvents'],
            );
        });

    // ─── Notifications ────────────────────────────────────────────────────

    Route::post('notifications/register-device', function (Request $request) {
        $request->validate([
            'fcm_token' => ['required', 'string'],
        ]);

        $user = $request->user();
        $user->fcm_token = $request->input('fcm_token');
        $user->save();

        return response()->json([
            'status' => 'ok',
        ]);
    });
});