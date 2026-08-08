<?php

declare(strict_types=1);

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreHospitalAdminRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role->value === 'super_admin';
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:255', 'unique:users,phone'],
            'employee_code' => ['required', 'string', 'max:50', 'unique:users,employee_code'],
            'password' => ['required', 'string', 'min:8', 'max:255'],
        ];
    }
}