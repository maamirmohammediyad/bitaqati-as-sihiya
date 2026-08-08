<?php

declare(strict_types=1);

namespace App\Http\Requests\Emergency;

use Illuminate\Foundation\Http\FormRequest;

class TriggerSosRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'location_name' => ['nullable', 'string', 'max:500'],
        ];
    }
}
