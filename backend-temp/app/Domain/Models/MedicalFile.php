<?php

declare(strict_types=1);

namespace App\Domain\Models;

use App\Domain\Enums\FileType;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class MedicalFile extends Model
{
    use HasUuids, SoftDeletes;

    protected $table = 'medical_files';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'user_id',
        'original_name',
        'storage_path',
        'mime_type',
        'size_bytes',
        'file_type',
        'description',
    ];

    protected function casts(): array
    {
        return [
            'id' => 'string',
            'user_id' => 'string',
            'size_bytes' => 'integer',
            'file_type' => FileType::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
