<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Domain\Enums\HospitalUserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureHospitalStaff
{
    public function handle(
        Request $request,
        Closure $next,
        string ...$allowedRoles,
    ): Response {
        $user = $request->user();

        if ($user === null || $user->role->value !== 'health_worker') {
            return response()->json([
                'message' => 'غير مصرح لك بالوصول إلى موارد المستشفى.',
            ], 403);
        }

        $allowedRoleValues = collect($allowedRoles)
            ->map(static fn (string $role) => HospitalUserRole::tryFrom($role))
            ->filter()
            ->map(static fn (HospitalUserRole $role) => $role->value)
            ->values()
            ->all();

        if ($allowedRoles !== [] && $allowedRoleValues === []) {
            return response()->json([
                'message' => 'إعداد صلاحيات المستشفى غير صحيح.',
            ], 500);
        }

        $hospitalUser = $user->hospitalUsers()
            ->where('is_active', true)
            ->when(
                $allowedRoleValues !== [],
                fn ($query) => $query->whereIn('role', $allowedRoleValues),
            )
            ->with('hospital')
            ->first();

        if ($hospitalUser === null || ! $hospitalUser->hospital?->is_active) {
            return response()->json([
                'message' => 'لا تملك صلاحية نشطة ضمن مستشفى معتمد.',
            ], 403);
        }

        $request->attributes->set('hospital_user', $hospitalUser);
        $request->attributes->set('hospital_id', $hospitalUser->hospital_id);

        return $next($request);
    }
}