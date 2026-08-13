<?php

declare(strict_types=1);

namespace App\Http\Resources;
use App\Domain\Models\User;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmergencyEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'user' => new UserResource($this->whenLoaded('user')),
            'status' => $this->status,
            'is_read' => (bool) ($this->is_read ?? false),
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'location_name' => $this->location_name,
            'notified_guardians' => $this->notified_guardians,
            'checked_in_hospital_id' => $this->checked_in_hospital_id,
'checked_in_hospital' => $this->whenLoaded(
    'checkedInHospital',
    fn () => [
        'id' => $this->checkedInHospital?->id,
        'name' => $this->checkedInHospital?->name,
    ],
),
'checked_in_at' => $this->checked_in_at?->toIso8601String(),
            'resolved_at' => $this->resolved_at?->toIso8601String(),
            'resolved_by' => $this->resolved_by,
            'resolution_notes' => $this->resolution_notes,
            'created_at' => $this->created_at->toIso8601String(),
            'updated_at' => $this->updated_at->toIso8601String(),
        ];
    }
}
