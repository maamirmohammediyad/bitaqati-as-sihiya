<?php

declare(strict_types=1);

namespace App\Domain\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EmergencyEventRead extends Model
{
    use HasUuids;

    protected $table = 'emergency_event_reads';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'emergency_event_id',
        'guardian_id',
        'read_at',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'emergency_event_id' => 'string',
            'guardian_id' => 'string',
            'read_at' => 'datetime',
        ];
    }

    public function emergencyEvent(): BelongsTo
    {
        return $this->belongsTo(
            EmergencyEvent::class,
            'emergency_event_id',
        );
    }

    public function guardian(): BelongsTo
    {
        return $this->belongsTo(User::class, 'guardian_id');
    }
}