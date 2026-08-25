<?php

declare(strict_types=1);

use App\Http\Controllers\Api\Admin\HospitalController as AdminHospitalController;

use App\Http\Controllers\Api\Admin\AccountVerificationDocumentController;
use App\Http\Controllers\Api\HospitalEmergencyController;
use App\Http\Controllers\Api\HospitalPatientQrController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\Auth\PasswordResetController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EmergencyController;
use App\Http\Controllers\Api\HospitalController;
use App\Http\Controllers\Api\HospitalDashboardController;
use App\Http\Controllers\Api\HospitalMedicalFileController;
use App\Http\Controllers\Api\HospitalPatientController;
use App\Http\Controllers\Api\HospitalStaffController;
use App\Http\Controllers\Api\PatientController;
use App\Http\Controllers\Api\PatientQrController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\HospitalPatientRecordController;
use App\Http\Controllers\HospitalMedicationController;
use App\Http\Controllers\PatientMedicationController;
use App\Http\Controllers\Api\AccountRecoveryController;
/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/

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

Route::post('/auth/forgot-password', [
    PasswordResetController::class,
    'forgotPassword',
]);

Route::post('/auth/reset-password', [
    PasswordResetController::class,
    'resetPassword',
]);

Route::post(
    'auth/account-recovery-requests',
    [AccountRecoveryController::class, 'store'],
);

Route::post(
    'auth/account-recovery/complete',
    [AccountRecoveryController::class, 'complete'],
);

/*
|--------------------------------------------------------------------------
| Authenticated Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->group(function (): void {
    /*
    |--------------------------------------------------------------------------
    | Authentication
    |--------------------------------------------------------------------------
    */

    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('auth/me', [AuthController::class, 'me']);
    Route::put('auth/profile', [AuthController::class, 'updateProfile']);
    Route::put('auth/password', [AuthController::class, 'updatePassword']);
    Route::post(
    '/account-verification-document',
    [PatientController::class, 'uploadAccountVerificationDocument'],
);

Route::get(
    'account-verification-document',
    [PatientController::class, 'show']
);

    Route::middleware('role:guardian')->get('/test-role', function () {
        return response()->json([
            'ok' => true,
        ]);
    });

    /*
    |--------------------------------------------------------------------------
    | Public hospital directory for authenticated users
    |--------------------------------------------------------------------------
    */

    Route::get('hospitals/nearby', [HospitalController::class, 'nearby']);

    /*
    |--------------------------------------------------------------------------
    | Hospital staff management: Admin only
    |--------------------------------------------------------------------------
    */

    Route::middleware([
        'role:health_worker',
        'hospital.staff:admin',
    ])->group(function (): void {
        Route::post(
            'hospital/staff',
            [HospitalStaffController::class, 'store'],
        );

        Route::get(
            'hospital/staff',
            [HospitalStaffController::class, 'index'],
        );

        Route::patch(
            'hospital/staff/{id}',
            [HospitalStaffController::class, 'update'],
        )->whereUuid('id');

        /*
         * سجل كل عمليات QR داخل المستشفى.
         * يدعم employee_id فقط للإداري كي يستطيع فلترة السجل بحسب الموظف.
         */
        Route::get(
            'hospital/patients',
            [HospitalPatientController::class, 'index'],
        );
    });

    /*
    |--------------------------------------------------------------------------
    | Personal QR scan history: All active hospital staff
    |--------------------------------------------------------------------------
    */

    Route::middleware([
        'role:health_worker',
        'hospital.staff:admin,receptionist,doctor,nurse,staff',
    ])->group(function (): void {
        Route::get(
            'hospital/my-scanned-patients',
            [HospitalPatientController::class, 'myScans'],
        );
        Route::get(
            'hospital/patient-qr/{token}',
            [PatientQrController::class, 'showForHospitalStaff'],
        );
Route::post(
    'hospital/patients/scan-qr',
    [HospitalPatientQrController::class, 'scan'],
);

Route::get(
    'hospital/patients/{patient}',
    [HospitalPatientQrController::class, 'show'],
)->whereUuid('patient');
    });
