<?php

declare(strict_types=1);

namespace App\Domain\Models;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class AccountVerificationDocument extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'original_name',
        'storage_path',
        'mime_type',
        'size_bytes',
        'submitted_at',
        'reviewed_at',
        'reviewed_by',
        'rejection_reason',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'submitted_at' => 'datetime',
            'reviewed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }
}