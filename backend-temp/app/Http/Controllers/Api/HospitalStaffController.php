<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Domain\Enums\HospitalUserRole;
use App\Domain\Enums\UserRole;
use App\Domain\Models\HospitalUser;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Requests\Hospital\StoreHospitalStaffRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Requests\Hospital\UpdateHospitalStaffRequest;
use App\Mail\HospitalStaffCredentialsMail;
use Illuminate\Support\Facades\Mail;
class HospitalStaffController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $hospitalId = $request->attributes->get('hospital_id');

        if ($hospitalId === null) {
            return response()->json([
                'message' => 'تعذر تحديد المستشفى.',
            ], 403);
        }

        $staff = HospitalUser::query()
            ->with([
                'user:id,name,email,employee_code,phone,is_active',
            ])
            ->where('hospital_id', $hospitalId)
            ->orderByDesc('is_active')
            ->orderBy('joined_at')
            ->get()
            ->map(function (HospitalUser $hospitalUser): array {
                return $this->staffData($hospitalUser);
            })
            ->values();

        return response()->json([
            'data' => $staff,
        ]);
    }

    public function store(StoreHospitalStaffRequest $request): JsonResponse
    {
        $hospitalId = $request->attributes->get('hospital_id');

        if ($hospitalId === null) {
            return response()->json([
                'message' => 'تعذر تحديد المستشفى.',
            ], 403);
        }

        $staffMember = DB::transaction(function () use ($request, $hospitalId): HospitalUser {
            $data = $request->validated();

            $user = User::query()->create([
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'employee_code' => $data['employee_code'],
                'password' => $data['password'],
                'role' => UserRole::HealthWorker,
                'is_active' => true,
            ]);

            return HospitalUser::query()->create([
                'hospital_id' => $hospitalId,
                'user_id' => $user->id,
                'role' => HospitalUserRole::from($data['role']),
                'is_active' => true,
                'joined_at' => now(),
            ]);
        });

        $staffMember->load([
            'user:id,name,email,employee_code,phone,is_active',
        ]);
Mail::to($staffMember->user->email)->send(
    new HospitalStaffCredentialsMail(
        name: $staffMember->user->name,
        employeeCode: $staffMember->user->employee_code,
        password: $request->input('password'),
        role: $staffMember->role->value,
    )
);
        return response()->json([
            'message' => 'تمت إضافة موظف المستشفى بنجاح.',
            'data' => $this->staffData($staffMember),
        ], 201);
    }
    public function update(
    UpdateHospitalStaffRequest $request,
    string $id,
): JsonResponse {
    $hospitalId = $request->attributes->get('hospital_id');

    if ($hospitalId === null) {
        return response()->json([
            'message' => 'تعذر تحديد المستشفى.',
        ], 403);
    }

    $staffMember = HospitalUser::query()
        ->with('user')
        ->whereKey($id)
        ->where('hospital_id', $hospitalId)
        ->first();

    if ($staffMember === null) {
        return response()->json([
            'message' => 'موظف المستشفى غير موجود.',
        ], 404);
    }

    $data = $request->validated();
    $currentUserId = (string) $request->user()->id;
    $isUpdatingSelf = (string) $staffMember->user_id === $currentUserId;

    if ($isUpdatingSelf && array_key_exists('is_active', $data) && $data['is_active'] === false) {
        return response()->json([
            'message' => 'لا يمكنك تعطيل حسابك الإداري بنفسك.',
        ], 422);
    }

    if ($isUpdatingSelf && array_key_exists('role', $data)) {
        return response()->json([
            'message' => 'لا يمكنك تغيير دور حسابك الإداري بنفسك.',
        ], 422);
    }

    DB::transaction(function () use ($staffMember, $data): void {
        $userData = [];

        if (array_key_exists('name', $data)) {
            $userData['name'] = $data['name'];
        }

        if (array_key_exists('phone', $data)) {
            $userData['phone'] = $data['phone'];
        }

        if ($userData !== []) {
            $staffMember->user->update($userData);
        }

        $hospitalUserData = [];

        if (array_key_exists('role', $data)) {
            $hospitalUserData['role'] = HospitalUserRole::from($data['role']);
        }

        if (array_key_exists('is_active', $data)) {
            $hospitalUserData['is_active'] = $data['is_active'];

            $staffMember->user->update([
                'is_active' => $data['is_active'],
            ]);
        }

        if ($hospitalUserData !== []) {
            $staffMember->update($hospitalUserData);
        }
    });

    $staffMember->refresh()->load([
        'user:id,name,email,employee_code,phone,is_active',
    ]);

    return response()->json([
        'message' => 'تم تحديث بيانات موظف المستشفى بنجاح.',
        'data' => $this->staffData($staffMember),
    ]);
}
    private function staffData(HospitalUser $hospitalUser): array
    {
        return [
            'id' => (string) $hospitalUser->id,
            'user_id' => (string) $hospitalUser->user_id,
            'name' => $hospitalUser->user?->name,
            'email' => $hospitalUser->user?->email,
            'employee_code' => $hospitalUser->user?->employee_code,
            'phone' => $hospitalUser->user?->phone,
            'role' => $hospitalUser->role?->value ?? $hospitalUser->role,
            'is_active' => (bool) $hospitalUser->is_active,
            'joined_at' => $hospitalUser->joined_at?->toISOString(),
        ];
    }
}