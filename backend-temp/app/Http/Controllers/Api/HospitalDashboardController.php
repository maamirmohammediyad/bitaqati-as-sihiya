<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Domain\Models\EmergencyEvent;
use App\Domain\Models\HospitalUser;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HospitalDashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        /** @var HospitalUser $hospitalUser */
        $hospitalUser = $request->attributes->get('hospital_user');

        $hospital = $hospitalUser->hospital;

        $today = today();

        $activeEmergencies = EmergencyEvent::query()
            ->where('status', 'active')
            ->count();

        $checkedInToday = EmergencyEvent::query()
            ->where('checked_in_hospital_id', $hospital->id)
            ->whereDate('checked_in_at', $today)
            ->count();

        $resolvedToday = EmergencyEvent::query()
            ->where('checked_in_hospital_id', $hospital->id)
            ->where('status', 'resolved')
            ->whereDate('resolved_at', $today)
            ->count();

        $staffCount = HospitalUser::query()
            ->where('hospital_id', $hospital->id)
            ->where('is_active', true)
            ->count();

        $recentEmergencies = EmergencyEvent::query()
            ->with([
                'user:id,name,phone,patient_code',
            ])
            ->where(function ($query) use ($hospital): void {
                $query
                    ->where('checked_in_hospital_id', $hospital->id)
                    ->orWhere('status', 'active');
            })
            ->latest('created_at')
            ->limit(10)
            ->get()
            ->map(function (EmergencyEvent $event): array {
                return [
                    'id' => $event->id,
                    'status' => $event->status,
                    'latitude' => $event->latitude,
                    'longitude' => $event->longitude,
                    'location_name' => $event->location_name,
                    'created_at' => $event->created_at?->toISOString(),
                    'checked_in_at' => $event->checked_in_at?->toISOString(),
                    'patient' => [
                        'id' => $event->user?->id,
                        'name' => $event->user?->name,
                        'phone' => $event->user?->phone,
                        'patient_code' => $event->user?->patient_code,
                    ],
                ];
            })
            ->values();

        return response()->json([
            'data' => [
                'hospital' => [
                    'id' => $hospital->id,
                    'name' => $hospital->name,
                    'type' => $hospital->type,
                    'phone' => $hospital->phone,
                    'address' => $hospital->address,
                    'city' => $hospital->city,
                    'is_active' => $hospital->is_active,
                ],
                'staff' => [
                    'id' => $hospitalUser->id,
                    'name' => $request->user()->name,
                    'role' => $hospitalUser->role->value,
                ],
                'statistics' => [
                    'active_emergencies' => $activeEmergencies,
                    'checked_in_today' => $checkedInToday,
                    'resolved_today' => $resolvedToday,
                    'active_staff_count' => $staffCount,
                ],
                'recent_emergencies' => $recentEmergencies,
            ],
        ]);
    }
}