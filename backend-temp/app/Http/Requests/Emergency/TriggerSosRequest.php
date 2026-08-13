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
            'latitude' => [
                'nullable',
                'required_with:longitude',
                'numeric',
                'between:-90,90',
            ],
            'longitude' => [
                'nullable',
                'required_with:latitude',
                'numeric',
                'between:-180,180',
            ],
            'location_name' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'latitude.required_with' => 'يجب إرسال خط العرض مع خط الطول.',
            'longitude.required_with' => 'يجب إرسال خط الطول مع خط العرض.',
            'latitude.between' => 'قيمة خط العرض غير صالحة.',
            'longitude.between' => 'قيمة خط الطول غير صالحة.',
        ];
    }
}