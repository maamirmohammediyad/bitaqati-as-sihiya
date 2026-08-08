<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

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
 public function sos(Request $request, FCMService $fcm, AuditLogService $audit)
    {
        /** @var \App\Models\User $patient */
        $patient = $request->user();

        // 1) إنشاء حدث الطوارئ
        $event = EmergencyEvent::create([
            'patient_id'   => $patient->id,
            'status'       => 'active',
            'triggered_at' => now(),
            // أضف هنا location أو ملاحظات إن وجدت
        ]);

        // 2) تسجيله في سجل التدقيق
        $audit->log('emergency_sos_triggered', [
            'patient_id'   => $patient->id,
            'emergency_id' => $event->id,
        ]);

        // 3) جمع توكنات أولياء المريض
        $guardianTokens = $patient->guardians
            ->pluck('fcm_token')
            ->filter()          // إزالة null / فراغ
            ->values()
            ->all();

        if (! empty($guardianTokens)) {
            $title = 'نداء طوارئ من مريضك';
            $body  = 'المريض ' . ($patient->name ?? 'المرتبط بحسابك') . ' قام بتفعيل زر الطوارئ.';

            $data = [
                'type'         => 'sos',
                'patient_id'   => (string) $patient->id,
                'emergency_id' => (string) $event->id,
            ];

            // استخدام FCMService الذي عندك
            $fcm->sendToMultipleDevices($guardianTokens, $data, $title, $body);
        }

        return response()->json([
            'status' => 'ok',
            'data'   => [
                'event_id' => $event->id,
            ],
        ]);
    }
}
