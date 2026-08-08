# Laravel API Architecture & Folder Structure

## Feature-Based Module Structure

```
backend/
├── app/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── User.php
│   │   │   ├── PatientProfile.php
│   │   │   ├── GuardianPatient.php
│   │   │   ├── MedicalFile.php
│   │   │   ├── EmergencyContact.php
│   │   │   ├── EmergencyEvent.php
│   │   │   ├── DeviceToken.php
│   │   │   ├── AuditLog.php
│   │   │   ├── Hospital.php
│   │   │   └── PatientQrToken.php
│   │   ├── Actions/
│   │   │   ├── Auth/
│   │   │   │   ├── RegisterPatientAction.php
│   │   │   │   ├── RegisterGuardianAction.php
│   │   │   │   ├── LoginAction.php
│   │   │   │   └── LinkPatientAction.php
│   │   │   ├── Patient/
│   │   │   │   ├── CompleteProfileAction.php
│   │   │   │   ├── UpdateProfileAction.php
│   │   │   │   └── GetHealthCardAction.php
│   │   │   ├── Guardian/
│   │   │   │   └── GetPatientsAction.php
│   │   │   ├── MedicalFile/
│   │   │   │   ├── UploadFileAction.php
│   │   │   │   └── DeleteFileAction.php
│   │   │   ├── Emergency/
│   │   │   │   ├── TriggerSosAction.php
│   │   │   │   └── ResolveEmergencyAction.php
│   │   │   └── Hospital/
│   │   │       └── FindNearestHospitalsAction.php
│   │   └── Enums/
│   │       ├── UserRole.php
│   │       ├── BloodGroup.php
│   │       ├── Gender.php
│   │       ├── FileType.php
│   │       ├── Relationship.php
│   │       └── DeviceType.php
│   │
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       ├── AuthController.php
│   │   │       ├── PatientProfileController.php
│   │   │       ├── GuardianController.php
│   │   │       ├── MedicalFileController.php
│   │   │       ├── EmergencyContactController.php
│   │   │       ├── EmergencyController.php
│   │   │       ├── HealthCardController.php
│   │   │       ├── HospitalController.php
│   │   │       └── Admin/
│   │   │           ├── UserController.php
│   │   │           ├── PatientController.php
│   │   │           ├── GuardianController.php
│   │   │           ├── MedicalFileController.php
│   │   │           └── EmergencyController.php
│   │   ├── Requests/
│   │   │   ├── Auth/
│   │   │   │   ├── RegisterPatientRequest.php
│   │   │   │   ├── RegisterGuardianRequest.php
│   │   │   │   ├── LoginRequest.php
│   │   │   │   └── LinkPatientRequest.php
│   │   │   ├── Patient/
│   │   │   │   ├── CompleteProfileRequest.php
│   │   │   │   └── UpdateProfileRequest.php
│   │   │   ├── MedicalFile/
│   │   │   │   └── UploadFileRequest.php
│   │   │   ├── EmergencyContact/
│   │   │   │   └── StoreEmergencyContactRequest.php
│   │   │   └── Emergency/
│   │   │       └── TriggerSosRequest.php
│   │   └── Resources/
│   │       ├── UserResource.php
│   │       ├── PatientProfileResource.php
│   │       ├── MedicalFileResource.php
│   │       ├── EmergencyContactResource.php
│   │       ├── EmergencyEventResource.php
│   │       ├── HealthCardResource.php
│   │       ├── HospitalResource.php
│   │       └── AuditLogResource.php
│   │
│   ├── Services/
│   │   ├── SupabaseStorageService.php
│   │   ├── FCMService.php
│   │   ├── AuditLogService.php
│   │   └── QRTokenService.php
│   │
│   └── Console/
│       └── Commands/
│           ├── SeedHospitals.php
│           └── CreateAdmin.php
│
├── config/
│   ├── supabase.php
│   └── health.php
│
├── database/
│   ├── migrations/
│   └── seeders/
│
└── routes/
    └── api.php
```

## Layer Responsibilities

### Domain Layer (`app/Domain/`)

- **Models:** Eloquent models with relationships, casts, and accessors/mutators. No business logic beyond what Eloquent provides.
- **Actions:** Single-responsibility classes that encapsulate business logic. Each action has one public method (usually `execute()` or `handle()`).
- **Enums:** Backed enums for type-safe role, blood group, etc.

**Rule:** Actions should NOT know about HTTP concerns (requests, responses, status codes). They return plain values or throw domain exceptions.

### HTTP Layer (`app/Http/`)

- **Controllers:** Thin — parse request, call an Action, return a Resource response. No business logic.
- **Requests (FormRequests):** Validation rules and authorization gates.
- **Resources (API Resources):** Transform models into JSON responses.

### Infrastructure Layer (`app/Services/`)

- Stateless services that interact with external systems.
- SupabaseStorageService: Upload, download, delete files.
- FCMService: Send push notifications via Firebase.
- AuditLogService: Record immutable audit entries.
- QRTokenService: Generate and validate QR tokens.

## Key Conventions

1. **Every Action returns a value or throws an exception.** No returning HTTP responses from Actions.
2. **Validation in FormRequests only.** No manual `$request->validate()` in controllers.
3. **API Resources for every response.** Never return `$model->toArray()` directly.
4. **Encryption happens at the Eloquent model level** using custom casts for sensitive fields.
5. **All database queries go through Eloquent models or Actions** — no raw SQL in controllers.
6. **Error handling via Laravel's exception handler** — custom exceptions for domain errors, HTTP exceptions for API errors.