/*
|--------------------------------------------------------------------------
| Medical files: read-only for hospital admin and staff
|--------------------------------------------------------------------------
*/

Route::middleware([
    'role:health_worker',
    'hospital.staff:admin,receptionist,doctor,nurse,staff',
])->prefix('hospital/patients/{patient}')->group(function (): void {
    Route::get(
        'medical-files',
        [HospitalMedicalFileController::class, 'index'],
    )->whereUuid('patient');

    Route::get(
        'medical-files/{medicalFile}/download',
        [HospitalMedicalFileController::class, 'download'],
    )->whereUuid('medicalFile');
});


/*
|--------------------------------------------------------------------------
| Medical files: modifications for doctors only
|--------------------------------------------------------------------------
*/

Route::middleware([
    'role:health_worker',
    'hospital.staff:doctor',
])->prefix('hospital/patients/{patient}')->group(function (): void {
    Route::post(
        'medical-files',
        [HospitalMedicalFileController::class, 'store'],
    )->whereUuid('patient');

    Route::delete(
        'medical-files/{medicalFile}',
        [HospitalMedicalFileController::class, 'destroy'],
    )->whereUuid('medicalFile');
});
/*
|--------------------------------------------------------------------------
| Hospital patient medical record - read access
|--------------------------------------------------------------------------
*/

Route::middleware([
    'role:health_worker',
    'hospital.staff:admin,receptionist,doctor,nurse,staff',
])->prefix('hospital/patients/{patient}')->group(function (): void {
    Route::get(
        'medical-record',
        [HospitalPatientRecordController::class, 'show'],
    )->whereUuid('patient');

    Route::get(
        'scan-history',
        [HospitalPatientRecordController::class, 'scanHistory'],
    )->whereUuid('patient');

    Route::get(
        'notes',
        [HospitalPatientRecordController::class, 'notes'],
    )->whereUuid('patient');

});

/*
|--------------------------------------------------------------------------
| Hospital patient notes - write access
|--------------------------------------------------------------------------
*/

Route::middleware([
    'role:health_worker',
    'hospital.staff:admin,doctor,nurse',
])->prefix('hospital/patients/{patient}')->group(function (): void {
    Route::post(
        'notes',
        [HospitalPatientRecordController::class, 'storeNote'],
    )->whereUuid('patient');

    Route::delete(
        'notes/{note}',
        [HospitalPatientRecordController::class, 'destroyNote'],
    )->whereUuid(['patient', 'note']);
});
/*
|--------------------------------------------------------------------------
| Hospital medications catalog
|--------------------------------------------------------------------------
*/

Route::middleware('role:health_worker,hospital.staff:admin,doctor')->group(function (): void {
    Route::get(
        'hospital/medications',
        [HospitalMedicationController::class, 'index']
    );

    Route::post(
        'hospital/medications',
        [HospitalMedicationController::class, 'store']
    );

    Route::patch(
        'hospital/medications/{medication}',
        [HospitalMedicationController::class, 'update']
    )->whereUuid('medication');

    Route::delete(
        'hospital/medications/{medication}',
        [HospitalMedicationController::class, 'destroy']
    )->whereUuid('medication');
});

/*
|--------------------------------------------------------------------------
| Patient medication assignments
|--------------------------------------------------------------------------
*/

Route::middleware('role:health_worker,hospital.staff:admin,receptionist,doctor,nurse,staff')
    ->prefix('hospital/patients/{patient}')
    ->group(function (): void {
        Route::get(
            'medications',
            [PatientMedicationController::class, 'index']
        )->whereUuid('patient');
    });

Route::middleware('role:health_worker,hospital.staff:admin,doctor')
    ->prefix('hospital/patients/{patient}')
    ->group(function (): void {
        Route::post(
            'medications',
            [PatientMedicationController::class, 'store']
        )->whereUuid('patient');

        Route::delete(
            'medications/{patientMedication}',
            [PatientMedicationController::class, 'destroy']
        )->whereUuid(['patient', 'patientMedication']);
    });
