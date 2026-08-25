<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use App\Domain\Actions\Auth\LoginAction;
use App\Domain\Actions\Auth\RegisterGuardianAction;
use App\Domain\Actions\Auth\RegisterPatientAction;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterGuardianRequest;
use App\Http\Requests\Auth\RegisterPatientRequest;
use App\Http\Resources\UserResource;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function __construct(
        private readonly RegisterPatientAction   $registerPatientAction,
        private readonly RegisterGuardianAction $registerGuardianAction,
        private readonly LoginAction            $loginAction,
        private readonly AuditLogService        $auditLogService,
    ) {
    }

    public function registerPatient(RegisterPatientRequest $request): JsonResponse
    {
        $result = $this->registerPatientAction->execute($request->validated());

        $this->auditLogService->logLogin($result['user']->id);

        return response()->json([
            'data' => [
                'user'  => new UserResource($result['user']),
                'token' => $result['token'],
            ],
        ], 201);
    }

    public function registerGuardian(RegisterGuardianRequest $request): JsonResponse
    {
        $result = $this->registerGuardianAction->execute($request->validated());

        $this->auditLogService->logLogin($result['user']->id);

        return response()->json([
            'data' => [
                'user'  => new UserResource($result['user']),
                'token' => $result['token'],
            ],
        ], 201);
    }

public function login(LoginRequest $request): JsonResponse
{
    $requestedRole = $request->string('role')->toString();

    if ($requestedRole === 'super_admin') {
        $result = $this->loginAction->executeWithEmail(
            email: $request->string('email')->toString(),
            password: $request->string('password')->toString(),
        );
    } elseif ($requestedRole === 'health_worker') {
        $result = $this->loginAction->executeWithEmployeeCode(
            employeeCode: $request->string('employee_code')->toString(),
            password: $request->string('password')->toString(),
        );
    } else {
        $result = $this->loginAction->execute(
            nationalId: $request->string('national_id')->toString(),
            password: $request->string('password')->toString(),
        );
    }

    /** @var User $user */
    $user = $result['user'];

    $user->load([
    'patientProfile',
    'accountVerificationDocument',
    ]);
    
    if ($user->role->value !== $requestedRole) {
        return response()->json([
            'message' =>'بيانات الدخول غير صحيحة.',
        ], 403);
    }

    $this->auditLogService->logLogin($user->id);

    return response()->json([
        'data' => [
            'user' => new UserResource($user),
            'token' => $result['token'],
        ],
    ]);
}
    public function logout(): JsonResponse
    {
        $user = auth()->user();

        if ($user instanceof User) {
            $this->auditLogService->logLogout($user->id);
            $user->currentAccessToken()->delete();
        }

        return response()->json(['message' => 'Logged out successfully.']);
    }

    public function me(): JsonResponse
    {
        /** @var User $user */
        $user = auth()->user();

        $user->load([
            'patientProfile',
            'guardians.patientProfile',
            'patients.patientProfile',
        ]);

        return response()->json([
            'data' => new UserResource($user),
        ]);
    }
public function updateProfile(Request $request): JsonResponse
{
    /** @var User $user */
    $user = $request->user();

    $data = $request->validate([
        'name' => ['required', 'string', 'max:255'],
        'phone' => ['required', 'string', 'max:30'],
        'email' => ['nullable', 'email', 'max:255'],
    ]);

    $user->update($data);

    return response()->json([
        'data' => new UserResource($user->fresh()),
    ]);
}
public function updatePassword(Request $request): JsonResponse
{
    /** @var User $user */
    $user = $request->user();

    $data = $request->validate([
        'current_password' => ['required', 'string'],
        'password' => ['required', 'string', 'min:8', 'confirmed'],
    ]);

    if (! Hash::check($data['current_password'], $user->password)) {
        throw ValidationException::withMessages([
            'current_password' => ['كلمة المرور الحالية غير صحيحة.'],
        ]);
    }

    $user->update([
        'password' => Hash::make($data['password']),
    ]);

    $user->tokens()->delete();

    return response()->json([
        'message' => 'تم تغيير كلمة المرور. يرجى تسجيل الدخول مرة أخرى.',
    ]);
}
}