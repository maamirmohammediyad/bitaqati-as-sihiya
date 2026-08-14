<?php

declare(strict_types=1);

namespace App\Http\Requests\Emergency;

use Illuminate\Foundation\Http\FormRequest;

class ResolveHospitalEmergencyRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'resolution_notes' => [
                'nullable',
                'string',
                'max:2000',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'resolution_notes.string' => 'ملاحظات إنهاء الحالة يجب أن تكون نصًا.',
            'resolution_notes.max' => 'ملاحظات إنهاء الحالة يجب ألا تتجاوز 2000 حرف.',
        ];
    }
}