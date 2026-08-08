<?php

declare(strict_types=1);

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

public function rules(): array
{
    return [
        'role' => [
            'required',
            Rule::in([
                'patient',
                'guardian',
                'health_worker',
                'super_admin',
            ]),
        ],

        'email' => [
            Rule::requiredIf(
                fn (): bool => $this->input('role') === 'super_admin',
            ),
            'nullable',
            'email',
            'max:255',
        ],

        'national_id' => [
            Rule::requiredIf(
                fn (): bool => in_array(
                    $this->input('role'),
                    ['patient', 'guardian'],
                    true,
                ),
            ),
            'nullable',
            'string',
            'max:50',
        ],

        'employee_code' => [
            Rule::requiredIf(
                fn (): bool => $this->input('role') === 'health_worker',
            ),
            'nullable',
            'string',
            'max:50',
        ],

        'password' => [
            'required',
            'string',
            'min:8',
        ],
    ];
}

    public function credentials(): array
{
    if ($this->input('role') === 'super_admin') {
        return $this->only('email', 'password');
    }

    if ($this->input('role') === 'health_worker') {
        return $this->only('employee_code', 'password');
    }

    return $this->only('national_id', 'password');
}
}