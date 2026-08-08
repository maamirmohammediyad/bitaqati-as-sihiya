<?php

declare(strict_types=1);

namespace App\Domain\Models;

use App\Domain\Enums\BloodGroup;
use App\Casts\EncryptedMedicalData;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PatientProfile extends Model
{
    use HasUuids;

    protected $table = 'patient_profiles';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'user_id',
        'full_name',
        'date_of_birth',
        'blood_group',
        'gender',
        'height_cm',
        'weight_kg',
        'allergies',
        'chronic_diseases',
        'medications',
        'emergency_notes',
        'address',
        'city',
        'state',
        'country',
        'postal_code',
        'avatar_url',
        'is_profile_complete',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'user_id' => 'string',
            'date_of_birth' => 'date:Y-m-d',
            'blood_group' => BloodGroup::class,
            'height_cm' => 'float',
            'weight_kg' => 'float',
            'allergies' => EncryptedMedicalData::class,
            'chronic_diseases' => EncryptedMedicalData::class,
            'medications' => EncryptedMedicalData::class,
            'emergency_notes' => 'encrypted',
            'is_profile_complete' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
