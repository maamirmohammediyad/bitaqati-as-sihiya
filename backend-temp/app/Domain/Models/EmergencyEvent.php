<?php

declare(strict_types=1);

namespace App\Domain\Models;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Domain\Models\Hospital;
use Illuminate\Database\Eloquent\Builder;
class EmergencyEvent extends Model
{
    use HasUuids;

    protected $table = 'emergency_events';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';
protected $fillable = [
    'user_id',
    'status',
    'latitude',
    'longitude',
    'location_name',
    'notified_guardians',
    'checked_in_hospital_id',
    'checked_in_at',
    'resolved_at',
    'resolved_by',
    'resolution_notes',
];

protected function casts(): array
{
    return [
        'id' => 'string',
        'user_id' => 'string',
        'latitude' => 'float',
        'longitude' => 'float',
        'notified_guardians' => 'array',
        'checked_in_hospital_id' => 'string',
        'checked_in_at' => 'datetime',
        'resolved_at' => 'datetime',
        'resolved_by' => 'string',
    ];
}

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function resolver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'resolved_by');
    }
    public function checkedInHospital(): BelongsTo
{
    return $this->belongsTo(Hospital::class, 'checked_in_hospital_id');
}
    public function reads(): HasMany
{
    return $this->hasMany(
        EmergencyEventRead::class,
        'emergency_event_id',
    );
}
public function notes(): HasMany
{
    return $this->hasMany(
        EmergencyEventNote::class,
        'emergency_event_id',
    );
}

public function scopeVisibleToHospital(
    Builder $query,
    Hospital $hospital,
): Builder {
    if ($hospital->latitude === null || $hospital->longitude === null) {
        return $query->whereRaw('1 = 0');
    }

    $radiusKm = (float) config(
        'services.hospital_emergency_radius_km',
        20,
    );

    $distanceSql = '
        6371 * acos(
            least(
                1.0,
                greatest(
                    -1.0,
                    cos(radians(?))
                    * cos(radians(latitude))
                    * cos(radians(longitude) - radians(?))
                    + sin(radians(?))
                    * sin(radians(latitude))
                )
            )
        )
    ';

    $bindings = [
        $hospital->latitude,
        $hospital->longitude,
        $hospital->latitude,
    ];

    return $query
        ->select('emergency_events.*')
        ->selectRaw(
    "round(({$distanceSql})::numeric, 2) as distance_km",
    $bindings,
)
        ->whereNotNull('latitude')
        ->whereNotNull('longitude')
        ->whereRaw("{$distanceSql} <= ?", [
            ...$bindings,
            $radiusKm,
        ]);
}

public function qrLastScannedBy(): BelongsTo
{
    return $this->belongsTo(
        User::class,
        'qr_last_scanned_by_user_id'
    );
}

public function hospitalQrScans(): HasMany
{
    return $this->hasMany(
        HospitalPatientQrScan::class,
        'patient_id',
        'user_id'
    );
}
}
