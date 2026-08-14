<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Http\Requests\Emergency\ResolveHospitalEmergencyRequest;
use App\Domain\Actions\Emergency\TriggerSosAction;
use App\Domain\Models\EmergencyEvent;
use App\Http\Controllers\Controller;
use App\Http\Requests\Emergency\ResolveSosRequest;
use App\Http\Requests\Emergency\TriggerSosRequest;
use App\Http\Resources\EmergencyEventResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EmergencyController extends Controller
{
    public function __construct(
        private readonly TriggerSosAction $triggerSosAction,
    ) {}

    public function trigger(TriggerSosRequest $request): JsonResponse
    {
        $event = $this->triggerSosAction->execute(
            userId: $request->user()->id,
            data: $request->validated(),
        );

        return response()->json([
            'data' => new EmergencyEventResource($event),
        ], 201);
    }

    public function resolve(string $id, ResolveSosRequest $request): JsonResponse
    {
        $event = EmergencyEvent::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->firstOrFail();

        $event->update([
            'status' => 'resolved',
            'resolved_at' => now(),
            'resolved_by' => $request->user()->id,
            'resolution_notes' => $request->input('resolution_notes'),
        ]);

        return response()->json([
            'data' => new EmergencyEventResource($event->fresh()),
        ]);
    }
public function current(Request $request): JsonResponse
{
    $event = EmergencyEvent::query()
        ->with([
            'checkedInHospital',
            'user.patientProfile',
            'user.medicalFiles',
            'user.guardians',
        ])
        ->where('user_id', $request->user()->id)
        ->whereIn('status', ['active', 'checked_in'])
        ->latest('created_at')
        ->first();

    return response()->json([
        'data' => $event
            ? new EmergencyEventResource($event)
            : null,
    ]);
}
public function cancel(string $id, Request $request): JsonResponse
{
    $event = EmergencyEvent::query()
        ->where('id', $id)
        ->where('user_id', $request->user()->id)
        ->where('status', 'active')
        ->firstOrFail();

    $event->delete();

    return response()->json([
        'message' => 'تم إلغاء نداء الطوارئ وحذفه.',
    ]);
}
public function checkIn(Request $request, string $id): JsonResponse
{
    $hospitalId = $request->attributes->get('hospital_id');

    if ($hospitalId === null) {
        return response()->json([
            'message' => 'تعذر تحديد المستشفى.',
        ], 403);
    }

    $updated = EmergencyEvent::query()
        ->whereKey($id)
        ->where('status', 'active')
        ->update([
            'status' => 'checked_in',
            'checked_in_hospital_id' => $hospitalId,
            'checked_in_at' => now(),
        ]);

    if ($updated === 0) {
        $exists = EmergencyEvent::query()
            ->whereKey($id)
            ->exists();

        return response()->json([
            'message' => $exists
                ? 'لا يمكن تسجيل وصول هذه الحالة لأنها سُجلت أو أُغلقت مسبقًا.'
                : 'حالة الطوارئ غير موجودة.',
        ], $exists ? 422 : 404);
    }

    $event = EmergencyEvent::query()
        ->with([
            'user:id,name,phone,patient_code',
            'checkedInHospital:id,name,phone,address,city',
        ])
        ->findOrFail($id);

    return response()->json([
        'message' => 'تم تسجيل وصول المريض بنجاح.',
        'data' => new EmergencyEventResource($event),
    ]);
}

public function resolveByHospital(
    ResolveHospitalEmergencyRequest $request,
    string $id,
): JsonResponse {
    $hospitalId = $request->attributes->get('hospital_id');

    if ($hospitalId === null) {
        return response()->json([
            'message' => 'تعذر تحديد المستشفى.',
        ], 403);
    }

    $updated = EmergencyEvent::query()
        ->whereKey($id)
        ->where('status', 'checked_in')
        ->where('checked_in_hospital_id', $hospitalId)
        ->update([
            'status' => 'resolved',
            'resolved_at' => now(),
            'resolved_by' => $request->user()->id,
            'resolution_notes' => $request->validated('resolution_notes'),
        ]);

    if ($updated === 0) {
    $event = EmergencyEvent::query()->find($id);

    if ($event === null) {
        return response()->json([
            'message' => 'حالة الطوارئ غير موجودة.',
        ], 404);
    }

    if ($event->checked_in_hospital_id === null) {
        return response()->json([
            'message' => 'يجب تسجيل وصول الحالة إلى مستشفى أولًا.',
        ], 422);
    }

    if ($event->checked_in_hospital_id !== $hospitalId) {
        return response()->json([
            'message' => 'لا تملك صلاحية إنهاء حالة تابعة لمستشفى آخر.',
        ], 403);
    }

    if ($event->status === 'resolved') {
        return response()->json([
            'message' => 'تم إنهاء هذه الحالة مسبقًا.',
        ], 422);
    }

    return response()->json([
        'message' => 'الحالة ليست في مرحلة تسمح بإنهائها.',
    ], 422);
}

    $event = EmergencyEvent::query()
        ->with([
            'user:id,name,phone,patient_code',
            'checkedInHospital:id,name,phone,address,city',
            'resolver:id,name',
        ])
        ->findOrFail($id);

    return response()->json([
        'message' => 'تم إنهاء حالة الطوارئ بنجاح.',
        'data' => new EmergencyEventResource($event),
    ]);
}

    public function history(Request $request): JsonResponse
    {
        $events = EmergencyEvent::where('user_id', $request->user()->id)
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

    public function show(string $id, Request $request): JsonResponse
    {
        $event = EmergencyEvent::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        return response()->json([
            'data' => new EmergencyEventResource($event),
        ]);
    }
public function guardians(Request $request): JsonResponse
{
    // مؤقتًا بدون أي فلترة على is_verified أو can_access_location
    $user = $request->user()->load('guardians');

    $guardians = $user->guardians->map(function ($g) {
        $pivot = $g->pivot;

        // العلاقة من الـ Enum Relationship أو null
        $relationEnum = $pivot->relationship; // نوعه App\Domain\Enums\Relationship|null
        $relation = $relationEnum?->value;    // يحول Enum إلى string أو يبقيها null

        return [
            'id'       => (string) $g->id,
            'name'     => $g->name,
            'phone'    => $g->phone,
            'relation' => $relation,
        ];
    })->values();

    return response()->json([
        'data' => $guardians,
    ]);
}
}