## Routes Structure (`routes/api.php`)

```php
// Public routes
Route::post('auth/register/patient', [AuthController::class, 'registerPatient']);
Route::post('auth/register/guardian', [AuthController::class, 'registerGuardian']);
Route::post('auth/login', [AuthController::class, 'login']);
Route::post('auth/refresh', [AuthController::class, 'refresh']);
Route::post('auth/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('auth/reset-password', [AuthController::class, 'resetPassword']);

// Public QR health card (no auth — QR token is the auth)
Route::get('health-card/qr/{token}', [HealthCardController::class, 'getByQrToken']);

// Authenticated routes
Route::middleware('auth:api')->group(function () {
    // Auth
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('auth/me', [AuthController::class, 'me']);

    // Patient Profile
    Route::prefix('patient')->middleware('role:patient')->group(function () {
        Route::post('profile/complete', [PatientProfileController::class, 'complete']);
        Route::put('profile', [PatientProfileController::class, 'update']);
        Route::get('profile', [PatientProfileController::class, 'show']);
        Route::post('avatar', [PatientProfileController::class, 'uploadAvatar']);
    });

    // Guardian
    Route::prefix('guardian')->middleware('role:guardian')->group(function () {
        Route::post('link', [GuardianController::class, 'linkPatient']);
        Route::get('patients', [GuardianController::class, 'patients']);
        Route::get('patients/{patient}', [GuardianController::class, 'patientDetail']);
    });

    // Medical Files (patient + guardian)
    Route::prefix('patients/{patient}/files')->middleware('can:manage,patient')->group(function () {
        Route::get('/', [MedicalFileController::class, 'index']);
        Route::post('/', [MedicalFileController::class, 'store']);
        Route::get('/{file}', [MedicalFileController::class, 'show']);
        Route::delete('/{file}', [MedicalFileController::class, 'destroy']);
        Route::get('/{file}/download', [MedicalFileController::class, 'download']);
    });

    // Emergency Contacts
    Route::apiResource('patients/{patient}/emergency-contacts', EmergencyContactController::class)
        ->middleware('can:manage,patient');

    // Emergency / SOS
    Route::prefix('emergency')->group(function () {
        Route::post('sos', [EmergencyController::class, 'triggerSos']);
        Route::post('sos/{event}/resolve', [EmergencyController::class, 'resolve']);
        Route::get('history', [EmergencyController::class, 'history']);
        Route::get('history/{patient}', [EmergencyController::class, 'patientHistory']);
    });

    // Health Card
    Route::get('health-card', [HealthCardController::class, 'show']);
    Route::post('health-card/regenerate-qr', [HealthCardController::class, 'regenerateQr']);

    // Hospitals
    Route::get('hospitals/nearby', [HospitalController::class, 'nearby']);
    Route::get('hospitals/{hospital}', [HospitalController::class, 'show']);

    // Device Tokens (FCM)
    Route::post('device-tokens', [AuthController::class, 'registerDeviceToken']);
    Route::delete('device-tokens/{token}', [AuthController::class, 'removeDeviceToken']);

    // Admin routes
    Route::prefix('admin')->middleware('role:admin')->group(function () {
        Route::get('users', [Admin\UserController::class, 'index']);
        Route::get('users/{user}', [Admin\UserController::class, 'show']);
        Route::put('users/{user}', [Admin\UserController::class, 'update']);
        Route::delete('users/{user}', [Admin\UserController::class, 'destroy']);
        Route::get('patients', [Admin\PatientController::class, 'index']);
        Route::get('patients/{patient}', [Admin\PatientController::class, 'show']);
        Route::get('guardians', [Admin\GuardianController::class, 'index']);
        Route::get('guardians/{guardian}', [Admin\GuardianController::class, 'show']);
        Route::get('files', [Admin\MedicalFileController::class, 'index']);
        Route::delete('files/{file}', [Admin\MedicalFileController::class, 'destroy']);
        Route::get('emergencies', [Admin\EmergencyController::class, 'index']);
        Route::get('emergencies/{event}', [Admin\EmergencyController::class, 'show']);
        Route::get('audit-logs', [Admin\EmergencyController::class, 'auditLogs']);
    });
});
```

## Model Relationships Summary

```php
// User.php
class User extends Authenticatable
{
    public function patientProfile(): HasOne;
    public function guardianPatients(): BelongsToMany;  // pivot: guardian_patient
    public function patientGuardians(): BelongsToMany;  // pivot: guardian_patient
    public function medicalFiles(): HasMany;
    public function deviceTokens(): HasMany;
    public function auditLogs(): HasMany;
    public function emergencyEvents(): HasMany;
    public function emergencyContacts(): HasMany;
}
```

## Middleware

1. **`auth:api`** — Standard JWT auth middleware (Sanctum or tymon/jwt-auth).
2. **`role:patient|guardian|admin`** — Custom middleware checking `$user->role`.
3. **`can:manage,patient`** — Custom authorization gate checking:
   - Is the user the patient themselves?
   - Is the user a guardian linked to this patient?
   - Is the user an admin?
