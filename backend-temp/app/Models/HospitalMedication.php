<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class HospitalMedication extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'hospital_id',
        'created_by',
        'name',
        'generic_name',
        'recommended_doses',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'recommended_doses' => 'array',
            'is_active' => 'boolean',
        ];
    }

    public function hospital(): BelongsTo
    {
        return $this->belongsTo(Hospital::class);
    }

    public function createdBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function patientMedications(): HasMany
    {
        return $this->hasMany(PatientMedication::class);
    }
}