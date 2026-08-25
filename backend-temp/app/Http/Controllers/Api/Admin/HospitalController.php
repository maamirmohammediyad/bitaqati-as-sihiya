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
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Domain\Enums\HospitalUserRole;
use App\Models\HospitalStaff;
use App\Mail\HospitalAdminCredentialsMail;
use Illuminate\Support\Facades\Mail;
use App\Domain\Models\HospitalUser;
class HospitalController extends Controller
{
 public function index(Request $request): JsonResponse
{
    $hospitals = Hospital::query()
        ->withCount([
            'hospitalUsers as active_staff_count' => function ($query) {
                $query->where('is_active', true);
            },
            'hospitalUsers as admins_count' => function ($query) {
                $query
                    ->where('is_active', true)
                    ->where('role', 'admin');
            },
        ])
        ->latest()
        ->paginate(20);

    $hospitals->getCollection()->transform(function (Hospital $hospital) {
        $hospital->setAttribute(
            'has_admin',
            (int) $hospital->admins_count > 0
        );

        unset($hospital->admins_count);

        return $hospital;
    });

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

public function storeAdmin(Request $request, Hospital $hospital): JsonResponse
{
    $validated = $request->validate([
        'name' => ['required', 'string', 'max:255'],
        'email' => ['required', 'email', 'max:255'],
        'phone' => ['nullable', 'string', 'max:30'],
        'password' => ['nullable', 'string', 'min:8', 'max:255'],
    ]);

    $hasAdmin = HospitalUser::query()
        ->where('hospital_id', $hospital->id)
        ->where('role', HospitalUserRole::Admin)
        ->where('is_active', true)
        ->exists();

    if ($hasAdmin) {
        return response()->json([
            'message' => 'يوجد مدير نشط لهذا المستشفى بالفعل.',
        ], 422);
    }

    $user = User::query()
        ->where('email', $validated['email'])
        ->first();

    $created = false;

    if ($user === null) {
        if (empty($validated['password'])) {
            return response()->json([
                'message' => 'كلمة المرور المؤقتة مطلوبة عند إنشاء مستخدم جديد.',
            ], 422);
        }

        $user = User::query()->create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'] ?? null,
            'password' => $validated['password'],
            'role' => UserRole::HealthWorker,
            'is_active' => true,
        ]);

        $created = true;
    }
if ($user->role !== UserRole::HealthWorker) {
    return response()->json([
        'message' => 'يمكن اختيار حساب عامل صحة فقط. هذا البريد لا يخص عامل صحة.',
    ], 422);
}
    if ($user->role === UserRole::SuperAdmin) {
        return response()->json([
            'message' => 'لا يمكن ربط مدير المنصة كمدير مستشفى.',
        ], 422);
    }

    if ($user->role !== UserRole::HealthWorker) {
        $user->update([
            'role' => UserRole::HealthWorker,
            'is_active' => true,
        ]);
    }

    $hospitalUser = DB::transaction(function () use ($hospital, $user) {
        return HospitalUser::query()->updateOrCreate(
            [
                'hospital_id' => $hospital->id,
                'user_id' => $user->id,
            ],
            [
                'role' => HospitalUserRole::Admin,
                'is_active' => true,
                'joined_at' => now(),
            ]
        );
    });

    return response()->json([
        'message' => $created
            ? 'تم إنشاء حساب مدير المستشفى وربطه بالمستشفى بنجاح.'
            : 'تم ربط المستخدم الموجود كمدير لهذا المستشفى بنجاح.',
        'data' => [
            'user' => $user->fresh(),
            'hospital_user' => $hospitalUser->fresh(),
            'created' => $created,
        ],
    ], $created ? 201 : 200);
}

    public function update(Request $request, Hospital $hospital): JsonResponse
{
    $validated = $request->validate([
        'name' => ['required', 'string', 'max:255'],
        'type' => ['nullable', 'string', 'max:100'],
        'license_number' => ['nullable', 'string', 'max:255'],
        'address' => ['nullable', 'string', 'max:1000'],
        'city' => ['nullable', 'string', 'max:255'],
        'state' => ['nullable', 'string', 'max:255'],
        'country' => ['nullable', 'string', 'max:255'],
        'postal_code' => ['nullable', 'string', 'max:50'],
        'phone' => ['nullable', 'string', 'max:50'],
        'email' => ['nullable', 'email', 'max:255'],
        'latitude' => ['nullable', 'numeric', 'between:-90,90'],
        'longitude' => ['nullable', 'numeric', 'between:-180,180'],
        'is_active' => ['sometimes', 'boolean'],
        'status' => ['nullable', 'string', 'max:50'],
    ]);

    $hospital->update($validated);

    return response()->json([
        'message' => 'تم تحديث بيانات المؤسسة الصحية بنجاح.',
        'data' => $hospital->fresh(),
    ]);
}

public function destroy(Hospital $hospital): JsonResponse
{
    $hospital->delete();

    return response()->json([
        'message' => 'تم حذف المؤسسة الصحية بنجاح.',
    ]);
}
}