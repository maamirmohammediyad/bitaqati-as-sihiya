<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Mail\AdminUserChangedMail;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\Rule;
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

public function storeUser(Request $request): JsonResponse
{
    $validated = $request->validate([
        'name' => ['required', 'string', 'max:255'],
        'email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
        'phone' => ['nullable', 'string', 'max:30', 'unique:users,phone'],
        'national_id' => ['nullable', 'string', 'max:100', 'unique:users,national_id'],
        'patient_code' => ['nullable', 'string', 'max:100', 'unique:users,patient_code'],
'employee_code' => ['nullable', 'string', 'max:100', 'unique:users,employee_code'],
        'role' => ['required', Rule::in([
            'super_admin',
            'health_worker',
            'patient',
            'guardian',
        ])],
        'password' => ['required', 'string', 'min:8'],
        'is_active' => ['sometimes', 'boolean'],
    ]);

    $plainPassword = $validated['password'];

    $user = User::query()->create([
        'name' => $validated['name'],
        'email' => $validated['email'] ?? null,
        'phone' => $validated['phone'] ?? null,
        'national_id' => $validated['national_id'] ?? null,
        'patient_code' => $validated['patient_code'] ?? null,
        'employee_code' => $validated['employee_code'] ?? null,
        'role' => $validated['role'],
        'password' => Hash::make($plainPassword),
        'is_active' => $validated['is_active'] ?? true,
    ]);

    if ($user->email) {
        Mail::to($user->email)->send(
            new AdminUserChangedMail($user, 'created', $plainPassword)
        );
    }

    return response()->json([
        'message' => 'تم إنشاء المستخدم بنجاح.',
        'data' => new UserResource($user->load('patientProfile')),
    ], 201);
}

public function updateUser(Request $request, User $user): JsonResponse
{
    $validated = $request->validate([
        'name' => ['nullable', 'string', 'max:255'],
        'email' => [
            'nullable',
            'email',
            'max:255',
            Rule::unique('users', 'email')->ignore($user->id),
        ],
        'phone' => [
            'nullable',
            'string',
            'max:30',
            Rule::unique('users', 'phone')->ignore($user->id),
        ],
        'national_id' => [
            'nullable',
            'string',
            'max:100',
            Rule::unique('users', 'national_id')->ignore($user->id),
        ],
        'role' => [
            'required',
            Rule::in([
                'super_admin',
                'health_worker',
                'patient',
                'guardian',
            ]),
        ],

        'patient_code' => [
    'nullable',
    'string',
    'max:100',
    Rule::unique('users', 'patient_code')->ignore($user->id),
],

'employee_code' => [
    'nullable',
    'string',
    'max:100',
    Rule::unique('users', 'employee_code')->ignore($user->id),
],
        'password' => ['nullable', 'string', 'min:8'],
        'is_active' => ['required', 'boolean'],
    ]);

        $changes = [
    'name' => $validated['name'] ?? null,
    'email' => $validated['email'] ?? null,
    'phone' => $validated['phone'] ?? null,
    'national_id' => $validated['national_id'] ?? null,
    'patient_code' => $validated['patient_code'] ?? null,
    'employee_code' => $validated['employee_code'] ?? null,
    'role' => $validated['role'],
    'is_active' => $validated['is_active'],
];


    if (!empty($validated['password'])) {
        $changes['password'] = Hash::make($validated['password']);
    }

    $user->update($changes);

    if ($user->email) {
        Mail::to($user->email)->send(
            new AdminUserChangedMail($user->fresh(), 'updated')
        );
    }

    return response()->json([
        'message' => 'تم تحديث المستخدم بنجاح.',
        'data' => $user->fresh()->load('patientProfile'),
    ]);
}

public function destroyUser(Request $request, User $user): JsonResponse
{
    if ($request->user()->is($user)) {
        return response()->json([
            'message' => 'لا يمكنك حذف حسابك أثناء تسجيل الدخول.',
        ], 422);
    }

    $email = $user->email;
    $userSnapshot = $user->replicate();
    $userSnapshot->id = $user->id;

    $user->delete();

    if ($email) {
        Mail::to($email)->send(
            new AdminUserChangedMail($userSnapshot, 'deleted')
        );
    }

    return response()->json([
        'message' => 'تم حذف المستخدم بنجاح.',
    ]);
}
}
