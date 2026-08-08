<?php

declare(strict_types=1);

namespace App\Domain\Enums;

enum UserRole: string
{
    case Patient = 'patient';
    case Guardian = 'guardian';
    case SuperAdmin = 'super_admin';
    case HealthWorker = 'health_worker';
}