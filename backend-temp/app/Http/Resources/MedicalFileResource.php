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

            'url' => null,

            
            'hospital_id' => $this->hospital_id
                ? (string) $this->hospital_id
                : null,

            'uploaded_by' => $this->uploaded_by
                ? [
                    'id' => (string) $this->uploaded_by,

                    // لا نصل إلى name إلا إذا كانت علاقة uploader محملة وموجودة.
                    'name' => $this->when(
                        $this->resource->relationLoaded('uploader') &&
                            $this->resource->uploader !== null,
                        fn () => $this->resource->uploader->name,
                    ),
                ]
                : null,

            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}