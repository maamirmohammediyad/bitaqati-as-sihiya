<?php

declare(strict_types=1);
use App\Http\Controllers\Api\Admin\HospitalController as AdminHospitalController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EmergencyController;
use App\Http\Controllers\Api\PatientController;
use App\Http\Controllers\Api\AdminController;
use Illuminate\Support\Facades\Route;
use App\Http\Middleware\CheckRole;
use App\Http\Controllers\Api\PatientQrController;
use App\Http\Controllers\Api\HospitalController;
// Health check
Route::get('/ping', function () {
    return response()->json(['message' => 'pong']);
});

// API root info
Route::get('/', function () {
    return response()->json([
        'message' => 'Bitaqati As-Sihiya API',
        'version' => '1.0.0',
    ]);
});

// ─── Public Routes ─────────────────────────────────────────────────────────

Route::post('auth/register/patient', [AuthController::class, 'registerPatient']);
Route::post('auth/register/guardian', [AuthController::class, 'registerGuardian']);

// Route لتسجيل الدخول
Route::post('auth/login', [AuthController::class, 'login']);

// ─── Authenticated Routes ──────────────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function (): void {
   Route::middleware(['auth:sanctum', 'role:guardian'])->get('/test-role', function () {
    return response()->json(['ok' => true]);
   });
    // Auth
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('auth/me', [AuthController::class, 'me']);
    // Hospitals
    Route::get('hospitals/nearby', [HospitalController::class, 'nearby']);



    // Emergency
Route::get('emergency/current', [EmergencyController::class, 'current']);
Route::post('emergency/sos', [EmergencyController::class, 'trigger']);
Route::delete('emergency/{id}/cancel', [EmergencyController::class, 'cancel']);
Route::get('emergency/history', [EmergencyController::class, 'history']);
Route::get('emergency/{id}', [EmergencyController::class, 'show']);
Route::get('emergency/guardians', [EmergencyController::class, 'guardians']);
Route::middleware([
    'auth:sanctum',
    'role:health_worker',
])->group(function (): void {
    Route::post(
        'emergency/{id}/check-in',
        [EmergencyController::class, 'checkIn'],
    );
});
    Route::post('/emergency/trigger', [EmergencyController::class, 'trigger']);
    // Patient QR
    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('patient/qr-token', [PatientQrController::class, 'issue']);
        Route::get('patient/qr/{token}', [PatientQrController::class, 'show']);
    });
Route::put(
    'patient/email',
    [PatientController::class, 'updateMyEmail'],
);
    // Patient own medical files
Route::get('patient/medical-files', [PatientController::class, 'myMedicalFiles']);

// Patient emergencies history (للسجل الطبي)
Route::get('patient/emergencies', [PatientController::class, 'myEmergencies']);
    // Patient Profile (بدون role مؤقتاً)
Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('patient/profile/complete', [PatientController::class, 'completeProfile']);
    Route::get('patient/profile', [PatientController::class, 'showProfile']);
});
Route::middleware(['auth:sanctum', 'role:super_admin'])
    ->prefix('admin')
    ->group(function (): void {
        Route::get('/hospitals', [AdminHospitalController::class, 'index']);
        Route::post('/hospitals', [AdminHospitalController::class, 'store']);
        Route::get('/hospitals/{hospital}', [AdminHospitalController::class, 'show']);
        Route::post('/hospitals/{hospital}/admins', [AdminHospitalController::class, 'storeAdmin']);
    });

    // Guardian
Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('guardian/patients', [PatientController::class, 'myPatients']);
    Route::get('guardian/patient/{id}', [PatientController::class, 'guardianShowPatient']);
    Route::get('guardian/patient/{id}/dashboard', [PatientController::class, 'guardianPatientDashboard']);
    Route::get('guardian/patient/{id}/medical-files', [PatientController::class, 'patientMedicalFiles']);
    Route::post('guardian/patient/{id}/medical-files', [PatientController::class, 'uploadMedicalFile']);
    Route::get('guardian/patient/{id}/emergencies', [PatientController::class, 'guardianPatientEmergencies']);
    Route::get('guardian/patient/{patientId}/emergencies/{eventId}',[PatientController::class, 'guardianPatientEmergencyDetail']);

    Route::post('guardian/patient/{patientId}/emergencies/{eventId}/read',[PatientController::class, 'markGuardianEmergencyAsRead']);
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('guardian/patient/{id}/qr-token', [PatientQrController::class, 'issueForGuardian']);
    Route::put('auth/profile', [AuthController::class, 'updateProfile']);
    Route::put('auth/password', [AuthController::class, 'updatePassword']);
    Route::post(
    'guardian/patient/{id}/qr-token',
    [PatientQrController::class, 'issueForGuardian'],
);
});
    // Admin
Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('admin/users', [AdminController::class, 'users'])->name('admin.users');
    Route::get('admin/emergency-events', [AdminController::class, 'emergencyEvents']);
    Route::middleware([
    'role:health_worker',
    'hospital.staff:admin,receptionist',
])->group(function (): void {
    Route::post(
        'emergency/{id}/check-in',
        [EmergencyController::class, 'checkIn'],
    );
});
});

Route::middleware('auth:sanctum')->post('/notifications/register-device', function (Request $request) {
    $request->validate([
        'fcm_token' => 'required|string',
    ]);

    $user = $request->user();
    $user->fcm_token = $request->fcm_token; 
    $user->save();

    return response()->json([
        'status' => 'ok',
    ]);
});

});