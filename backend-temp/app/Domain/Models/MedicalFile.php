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
    public function uploadMedicalFile(Request $request, string $id): JsonResponse
{
    /** @var User $guardian */
    $guardian = auth()->user();

    $patient = $guardian->patients()->where('id', $id)->firstOrFail();

    $validated = $request->validate([
        'file'        => ['required', 'file', 'max:10240'], // 10MB
        'file_type'   => ['nullable', 'string', 'max:50'],
        'description' => ['nullable', 'string', 'max:255'],
    ]);

    $uploadedFile = $validated['file'];

    $path = $uploadedFile->store('medical_files/'.$patient->id, 'public');

    $medicalFile = MedicalFile::create([
        'user_id'      => $patient->id,
        'original_name'=> $uploadedFile->getClientOriginalName(),
        'storage_path' => $path,
        'mime_type'    => $uploadedFile->getClientMimeType(),
        'size_bytes'   => $uploadedFile->getSize(),
        // file_type عندك Enum FileType، هنا نستقبل string ونحوّله إذا شئت:
        'file_type'    => isset($validated['file_type'])
            ? \App\Domain\Enums\FileType::from($validated['file_type'])
            : null,
        'description'  => $validated['description'] ?? null,
    ]);

    return response()->json([
        'data' => new MedicalFileResource($medicalFile),
    ], 201);
}
}
