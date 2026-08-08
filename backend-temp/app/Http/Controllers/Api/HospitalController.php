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
        $lat = (float) $request->query('lat');
        $lng = (float) $request->query('lng');
        $radiusKm = (float) $request->query('radius', 10); // 10 كم مثلاً

        if (!$lat || !$lng) {
            return response()->json([
                'message' => 'lat and lng are required',
            ], 422);
        }

        // Haversine formula
        $hospitals = DB::table('hospitals')
            ->where('is_active', true)
            ->select('*')
            ->selectRaw("
                (6371 * acos(
                    cos(radians(?)) * cos(radians(latitude))
                    * cos(radians(longitude) - radians(?))
                    + sin(radians(?)) * sin(radians(latitude))
                )) AS distance
            ", [$lat, $lng, $lat])
            ->having('distance', '<=', $radiusKm)
            ->orderBy('distance')
            ->get();

        return response()->json([
            'data'  => $hospitals,
            'count' => $hospitals->count(),
        ]);
    }
}