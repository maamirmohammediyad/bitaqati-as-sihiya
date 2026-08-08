<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;
use Illuminate\Support\Str;
use App\Domain\Enums\UserRole;
use App\Domain\Models\Hospital;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreHospitalAdminRequest;
use App\Http\Requests\Admin\StoreHospitalRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class HospitalController extends Controller
{
    public function index(): JsonResponse
    {
        $hospitals = Hospital::query()
            ->withCount([
                'users as active_staff_count' => fn ($query) => $query->wherePivot('is_active', true),
            ])
            ->latest()
            ->paginate(20);

        return response()->json($hospitals);
    }

    public function store(StoreHospitalRequest $request): JsonResponse
    {
        $hospital = Hospital::query()->create([
            ...$request->validated(),
            'is_active' => true,
            'status' => 'approved',
            'created_by' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'تم إنشاء المؤسسة الصحية بنجاح.',
            'data' => $hospital,
        ], 201);
    }

    public function show(Hospital $hospital): JsonResponse
    {
        $hospital->load([
            'users' => fn ($query) => $query
                ->select('users.id', 'users.name', 'users.email', 'users.phone', 'users.employee_code', 'users.is_active')
                ->orderBy('users.name'),
        ]);

        return response()->json([
            'data' => $hospital,
        ]);
    }

    public function storeAdmin(
        StoreHospitalAdminRequest $request,
        Hospital $hospital,
    ): JsonResponse {
        $admin = DB::transaction(function () use ($request, $hospital): User {
            $user = User::query()->create([
                'name' => $request->string('name')->toString(),
                'email' => $request->input('email'),
                'phone' => $request->input('phone'),
                'employee_code' => $request->string('employee_code')->toString(),
                'password' => Hash::make($request->string('password')->toString()),
                'role' => UserRole::HealthWorker,
                'is_active' => true,
            ]);

            $hospital->users()->attach($user->id, [
    'id' => (string) Str::uuid(),
    'role' => 'hospital_admin',
    'is_active' => true,
    'joined_at' => now(),
]);

            return $user;
        });

        return response()->json([
            'message' => 'تم إنشاء مسؤول المستشفى وربطه بالمؤسسة بنجاح.',
            'data' => [
                'id' => $admin->id,
                'name' => $admin->name,
                'email' => $admin->email,
                'employee_code' => $admin->employee_code,
                'role' => 'hospital_admin',
                'hospital_id' => $hospital->id,
            ],
        ], 201);
    }
}