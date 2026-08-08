<?php

declare(strict_types=1);

namespace App\Http\Requests\Emergency;

use Illuminate\Foundation\Http\FormRequest;

class ResolveSosRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'resolution_notes' => ['nullable', 'string', 'max:2000'],
        ];
    }
}
