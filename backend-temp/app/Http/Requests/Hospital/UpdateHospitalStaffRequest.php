<?php

declare(strict_types=1);

namespace App\Http\Requests\Hospital;

use App\Domain\Enums\HospitalUserRole;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class UpdateHospitalStaffRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => [
                'sometimes',
                'required',
                'string',
                'min:2',
                'max:120',
            ],

            'phone' => [
                'sometimes',
                'nullable',
                'string',
                'max:30',
            ],

            'role' => [
                'sometimes',
                'required',
                new Enum(HospitalUserRole::class),
            ],

            'is_active' => [
                'sometimes',
                'boolean',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'اسم الموظف مطلوب عند إرساله.',
            'name.min' => 'اسم الموظف يجب ألا يقل عن حرفين.',
            'name.max' => 'اسم الموظف يجب ألا يتجاوز 120 حرفًا.',
            'phone.string' => 'رقم الهاتف يجب أن يكون نصًا.',
            'phone.max' => 'رقم الهاتف يجب ألا يتجاوز 30 حرفًا.',
            'role.required' => 'دور الموظف مطلوب عند إرساله.',
            'role.enum' => 'دور الموظف غير صالح.',
            'is_active.boolean' => 'حالة التفعيل يجب أن تكون true أو false.',
        ];
    }
}