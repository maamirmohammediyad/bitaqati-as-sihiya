<?php

declare(strict_types=1);

namespace App\Domain\Models;
use Illuminate\Database\Eloquent\Relations\Pivot;

use App\Domain\Enums\Relationship;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuardianPatient extends Pivot
{
    use HasUuids;

    protected $table = 'guardian_patient';

    protected $primaryKey = 'id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'guardian_id',
        'patient_id',
        'relationship',
        'can_access_location',
        'is_verified',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'guardian_id' => 'string',
            'patient_id' => 'string',
            'relationship' => Relationship::class,
            'can_access_location' => 'boolean',
            'is_verified' => 'boolean',
            'verified_at' => 'datetime',
        ];
    }

    public function guardian(): BelongsTo
    {
        return $this->belongsTo(User::class, 'guardian_id');
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'patient_id');
    }
}