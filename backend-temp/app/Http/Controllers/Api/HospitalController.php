<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Domain\Models\Hospital;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\DB;

class HospitalController extends Controller
{
public function nearby(Request $request): JsonResponse
{
    $validated = $request->validate([
        'lat' => ['required', 'numeric', 'between:-90,90'],
        'lng' => ['required', 'numeric', 'between:-180,180'],
        'radius' => ['nullable', 'numeric', 'min:1', 'max:100'],
    ]);

    $lat = (float) $validated['lat'];
    $lng = (float) $validated['lng'];
    $radiusKm = (float) ($validated['radius'] ?? 10);

    $distanceSql = '
        6371 * acos(
            cos(radians(?)) * cos(radians(latitude))
            * cos(radians(longitude) - radians(?))
            + sin(radians(?)) * sin(radians(latitude))
        )
    ';

    $hospitals = DB::table('hospitals')
        ->where('is_active', true)
        ->whereNotNull('latitude')
        ->whereNotNull('longitude')
        ->select('*')
        ->selectRaw(
            "($distanceSql) AS distance",
            [$lat, $lng, $lat],
        )
        ->whereRaw(
            "($distanceSql) <= ?",
            [$lat, $lng, $lat, $radiusKm],
        )
        ->orderBy('distance')
        ->get();

    return response()->json([
        'data' => $hospitals,
        'count' => $hospitals->count(),
    ]);
}
}