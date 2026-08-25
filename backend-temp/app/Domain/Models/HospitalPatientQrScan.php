<?php

declare(strict_types=1);

namespace App\Domain\Models;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HospitalPatientQrScan extends Model
{
    use HasUuids;

    protected $table = 'hospital_patient_qr_scans';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'hospital_id',
        'patient_id',
        'scanned_by_user_id',
        'patient_qr_token_id',
        'scanned_at',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'hospital_id' => 'string',
            'patient_id' => 'string',
            'scanned_by_user_id' => 'string',
            'patient_qr_token_id' => 'string',
            'scanned_at' => 'datetime',
        ];
    }

    public function hospital(): BelongsTo
    {
        return $this->belongsTo(Hospital::class);
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'patient_id');
    }

    public function scannedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'scanned_by_user_id');
    }

    public function qrToken(): BelongsTo
    {
        return $this->belongsTo(PatientQrToken::class, 'patient_qr_token_id');
    }
    public function notes(): HasMany
{
    return $this->hasMany(
        HospitalPatientScanNote::class,
        'hospital_patient_qr_scan_id',
    );
}
}