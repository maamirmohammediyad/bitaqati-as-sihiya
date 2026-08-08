# Security Best Practices for Medical Data

## 1. Data at Rest Encryption

### Approach: Application-Level Encryption

Laravel's built-in encryption uses AES-256-CBC with an application key. Sensitive health data is encrypted before it ever reaches the database.

```php
// app/Casts/EncryptedMedicalData.php
class EncryptedMedicalData implements CastsAttributes
{
    public function get(Model $model, string $key, mixed $value, array $attributes): mixed
    {
        return $value ? decrypt($value) : null;
    }

    public function set(Model $model, string $key, mixed $value, array $attributes): mixed
    {
        return $value ? encrypt($value) : null;
    }
}

// On the model:
protected $casts = [
    'chronic_diseases' => EncryptedMedicalData::class,
    'allergies' => EncryptedMedicalData::class,
    'current_medications' => EncryptedMedicalData::class,
    'previous_surgeries' => EncryptedMedicalData::class,
    'national_id' => EncryptedMedicalData::class,
];
```

**What to encrypt:**
- ✅ `national_id` — PII
- ✅ `chronic_diseases` — sensitive health data
- ✅ `allergies` — sensitive health data
- ✅ `current_medications` — sensitive health data
- ✅ `previous_surgeries` — sensitive health data

**What NOT to encrypt (kept plaintext for queries/filtering):**
- ❌ `blood_group` — needed for QR / emergency display
- ❌ `height`, `weight` — needed for display
- ❌ `date_of_birth` — needed for age calculation
- ❌ `emergency_phone` — needed for emergency contacts

### Why Not Database-Level Encryption?

Application-level encryption means:
- Even if the database is compromised, health data remains encrypted.
- You can rotate the application key without touching the database.
- PostgreSQL TDE (Transparent Data Encryption) is overkill for MVP and adds complexity.

### Key Management
```dotenv
# .env — NEVER commit this file
APP_KEY=base64:...   # Laravel's encryption key
# Rotate periodically. Store backup in password manager.
```

## 2. Data in Transit Security

| Requirement | Implementation |
|-------------|---------------|
| HTTPS only | Configure in Laravel: `URL::forceScheme('https')`, Nginx/Forge redirect |
| HSTS | Add `Strict-Transport-Security` header |
| API versioning | `/api/v1/...` for future-proofing |
| TLS 1.2+ | Configure on server — disable SSLv3, TLS 1.0, 1.1 |

## 3. Minimizing Sensitive Data Exposure

### QR Code Strategy
- QR code contains ONLY a random UUID token, NOT patient data.
- Scanning the QR calls a public API endpoint that returns minimal emergency info.
- Tokens can be revoked and regenerated.

### Push Notification Strategy
- **Never** include sensitive data in notification payloads.
- Notification body: "Emergency alert for [Patient Name]" — no medical details.
- When tapped, the app fetches data from the authenticated API.

### API Response Principles
- Never return full medical history in list endpoints.
- Always mask/chunk sensitive data in audit logs.
- Use API Resources to explicitly control what fields are exposed.
- `national_id` is masked in all responses: `"***67890"`

### Logging
- Audit logs store `old_values` and `new_values` as JSON, but sensitive fields remain encrypted.
- Server error logs (Laravel log, Sentry) must be configured to redact sensitive data.
- Use Laravel's `context` logging to add non-sensitive identifiers.

## 4. RBAC Implementation

```php
// app/Http/Middleware/CheckRole.php
class CheckRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        if (!in_array($request->user()->role, $roles)) {
            abort(403, 'Unauthorized action.');
        }
        return $next($request);
    }
}

// routes/api.php
Route::middleware('role:admin')->group(function () { ... });
Route::middleware('role:patient')->group(function () { ... });
Route::middleware('role:guardian')->group(function () { ... });
```

### Authorization Gates

```php
// AppServiceProvider.php
Gate::define('manage-patient', function (User $user, User $patient) {
    // Patient managing themselves
    if ($user->id === $patient->id) return true;

    // Guardian linked to this patient
    if ($user->role === 'guardian') {
        return GuardianPatient::where('guardian_id', $user->id)
            ->where('patient_id', $patient->id)
            ->exists();
    }

    // Admin
    if ($user->role === 'admin') return true;

    return false;
});
```

## 5. Rate Limiting

```php
// AppServiceProvider.php or routes
RateLimiter::for('auth', fn ($job) => Limit::perMinute(5)->by($job->input('national_id')));
RateLimiter::for('sos', fn ($job) => Limit::perMinute(2)->by($job->user()->id));
RateLimiter::for('file-upload', fn ($job) => Limit::perMinute(10)->by($job->user()->id));
RateLimiter::for('link-patient', fn ($job) => Limit::perHour(20)->by($job->user()->id));
```

