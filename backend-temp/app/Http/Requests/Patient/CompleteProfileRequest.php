<?php

declare(strict_types=1);

namespace App\Http\Requests\Patient;

use Illuminate\Foundation\Http\FormRequest;

class CompleteProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'full_name' => ['sometimes', 'required', 'string', 'max:255'],
            'date_of_birth' => ['sometimes', 'required', 'date', 'before:today'],
            'blood_group' => ['sometimes', 'required', 'string', 'in:A+,A-,B+,B-,AB+,AB-,O+,O-'],
            'gender' => ['sometimes', 'required', 'string', 'in:male,female'],
            'height_cm' => ['nullable', 'numeric', 'min:20', 'max:300'],
            'weight_kg' => ['nullable', 'numeric', 'min:1', 'max:500'],
            'allergies' => ['nullable', 'string', 'max:2000'],
            'chronic_diseases' => ['nullable', 'string', 'max:2000'],
            'medications' => ['nullable', 'array', 'max:100'],'medications.*.id' => ['nullable', 'uuid'],'medications.*.name' => ['required_with:medications', 'string', 'max:255'],'medications.*.dosage' => ['nullable', 'string', 'max:255'],'medications.*.frequency' => ['nullable', 'string', 'max:255'],'medications.*.notes' => ['nullable', 'string', 'max:1000'],
            'emergency_notes' => ['nullable', 'string', 'max:2000'],
            'address' => ['nullable', 'string', 'max:500'],
            'city' => ['nullable', 'string', 'max:255'],
            'state' => ['nullable', 'string', 'max:255'],
            'country' => ['nullable', 'string', 'max:255'],
            'postal_code' => ['nullable', 'string', 'max:20'],
            'avatar_url' => ['nullable', 'string', 'url', 'max:2048'],
            'patient_id' => ['sometimes', 'uuid'],
        ];
    }
}
