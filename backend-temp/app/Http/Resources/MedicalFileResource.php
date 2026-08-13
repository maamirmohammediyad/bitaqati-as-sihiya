<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class MedicalFileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'user_id' => (string) $this->user_id,

            'original_name' => $this->original_name ?? 'ملف طبي',
            'storage_path' => $this->storage_path,

            'file_type' => $this->file_type?->value,
            'description' => $this->description,

            'size_bytes' => $this->size_bytes,
            'mime_type' => $this->mime_type,

            'url' => $this->storage_path
                ? Storage::disk('public')->url($this->storage_path)
                : null,

            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}