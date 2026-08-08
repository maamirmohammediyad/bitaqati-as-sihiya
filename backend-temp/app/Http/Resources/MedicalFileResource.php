<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class MedicalFileResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'            => $this->id,
            'original_name' => $this->original_name,
            'file_type'     => $this->file_type?->value, // لأنه Enum FileType
            'description'   => $this->description,
            'size_bytes'    => $this->size_bytes,
            'mime_type'     => $this->mime_type,
            'url'           => Storage::url($this->storage_path),
            'created_at'    => $this->created_at?->toIso8601String(),
        ];
    }
}