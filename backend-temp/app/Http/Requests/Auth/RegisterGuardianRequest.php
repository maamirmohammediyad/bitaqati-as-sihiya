<?php

declare(strict_types=1);

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterGuardianRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'national_id'        => ['required', 'string', 'max:50', 'unique:users,national_id'],
            'first_name'  => ['required', 'string', 'max:255'],
            'last_name'   => ['required', 'string', 'max:255'],
            'email'              => ['nullable', 'string', 'email', 'max:255', 'unique:users,email'],
            'phone'              => ['required', 'string', 'max:20', 'unique:users,phone'],
            'password'           => ['required', 'string', 'min:8', 'max:128'],
            'patient_code'       => ['required', 'string', 'exists:users,patient_code'],
            'relationship'       => ['required', 'string', 'in:father,mother,husband,wife,son,daughter,brother,sister,other'],
            'can_access_location'=> ['nullable', 'boolean'],
        ];
    }
}