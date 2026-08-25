<?php

declare(strict_types=1);

namespace App\Domain\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AccountRecoveryRequest extends Model
{
    use HasUuids;

    protected $table = 'account_recovery_requests';

    protected $fillable = [
        'user_id',
        'national_id',
        'full_name',
        'phone',
        'note',
        'identity_document_path',
        'identity_document_name',
        'identity_document_mime',
        'identity_document_size',
        'status',
        'admin_note',
        'reviewed_by',
        'reviewed_at',
        'completion_token_hash',
        'completion_token_expires_at',
        'completion_token_used_at',
    ];

    protected function casts(): array
    {
        return [
            'identity_document_size' => 'integer',
            'reviewed_at' => 'datetime',
            'completion_token_expires_at' => 'datetime',
            'completion_token_used_at' => 'datetime',
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