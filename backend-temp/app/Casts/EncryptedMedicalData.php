<?php

declare(strict_types=1);

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

class EncryptedMedicalData implements CastsAttributes
{
    public function get($model, string $key, $value, array $attributes): mixed
    {
        // حالياً نرجع القيمة كما هي بدون تشفير/فك تشفير
        return $value;
    }

    public function set($model, string $key, $value, array $attributes): mixed
    {
        // حالياً نخزن القيمة كما هي
        return $value;
    }
}