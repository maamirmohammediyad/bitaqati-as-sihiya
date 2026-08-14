<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Domain\Models\EmergencyEventNote;
use App\Http\Requests\Hospital\StoreEmergencyEventNoteRequest;
use App\Domain\Models\EmergencyEvent;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HospitalEmergencyController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['nullable', 'in:checked_in,resolved'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ]);

        $hospitalId = $request->attributes->get('hospital_id');
        $perPage = (int) ($validated['per_page'] ?? 15);

        $availableEmergencies = EmergencyEvent::query()
            ->with('user:id,name,phone,patient_code')
            ->where('status', 'active')
            ->latest('created_at')
            ->paginate(
                $perPage,
                ['*'],
                'available_page',
            );

        $hospitalEmergencies = EmergencyEvent::query()
            ->with([
                'user:id,name,phone,patient_code',
                'resolver:id,name',
            ])
            ->where('checked_in_hospital_id', $hospitalId)
            ->when(
                isset($validated['status']),
                fn ($query) => $query->where(
                    'status',
                    $validated['status'],
                ),
            )
            ->latest('checked_in_at')
            ->paginate(
                $perPage,
                ['*'],
                'hospital_page',
            );

        return response()->json([
            'data' => [
                'available_emergencies' => $availableEmergencies,
                'hospital_emergencies' => $hospitalEmergencies,
            ],
        ]);
    }

    public function show(Request $request, string $id): JsonResponse
{
    $hospitalId = $request->attributes->get('hospital_id');

    if ($hospitalId === null) {
        return response()->json([
            'message' => 'تعذر تحديد المستشفى.',
        ], 403);
    }

    $emergency = EmergencyEvent::query()
        ->with([
            'user:id,name,phone,patient_code',
            'user.patientProfile:id,user_id,full_name,blood_group,allergies,chronic_diseases,medications,emergency_notes',
            'resolver:id,name',
            'checkedInHospital:id,name',
        ])
        ->whereKey($id)
        ->where('checked_in_hospital_id', $hospitalId)
        ->first();

    if ($emergency === null) {
        return response()->json([
            'message' => 'حالة الطوارئ غير موجودة أو لا تتبع لهذا المستشفى.',
        ], 404);
    }

    $patient = $emergency->user;
    $profile = $patient?->patientProfile;

    return response()->json([
        'data' => [
            'id' => (string) $emergency->id,
            'status' => $emergency->status,

            'patient' => [
                'id' => (string) $patient?->id,
                'name' => $profile?->full_name ?? $patient?->name,
                'patient_code' => $patient?->patient_code,
                'phone' => $patient?->phone,
                'blood_group' => $profile?->blood_group?->value ?? $profile?->blood_group,
                'allergies' => $profile?->allergies,
                'chronic_diseases' => $profile?->chronic_diseases,
                'medications' => $profile?->medications,
                'emergency_notes' => $profile?->emergency_notes,
            ],

            'location' => [
                'latitude' => $emergency->latitude,
                'longitude' => $emergency->longitude,
                'location_name' => $emergency->location_name,
            ],

            'hospital' => [
                'id' => (string) $emergency->checked_in_hospital_id,
                'name' => $emergency->checkedInHospital?->name,
            ],

            'check_in' => [
                'checked_in_at' => $emergency->checked_in_at?->toISOString(),
            ],

            'resolution' => [
                'resolved_at' => $emergency->resolved_at?->toISOString(),
                'resolved_by' => [
                    'id' => (string) $emergency->resolved_by,
                    'name' => $emergency->resolver?->name,
                ],
                'notes' => $emergency->resolution_notes,
            ],

            'created_at' => $emergency->created_at?->toISOString(),
            'updated_at' => $emergency->updated_at?->toISOString(),
        ],
    ]);
}

public function notes(Request $request, string $id): JsonResponse
{
    $hospitalId = $request->attributes->get('hospital_id');

    $event = EmergencyEvent::query()
        ->whereKey($id)
        ->where('checked_in_hospital_id', $hospitalId)
        ->first();

    if ($event === null) {
        return response()->json([
            'message' => 'حالة الطوارئ غير موجودة أو لا تتبع لهذا المستشفى.',
        ], 404);
    }

    $notes = EmergencyEventNote::query()
        ->with('author:id,name')
        ->where('emergency_event_id', $event->id)
        ->where('hospital_id', $hospitalId)
        ->latest('created_at')
        ->paginate(20);

    return response()->json([
        'data' => $notes,
    ]);
}

public function storeNote(
    StoreEmergencyEventNoteRequest $request,
    string $id,
): JsonResponse {
    $hospitalId = $request->attributes->get('hospital_id');

    $event = EmergencyEvent::query()
        ->whereKey($id)
        ->where('checked_in_hospital_id', $hospitalId)
        ->first();

    if ($event === null) {
        return response()->json([
            'message' => 'حالة الطوارئ غير موجودة أو لا تتبع لهذا المستشفى.',
        ], 404);
    }

    $note = EmergencyEventNote::create([
        'emergency_event_id' => $event->id,
        'hospital_id' => $hospitalId,
        'author_id' => $request->user()->id,
        'note' => $request->validated('note'),
    ]);

    $note->load('author:id,name');

    return response()->json([
        'message' => 'تمت إضافة الملاحظة بنجاح.',
        'data' => [
            'id' => (string) $note->id,
            'note' => $note->note,
            'author' => [
                'id' => (string) $note->author->id,
                'name' => $note->author->name,
            ],
            'created_at' => $note->created_at?->toISOString(),
        ],
    ], 201);
}
}