/*
|--------------------------------------------------------------------------
| Hospital patient medication update
|--------------------------------------------------------------------------
*/

Route::middleware([
    'role:health_worker',
    'hospital.staff:admin,doctor',
])->prefix('hospital/patients/{patient}')->group(function (): void {
    Route::put(
        'medications',
        [HospitalPatientRecordController::class, 'updateMedications'],
    )->whereUuid('patient');
});
    /*
    |--------------------------------------------------------------------------
    | Hospital dashboard and emergencies
    |--------------------------------------------------------------------------
    */

    Route::middleware([
        'role:health_worker',
        'hospital.staff:admin,receptionist,doctor,nurse,staff',
    ])->group(function (): void {
        Route::get(
            'hospital/dashboard',
            [HospitalDashboardController::class, 'index'],
        );

        Route::get(
            'hospital/emergencies',
            [HospitalEmergencyController::class, 'index'],
        );

        Route::get(
            'hospital/emergencies/{id}',
            [HospitalEmergencyController::class, 'show'],
        )->whereUuid('id');

        Route::get(
            'hospital/emergencies/{id}/notes',
            [HospitalEmergencyController::class, 'notes'],
        )->whereUuid('id');
    });

    /*
    |--------------------------------------------------------------------------
    | Hospital emergency actions
    |--------------------------------------------------------------------------
    */

    Route::middleware([
    'role:health_worker',
    'hospital.staff:admin,receptionist,doctor,nurse,staff',
])->group(function (): void {
    Route::post(
    'hospital/emergencies/scan-qr',
    [HospitalEmergencyController::class, 'scanPatientQrForEmergency']
);
        Route::post(
    'hospital/emergencies/{id}/scan',
    [EmergencyController::class, 'checkIn'],
)->whereUuid('id');
    Route::post(
            'emergency/{id}/check-in',
            [EmergencyController::class, 'checkIn'],
        )->whereUuid('id');
    });

    Route::middleware([
        'role:health_worker',
        'hospital.staff:admin,doctor,nurse',
    ])->group(function (): void {
Route::post(
    'hospital/emergencies/{emergency}/resolve',
    [HospitalEmergencyController::class, 'resolve']
)->whereUuid('emergency');

        Route::post(
            'hospital/emergencies/{id}/notes',
            [HospitalEmergencyController::class, 'storeNote'],
        )->whereUuid('id');
    });

    /*
    |--------------------------------------------------------------------------
    | Patient QR token and patient records
    |--------------------------------------------------------------------------
    */

    Route::post('patient/qr-token', [PatientQrController::class, 'issue']);
    Route::get('patient/qr/{token}', [PatientQrController::class, 'show']);

    Route::put('patient/email', [PatientController::class, 'updateMyEmail']);
    Route::post('patient/profile/complete', [PatientController::class, 'completeProfile']);
    Route::get('patient/profile', [PatientController::class, 'showProfile']);
    Route::get('patient/medical-files', [PatientController::class, 'myMedicalFiles']);
    Route::get('patient/emergencies', [PatientController::class, 'myEmergencies']);
    Route::get('patient/medications', [PatientMedicationController::class, 'myMedications']);
    /*
    |--------------------------------------------------------------------------
    | Patient / guardian emergency routes
    |--------------------------------------------------------------------------
    */

    Route::get('emergency/current', [EmergencyController::class, 'current']);
    Route::get('emergency/history', [EmergencyController::class, 'history']);
    Route::get('emergency/guardians', [EmergencyController::class, 'guardians']);
    Route::post('emergency/sos', [EmergencyController::class, 'trigger']);

    Route::delete(
        'emergency/{id}/cancel',
        [EmergencyController::class, 'cancel'],
    )->whereUuid('id');

    Route::get(
        'emergency/{id}',
        [EmergencyController::class, 'show'],
    )->whereUuid('id');

    /*
    |--------------------------------------------------------------------------
    | Guardian routes
    |--------------------------------------------------------------------------
    */

    Route::get('guardian/patients', [PatientController::class, 'myPatients']);

    Route::post(
        'guardian/patient/{id}/qr-token',
        [PatientQrController::class, 'issueForGuardian'],
    )->whereUuid('id');

    Route::get(
        'guardian/patient/{id}/dashboard',
        [PatientController::class, 'guardianPatientDashboard'],
    )->whereUuid('id');

    Route::get(
        'guardian/patient/{id}/medical-files',
        [PatientController::class, 'patientMedicalFiles'],
    )->whereUuid('id');

    Route::post(
        'guardian/patient/{id}/medical-files',
        [PatientController::class, 'uploadMedicalFile'],
    )->whereUuid('id');

    Route::get(
        'guardian/patient/{id}/emergencies',
        [PatientController::class, 'guardianPatientEmergencies'],
    )->whereUuid('id');

    Route::get(
        'guardian/patient/{patientId}/emergencies/{eventId}',
        [PatientController::class, 'guardianPatientEmergencyDetail'],
    )->whereUuid(['patientId', 'eventId']);

    Route::post(
        'guardian/patient/{patientId}/emergencies/{eventId}/read',
        [PatientController::class, 'markGuardianEmergencyAsRead'],
    )->whereUuid(['patientId', 'eventId']);

    Route::get(
        'guardian/patient/{id}',
        [PatientController::class, 'guardianShowPatient'],
    )->whereUuid('id');

    /*
    |--------------------------------------------------------------------------
    | Super admin
    |--------------------------------------------------------------------------
    */

    Route::prefix('admin')
        ->middleware('role:super_admin')
        ->group(function (): void {
            Route::get('hospitals', [AdminHospitalController::class, 'index']);
            Route::post('hospitals', [AdminHospitalController::class, 'store']);

            Route::get(
                'hospitals/{hospital}',
                [AdminHospitalController::class, 'show'],
            )->whereUuid('hospital');

            Route::put(
                'hospitals/{hospital}',
                [AdminHospitalController::class, 'update'],
            )->whereUuid('hospital');

            Route::delete(
                'hospitals/{hospital}',
                [AdminHospitalController::class, 'destroy'],
            )->whereUuid('hospital');

            Route::post(
                'hospitals/{hospital}/admins',
                [AdminHospitalController::class, 'storeAdmin'],
            )->whereUuid('hospital');

            Route::get('users', [AdminController::class, 'users'])
                ->name('admin.users');

            Route::post('users', [AdminController::class, 'storeUser']);

            Route::put(
                'users/{user}',
                [AdminController::class, 'updateUser'],
            )->whereUuid('user');

            Route::delete(
                'users/{user}',
                [AdminController::class, 'destroyUser'],
            )->whereUuid('user');

            Route::get(
                'emergency-events',
                [AdminController::class, 'emergencyEvents'],
            );
            Route::get(
    'account-recovery-requests',
    [AccountRecoveryController::class, 'index'],
);

Route::get(
    'account-recovery-requests/{accountRecoveryRequest}/identity-document',
    [AccountRecoveryController::class, 'showIdentityDocument'],
)->whereUuid('accountRecoveryRequest');

 Route::patch(
            'account-recovery-requests/{accountRecoveryRequest}/review',
            [AccountRecoveryController::class, 'review']
        );
Route::get(
    'account-verification-documents',
    [AccountVerificationDocumentController::class, 'index'],
);

Route::get(
    'account-verification-documents/{document}',
    [AccountVerificationDocumentController::class, 'show'],
)->whereUuid('document');

Route::patch(
    'account-verification-documents/{document}/review',
    [AccountVerificationDocumentController::class, 'review'],
)->whereUuid('document');

Route::get(
    'account-verification-documents/{document}/document',
    [AccountVerificationDocumentController::class, 'showDocument'],
)->whereUuid('document');
        });

    /*
    |--------------------------------------------------------------------------
    | Notifications
    |--------------------------------------------------------------------------
    */

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