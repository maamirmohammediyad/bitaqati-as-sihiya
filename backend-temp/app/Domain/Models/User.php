<?php

declare(strict_types=1);

namespace App\Domain\Models;
use App\Domain\Models\HospitalPatientScanNote;
use App\Domain\Enums\UserRole;
use App\Http\Middleware\CheckRole;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Domain\Models\MedicalFile;
use App\Domain\Enums\HospitalUserRole;
use App\Domain\Models\HospitalUser;
use App\Notifications\CustomResetPasswordNotification;
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, HasUuids, Notifiable;

    protected $table = 'users';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'name',
        'email',
        'national_id',
        'phone',
        'password',
        'role',
        'patient_code',
        'employee_code',
        'is_active',
        'email_verified_at',
        'phone_verified_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'password' => 'hashed',
            'role' => UserRole::class,
            'is_active' => 'boolean',
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (User $user): void {
            if ($user->role === UserRole::Patient && empty($user->patient_code)) {
                $user->patient_code = self::generatePatientCode();
            }
        });
    }

    public static function generatePatientCode(): string
    {
        $prefix = config('health.patient_code_prefix', 'BQS');
        $length = config('health.patient_code_length', 10);
        $codeLength = $length - strlen($prefix);

        do {
            $code = $prefix . strtoupper(substr(bin2hex(random_bytes(4)), 0, $codeLength));
        } while (self::where('patient_code', $code)->exists());

        return $code;
    }

    public function patientProfile(): HasOne
    {
        return $this->hasOne(PatientProfile::class);
    }

    public function guardians(): BelongsToMany
    {
        return $this->belongsToMany(
            User::class,
            'guardian_patient',
            'patient_id',
            'guardian_id',
        )
            ->using(GuardianPatient::class)
            ->withPivot(['id', 'relationship', 'can_access_location', 'is_verified', 'verified_at'])
            ->withTimestamps();
    }
    
    public function medicalFiles()
    {
    return $this->hasMany(MedicalFile::class, 'user_id');
    }

    public function patients(): BelongsToMany
    {
        return $this->belongsToMany(
            User::class,
            'guardian_patient',
            'guardian_id',
            'patient_id',
        )
            ->using(GuardianPatient::class)
            ->withPivot(['id', 'relationship', 'can_access_location', 'is_verified', 'verified_at'])
            ->withTimestamps();
    }

    // public function medicalFiles(): HasMany
    // {
    //     return $this->hasMany(MedicalFile::class);
    // }

    public function deviceTokens(): HasMany
    {
        return $this->hasMany(DeviceToken::class);
    }

    public function auditLogs(): HasMany
    {
        return $this->hasMany(AuditLog::class);
    }

    public function emergencyEvents(): HasMany
    {
        return $this->hasMany(EmergencyEvent::class);
    }

    public function emergencyContacts(): HasMany
    {
        return $this->hasMany(EmergencyContact::class);
    }
public function hospitals(): BelongsToMany
{
    return $this->belongsToMany(
        Hospital::class,
        'hospital_users',
        'user_id',
        'hospital_id',
    )
        ->using(HospitalUser::class)
        ->withPivot([
            'id',
            'role',
            'is_active',
            'joined_at',
        ])
        ->withCasts([
            'role' => HospitalUserRole::class,
            'is_active' => 'boolean',
            'joined_at' => 'datetime',
        ])
        ->withTimestamps();
}
    protected static function newFactory(): UserFactory
    {
        return UserFactory::new();
    }
   public function hospitalUsers(): HasMany
{
    return $this->hasMany(HospitalUser::class, 'user_id');
}
public function sendPasswordResetNotification($token): void
{
    $this->notify(
        new CustomResetPasswordNotification($token)
    );
}

public function isHealthWorker(): bool
{
    return $this->role === UserRole::HealthWorker;
}

public function isPatient(): bool
{
    return $this->role === UserRole::Patient;
}

public function isGuardian(): bool
{
    return $this->role === UserRole::Guardian;
}
public function hospitalScanNotes(): HasMany
{
    return $this->hasMany(
        HospitalPatientScanNote::class,
        'created_by_user_id',
    );
}

public function receivedHospitalScanNotes(): HasMany
{
    return $this->hasMany(
        HospitalPatientScanNote::class,
        'patient_id',
    );
}

public function prescribedMedications(): HasMany
{
    return $this->hasMany(
        HospitalMedication::class,
        'created_by'
    );
}

public function patientMedications(): HasMany
{
    return $this->hasMany(
        PatientMedication::class,
        'patient_id'
    );
}

public function addedPatientMedications(): HasMany
{
    return $this->hasMany(
        PatientMedication::class,
        'added_by'
    );
}

public function accountVerificationDocument(): HasOne
{
    return $this->hasOne(AccountVerificationDocument::class);
}
}
