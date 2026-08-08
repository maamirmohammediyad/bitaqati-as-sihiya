<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user || ! in_array($user->role->value ?? $user->role, $roles, true)) {
            return new JsonResponse([
                'message' => 'غير مصرح لك بتنفيذ هذه العملية.',
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}