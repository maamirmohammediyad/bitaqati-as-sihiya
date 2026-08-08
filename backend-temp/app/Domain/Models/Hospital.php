<?php

declare(strict_types=1);

namespace App\Domain\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Hospital extends Model
{
    use HasUuids;

    protected $table = 'hospitals';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'name',
        'type',
        'license_number',
        'address',
        'city',
        'state',
        'country',
        'postal_code',
        'phone',
        'email',
        'latitude',
        'longitude',
        'is_active',
        'status',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'latitude' => 'float',
            'longitude' => 'float',
            'is_active' => 'boolean',
            'created_by' => 'string',
        ];
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(
            User::class,
            'hospital_users',
            'hospital_id',
            'user_id',
        )
            ->withPivot(['id', 'role', 'is_active', 'joined_at'])
            ->withTimestamps();
    }
}