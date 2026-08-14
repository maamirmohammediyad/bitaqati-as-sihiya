<?php

declare(strict_types=1);

namespace App\Http\Requests\Hospital;
use App\Domain\Enums\HospitalUserRole;
use Illuminate\Validation\Rules\Enum;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class StoreHospitalStaffRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'min:2',
                'max:120',
            ],

            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                'unique:users,email',
            ],

            'phone' => [
                'nullable',
                'string',
                'max:30',
            ],

            'employee_code' => [
                'required',
                'string',
                'max:50',
                'unique:users,employee_code',
            ],

           'role' => [
                'required',
                new Enum(HospitalUserRole::class),
            ],
            'password' => [
                'required',
                'string',
                'confirmed',
                Password::min(8),
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'اسم الموظف مطلوب.',
            'email.required' => 'البريد الإلكتروني مطلوب.',
            'email.email' => 'البريد الإلكتروني غير صالح.',
            'email.unique' => 'البريد الإلكتروني مستخدم بالفعل.',
            'employee_code.required' => 'كود الموظف مطلوب.',
            'employee_code.unique' => 'كود الموظف مستخدم بالفعل.',
            'role.required' => 'دور الموظف مطلوب.',
            'role.in' => 'دور الموظف غير صالح.',
            'password.required' => 'كلمة المرور مطلوبة.',
            'password.confirmed' => 'تأكيد كلمة المرور غير مطابق.',
        ];
    }
}