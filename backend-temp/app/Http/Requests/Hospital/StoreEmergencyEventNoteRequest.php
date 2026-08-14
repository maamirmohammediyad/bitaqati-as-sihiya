<?php

declare(strict_types=1);

namespace App\Http\Requests\Hospital;

use Illuminate\Foundation\Http\FormRequest;

class StoreEmergencyEventNoteRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'note' => ['required', 'string', 'min:1', 'max:5000'],
        ];
    }

    public function messages(): array
    {
        return [
            'note.required' => 'نص الملاحظة مطلوب.',
            'note.string' => 'يجب أن تكون الملاحظة نصًا.',
            'note.min' => 'لا يمكن أن تكون الملاحظة فارغة.',
            'note.max' => 'يجب ألا تتجاوز الملاحظة 5000 حرف.',
        ];
    }
}