## 6. Input Validation & Security Headers

### Laravel Security Headers (via middleware)
```php
// Kernel.php
protected $middleware = [
    // ...
    \App\Http\Middleware\SecurityHeaders::class,
];

// SecurityHeaders.php
public function handle($request, Closure $next)
{
    $response = $next($request);
    $response->headers->set('X-Frame-Options', 'DENY');
    $response->headers->set('X-Content-Type-Options', 'nosniff');
    $response->headers->set('X-XSS-Protection', '1; mode=block');
    $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
    $response->headers->set('Permissions-Policy', 'geolocation=(self), camera=()');
    return $response;
}
```

### FormRequest Validation
- Always use FormRequest classes — never skip validation.
- Validate national_id format (Saudi: 10 digits).
- Validate phone numbers with country code.
- Validate file types and sizes (max 10MB per file, restrict to allowed MIME types).

## 7. Audit Logging

```php
// app/Services/AuditLogService.php
class AuditLogService
{
    public function log(string $action, ?User $user, ?User $patient, $entity = null, array $oldValues = [], array $newValues = []): void
    {
        // Sanitize: never log raw passwords or full national IDs
        unset($oldValues['password'], $newValues['password']);
        if (isset($oldValues['national_id'])) $oldValues['national_id'] = '***' . substr($oldValues['national_id'], -4);
        if (isset($newValues['national_id'])) $newValues['national_id'] = '***' . substr($newValues['national_id'], -4);

        AuditLog::create([
            'user_id' => $user?->id,
            'patient_id' => $patient?->id,
            'action' => $action,
            'entity_type' => $entity ? get_class($entity) : null,
            'entity_id' => $entity?->id,
            'old_values' => $oldValues,
            'new_values' => $newValues,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }
}
```

**Actions to audit:**
- `profile.created`, `profile.updated`
- `guardian.linked`, `guardian.unlinked`
- `file.uploaded`, `file.deleted`
- `emergency.triggered`, `emergency.resolved`
- `qr_token.regenerated`
- `consent.granted`, `consent.revoked`
- `user.login`, `user.logout`

## 8. Backup & Disaster Recovery

### Database Backups
```bash
# Daily automated backup via cron
pg_dump -U bitaqati bitaqati_db | gzip > /backups/bitaqati_$(date +%Y%m%d).sql.gz

# Encrypt the backup
gpg --encrypt --recipient admin@example.com /backups/bitaqati_*.sql.gz
```

### File Storage Backups
- Supabase Storage has built-in redundancy.
- Enable cross-region replication if critical.

### Recovery Plan
1. **RPO (Recovery Point Objective):** 24 hours (daily backups).
2. **RTO (Recovery Time Objective):** 4 hours.
3. **Procedure:**
   - Restore PostgreSQL from latest backup.
   - Re-deploy Laravel from the last known-good release.
   - Storage files remain in Supabase (no restore needed).
   - Verify data integrity with a smoke test.

### Application Key Backup
- Store `APP_KEY` in a password manager (1Password, Bitwarden).
- Without it, encrypted data cannot be decrypted.

## 9. Right to Access / Delete (Data Subject Requests)

### Access Request
```php
// Admin endpoint to export all data for a user
public function exportUserData(User $user)
{
    $data = [
        'user' => $user->toArray(),
        'profile' => $user->patientProfile?->toArray(),
        'medical_files' => $user->medicalFiles->toArray(),
        'emergency_events' => $user->emergencyEvents->toArray(),
        'audit_logs' => $user->auditLogs->toArray(),
    ];
    // Decrypt sensitive fields for the export
    return response()->json($data);
}
```

### Delete Request
```php
// Soft delete user and all related data
public function deleteUser(User $user)
{
    DB::transaction(function () use ($user) {
        $user->patientProfile()?->delete();
        $user->medicalFiles()->delete();
        $user->deviceTokens()->delete();
        $user->emergencyContacts()->delete();
        $user->delete(); // soft delete
    });
}
```

## 10. Deployment Security Checklist

- [ ] `.env` never in version control
- [ ] `APP_DEBUG=false` in production
- [ ] `APP_ENV=production`
- [ ] HTTPS enforced (Laravel Forge / Nginx)
- [ ] Database accessible only from app server (firewall)
- [ ] Supabase Storage bucket private (not public)
- [ ] FCM API keys restricted to server IP
- [ ] File upload size limits enforced (Nginx + Laravel)
- [ ] CORS configured for specific origins only
- [ ] Failed login attempt monitoring (fail2ban)
- [ ] Regular dependency updates (`composer audit`, `npm audit`)
- [ ] PHP `disable_functions` configured (shell_exec, exec, etc.)
- [ ] Flutter app code obfuscated (`--obfuscate --split-debug-info`)
