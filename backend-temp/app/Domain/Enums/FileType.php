<?php

declare(strict_types=1);

namespace App\Domain\Enums;

enum FileType: string
{
    case Analysis = 'analysis';
    case Xray = 'xray';
    case Prescription = 'prescription';
    case Pdf = 'pdf';
    case Other = 'other';
}
