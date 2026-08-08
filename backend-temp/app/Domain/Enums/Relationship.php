<?php

declare(strict_types=1);

namespace App\Domain\Enums;

enum Relationship: string
{
    case Father = 'father';
    case Mother = 'mother';
    case Husband = 'husband';
    case Wife = 'wife';
    case Son = 'son';
    case Daughter = 'daughter';
    case Brother = 'brother';
    case Sister = 'sister';
    case Other = 'other';
}
