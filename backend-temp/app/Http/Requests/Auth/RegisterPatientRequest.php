<?php

declare(strict_types=1);

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterPatientRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
{
    return [
        'national_id' => ['required','regex:/^[0-9]{18}$/','unique:users,national_id'],
        'first_name'  => ['required', 'string', 'max:255'],
        'last_name'   => ['required', 'string', 'max:255'],
        'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'],
        'password'    => ['required', 'string', 'min:6', 'max:128'],
    ];
}
}
