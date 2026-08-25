<?php

declare(strict_types=1);

namespace App\Domain\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HospitalPatientAccess extends Model
{
    use HasUuids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'hospital_id',
        'hospital_user_id',
        'patient_id',
        'reason',
        'accessed_at',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'accessed_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    public function hospital(): BelongsTo
    {
        return $this->belongsTo(Hospital::class);
    }

    public function hospitalUser(): BelongsTo
    {
        return $this->belongsTo(HospitalUser::class);
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'patient_id');
    }
}