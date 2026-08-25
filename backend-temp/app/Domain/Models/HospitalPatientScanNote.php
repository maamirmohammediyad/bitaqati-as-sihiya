<?php

declare(strict_types=1);

namespace App\Domain\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HospitalPatientScanNote extends Model
{
    use HasUuids;

    protected $table = 'hospital_patient_scan_notes';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'hospital_id',
        'patient_id',
        'hospital_patient_qr_scan_id',
        'created_by_user_id',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'hospital_id' => 'string',
            'patient_id' => 'string',
            'hospital_patient_qr_scan_id' => 'string',
            'created_by_user_id' => 'string',
        ];
    }

    public function scan(): BelongsTo
    {
        return $this->belongsTo(
            HospitalPatientQrScan::class,
            'hospital_patient_qr_scan_id',
        );
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'patient_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by_user_id');
    }

    public function hospital(): BelongsTo
    {
        return $this->belongsTo(Hospital::class, 'hospital_id');
    }
}