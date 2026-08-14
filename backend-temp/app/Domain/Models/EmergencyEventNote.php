<?php

declare(strict_types=1);

namespace App\Domain\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EmergencyEventNote extends Model
{
    use HasUuids;

    protected $table = 'emergency_event_notes';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'emergency_event_id',
        'hospital_id',
        'author_id',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'emergency_event_id' => 'string',
            'hospital_id' => 'string',
            'author_id' => 'string',
        ];
    }

    public function emergencyEvent(): BelongsTo
    {
        return $this->belongsTo(
            EmergencyEvent::class,
            'emergency_event_id',
        );
    }

    public function hospital(): BelongsTo
    {
        return $this->belongsTo(Hospital::class, 'hospital_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}