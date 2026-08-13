<?php

declare(strict_types=1);

namespace App\Domain\Models;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Domain\Models\Hospital;
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

}
