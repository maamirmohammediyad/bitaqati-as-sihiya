<?php

declare(strict_types=1);

namespace App\Domain\Models;

use App\Domain\Enums\HospitalUserRole;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HospitalUser extends Model
{
    use HasUuids;

    protected $table = 'hospital_users';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'hospital_id',
        'user_id',
        'role',
        'is_active',
        'joined_at',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'hospital_id' => 'string',
            'user_id' => 'string',
            'role' => HospitalUserRole::class,
            'is_active' => 'boolean',
            'joined_at' => 'datetime',
        ];
    }

    public function hospital(): BelongsTo
    {
        return $this->belongsTo(Hospital::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}