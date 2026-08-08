<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Domain\Models\EmergencyEvent;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Resources\EmergencyEventResource;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function users(Request $request): JsonResponse
    {
        $users = User::with('patientProfile')
            ->when($request->input('role'), fn ($q, $role) => $q->where('role', $role))
            ->when($request->input('search'), fn ($q, $search) => $q->where(function ($q) use ($search): void {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            }))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'data' => UserResource::collection($users),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ]);
    }

    public function emergencyEvents(Request $request): JsonResponse
    {
        $events = EmergencyEvent::with('user')
            ->when($request->input('status'), fn ($q, $status) => $q->where('status', $status))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'data' => EmergencyEventResource::collection($events),
            'meta' => [
                'current_page' => $events->currentPage(),
                'last_page' => $events->lastPage(),
                'per_page' => $events->perPage(),
                'total' => $events->total(),
            ],
        ]);
    }
}
