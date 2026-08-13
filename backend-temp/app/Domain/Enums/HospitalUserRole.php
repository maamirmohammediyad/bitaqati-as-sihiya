<?php

declare(strict_types=1);

namespace App\Domain\Enums;

enum HospitalUserRole: string
{
    case Admin = 'admin';
    case Receptionist = 'receptionist';
    case Doctor = 'doctor';
    case Nurse = 'nurse';
    case Staff = 'staff';
}