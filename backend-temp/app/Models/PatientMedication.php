<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PatientMedication extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'patient_id',
        'hospital_medication_id',
        'dose',
        'instructions',
        'added_by',
    ];

    public function patient(): BelongsTo
{
    return $this->belongsTo(User::class, 'patient_id');
}

    public function hospitalMedication(): BelongsTo
    {
        return $this->belongsTo(HospitalMedication::class);
    }

    public function addedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'added_by');
    }
}