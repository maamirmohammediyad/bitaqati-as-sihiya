<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Domain\Models\EmergencyEventNote;
use App\Http\Requests\Hospital\StoreEmergencyEventNoteRequest;
use App\Domain\Models\EmergencyEvent;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Domain\Models\PatientQrToken;
use Illuminate\Support\Facades\DB;
use App\Domain\Models\Hospital;
use App\Domain\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Domain\Models\HospitalPatientQrScan;
use App\Enums\EmergencyStatus;
use App\Http\Resources\EmergencyEventResource;
class HospitalEmergencyController extends Controller
{
public function index(Request $request): JsonResponse
{
    $validated = $request->validate([
        'status' => ['nullable', 'in:checked_in,resolved'],
        'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
    ]);

    $hospitalId = $request->attributes->get('hospital_id');

    abort_if(
        $hospitalId === null,
        403,
        'لا يوجد مستشفى مرتبط بحساب الموظف.'
    );

    $hospital = Hospital::query()
        ->select(['id', 'latitude', 'longitude'])
        ->findOrFail($hospitalId);

    $perPage = (int) ($validated['per_page'] ?? 15);

    $scanStatistics = HospitalPatientQrScan::query()
        ->where('hospital_id', $hospitalId)
        ->select([
            'patient_id',
            DB::raw('COUNT(*) as scan_count'),
            DB::raw('MAX(scanned_at) as last_scanned_at'),
        ])
        ->groupBy('patient_id');

    $baseWith = [
        'user:id,name,phone,patient_code',
        'user.patientProfile:user_id,full_name,blood_group',
    ];

    $availableEmergencies = EmergencyEvent::query()
        // ->visibleToHospital($hospital)
        ->with($baseWith)
        ->leftJoinSub(
            $scanStatistics,
            'qr_scans',
            function ($join) {
                $join->on(
                    'emergency_events.user_id',
                    '=',
                    'qr_scans.patient_id'
                );
            }
        )
        ->where('emergency_events.status', 'active')
        ->whereNull('emergency_events.checked_in_hospital_id')
        ->select('emergency_events.*')
        ->selectRaw('COALESCE(qr_scans.scan_count, 0) as scan_count')
        ->addSelect([
            'last_scanned_at' => HospitalPatientQrScan::query()
                ->select('scanned_at')
                ->where('hospital_id', $hospitalId)
                ->whereColumn(
                    'hospital_patient_qr_scans.patient_id',
                    'emergency_events.user_id'
                )
                ->latest('scanned_at')
                ->limit(1),

            'last_scanned_by_user_id' => HospitalPatientQrScan::query()
                ->select('scanned_by_user_id')
                ->where('hospital_id', $hospitalId)
                ->whereColumn(
                    'hospital_patient_qr_scans.patient_id',
                    'emergency_events.user_id'
                )
                ->latest('scanned_at')
                ->limit(1),
        ])
        ->orderByRaw(
            'CASE WHEN qr_scans.scan_count > 0 THEN 1 ELSE 0 END DESC'
        )
        ->orderByDesc('qr_scans.last_scanned_at')
        ->orderByDesc('emergency_events.created_at')
        ->paginate($perPage, ['*'], 'available_page')
        ->withQueryString();

    $hospitalEmergencies = EmergencyEvent::query()
        ->with([
            ...$baseWith,
            'resolver:id,name',
        ])
        ->leftJoinSub(
            $scanStatistics,
            'qr_scans',
            function ($join) {
                $join->on(
                    'emergency_events.user_id',
                    '=',
                    'qr_scans.patient_id'
                );
            }
        )
        ->where('emergency_events.checked_in_hospital_id', $hospitalId)
        ->when(
            isset($validated['status']),
            fn ($query) => $query->where(
                'emergency_events.status',
                $validated['status']
            )
        )
        ->select('emergency_events.*')
        ->selectRaw('COALESCE(qr_scans.scan_count, 0) as scan_count')
        ->addSelect([
            'last_scanned_at' => HospitalPatientQrScan::query()
                ->select('scanned_at')
                ->where('hospital_id', $hospitalId)
                ->whereColumn(
                    'hospital_patient_qr_scans.patient_id',
                    'emergency_events.user_id'
                )
                ->latest('scanned_at')
                ->limit(1),

            'last_scanned_by_user_id' => HospitalPatientQrScan::query()
                ->select('scanned_by_user_id')
                ->where('hospital_id', $hospitalId)
                ->whereColumn(
                    'hospital_patient_qr_scans.patient_id',
                    'emergency_events.user_id'
                )
                ->latest('scanned_at')
                ->limit(1),
        ])
        ->orderByRaw(
            'CASE WHEN qr_scans.scan_count > 0 THEN 1 ELSE 0 END DESC'
        )
        ->orderByDesc('qr_scans.last_scanned_at')
        ->latest('emergency_events.checked_in_at')
        ->paginate($perPage, ['*'], 'hospital_page')
        ->withQueryString();

    $staffNames = User::query()
        ->whereIn(
            'id',
            collect([
                ...$availableEmergencies->getCollection(),
                ...$hospitalEmergencies->getCollection(),
            ])
                ->pluck('last_scanned_by_user_id')
                ->filter()
                ->unique()
                ->values()
        )
        ->pluck('name', 'id');

    $formatEmergency = function (EmergencyEvent $event) use ($staffNames): array {
        $patient = $event->user;
        $profile = $patient?->patientProfile;

        $scanCount = (int) ($event->scan_count ?? 0);
        $lastScannerId = $event->last_scanned_by_user_id;

        return [
            'id' => (string) $event->id,
            'status' => $event->status?->value ?? $event->status,
            'created_at' => $event->created_at?->toISOString(),
            'updated_at' => $event->updated_at?->toISOString(),
            'checked_in_at' => $event->checked_in_at?->toISOString(),
            'priority' => $scanCount > 0,
            'patient' => [
                'id' => (string) $patient?->id,
                'name' => $profile?->full_name ?? $patient?->name,
                'patient_code' => $patient?->patient_code,
                'phone' => $patient?->phone,
                'blood_group' => $profile?->blood_group?->value
                    ?? $profile?->blood_group,
            ],
            'qr_scan' => [
                'scan_count' => $scanCount,
                'last_scanned_at' => $event->last_scanned_at,
                'last_scanned_by' => $lastScannerId
                    ? [
                        'id' => (string) $lastScannerId,
                        'name' => $staffNames[$lastScannerId] ?? 'موظف المستشفى',
                    ]
                    : null,
            ],
        ];
    };

    $availableEmergencies->setCollection(
        $availableEmergencies->getCollection()
            ->map($formatEmergency)
            ->values()
    );

    $hospitalEmergencies->setCollection(
        $hospitalEmergencies->getCollection()
            ->map($formatEmergency)
            ->values()
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
            'user:id,name,phone,email,national_id,patient_code',
            'user.patientProfile:id,user_id,full_name,date_of_birth,blood_group,gender,height_cm,weight_kg,allergies,chronic_diseases,medications,emergency_notes',
            'user.medicalFiles' => function ($query) use ($hospitalId) {
                $query
                    ->select([
                        'id',
                        'user_id',
                        'hospital_id',
                        'original_name',
                        'mime_type',
                        'size_bytes',
                        'file_type',
                        'description',
                        'created_at',
                    ])
                    ->where('hospital_id', $hospitalId)
                    ->latest('created_at');
            },
            'resolver:id,name',
            'checkedInHospital:id,name,phone,address,city',
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

    $medicalFiles = $patient?->medicalFiles
        ->map(function ($file) use ($patient) {
            return [
                'id' => (string) $file->id,
                'original_name' => $file->original_name,
                'mime_type' => $file->mime_type,
                'size_bytes' => $file->size_bytes,
                'file_type' => $file->file_type?->value ?? $file->file_type,
                'description' => $file->description,
                'created_at' => $file->created_at?->toISOString(),
                'download_url' => url(
                    "/api/hospital/patients/{$patient->id}/medical-files/{$file->id}/download"
                ),
            ];
        })
        ->values()
        ->all() ?? [];

    return response()->json([
        'data' => [
            'id' => (string) $emergency->id,
            'status' => $emergency->status,
            'created_at' => $emergency->created_at?->toISOString(),
            'updated_at' => $emergency->updated_at?->toISOString(),

            'patient' => [
                'id' => (string) $patient?->id,
                'name' => $profile?->full_name ?? $patient?->name,
                'patient_code' => $patient?->patient_code,
                'national_id' => $patient?->national_id,
                'phone' => $patient?->phone,
                'email' => $patient?->email,

                'date_of_birth' => $profile?->date_of_birth?->format('Y-m-d'),
                'gender' => $profile?->gender,
                'height_cm' => $profile?->height_cm,
                'weight_kg' => $profile?->weight_kg,

                'blood_group' => $profile?->blood_group?->value
                    ?? $profile?->blood_group,
                'allergies' => $profile?->allergies,
                'chronic_diseases' => $profile?->chronic_diseases,
                'medications' => $profile?->medications,
                'emergency_notes' => $profile?->emergency_notes,

                'medical_files' => $medicalFiles,
            ],

            'location' => [
                'latitude' => $emergency->latitude,
                'longitude' => $emergency->longitude,
                'location_name' => $emergency->location_name,
            ],

            'hospital' => [
                'id' => (string) $emergency->checked_in_hospital_id,
                'name' => $emergency->checkedInHospital?->name,
                'phone' => $emergency->checkedInHospital?->phone,
                'address' => $emergency->checkedInHospital?->address,
                'city' => $emergency->checkedInHospital?->city,
            ],

            'check_in' => [
                'checked_in_at' => $emergency->checked_in_at?->toISOString(),
            ],

            'resolution' => [
                'resolved_at' => $emergency->resolved_at?->toISOString(),
                'resolved_by' => [
                    'id' => $emergency->resolved_by
                        ? (string) $emergency->resolved_by
                        : null,
                    'name' => $emergency->resolver?->name,
                ],
                'notes' => $emergency->resolution_notes,
            ],
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

public function scanPatientQrForEmergency(Request $request): JsonResponse
{
    $validated = $request->validate([
        'qr_token' => ['required', 'string', 'max:2048'],
    ]);

    $hospitalId = $request->attributes->get('hospital_id');

    if ($hospitalId === null) {
        return response()->json([
            'message' => 'تعذر تحديد المستشفى.',
        ], 403);
    }
$result = DB::transaction(function () use ($validated, $hospitalId) {
    $scannedValue = trim($validated['qr_token']);

    // أولاً: إذا كان الـ QR يحمل رقم حدث الطوارئ نفسه.
    $event = EmergencyEvent::query()
        ->whereKey($scannedValue)
        ->where('status', 'active')
        ->whereNull('checked_in_hospital_id')
        ->lockForUpdate()
        ->first();

    // ثانياً: إذا كان QR خاصًا ببطاقة المريض.
    if ($event === null) {
        $qr = PatientQrToken::query()
            ->with('patient')
            ->where('token', $scannedValue)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if ($qr === null || $qr->patient === null) {
            abort(404, 'رمز QR غير صالح أو منتهي الصلاحية.');
        }

        $event = EmergencyEvent::query()
            ->where('user_id', $qr->patient->id)
            ->where('status', 'active')
            ->whereNull('checked_in_hospital_id')
            ->latest('created_at')
            ->lockForUpdate()
            ->first();

        if ($event === null) {
            abort(422, 'لا توجد حالة طوارئ نشطة لهذا المريض.');
        }
    }

    $event->update([
        'status' => 'checkedin',
        'checked_in_hospital_id' => $hospitalId,
        'checked_in_at' => now(),
    ]);

    return EmergencyEvent::query()
        ->with([
            'user:id,name,phone,email,national_id,patient_code',
            'user.patientProfile:id,user_id,full_name,blood_group,allergies,chronic_diseases,medications,emergency_notes',
            'checkedInHospital:id,name,phone,address,city',
        ])
        ->findOrFail($event->id);
});

    $patient = $result->user;
    $profile = $patient?->patientProfile;

    return response()->json([
        'message' => 'تم التحقق من QR وتسجيل وصول المريض للطوارئ بنجاح.',
        'data' => [
            'id' => (string) $result->id,
            'status' => $result->status,
            'checked_in_at' => $result->checked_in_at?->toISOString(),
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
                'national_id' => $patient?->national_id,
'email' => $patient?->email,
'medical_files' => $patient?->medicalFiles
    ->map(fn ($file) => [
        'id' => (string) $file->id,
        'original_name' => $file->original_name,
        'mime_type' => $file->mime_type,
        'size_bytes' => $file->size_bytes,
        'file_type' => $file->file_type?->value ?? $file->file_type,
        'description' => $file->description,
        'created_at' => $file->created_at?->toISOString(),
    ])
    ->values()
    ->all() ?? [],
            ],
        ],
    ]);
}

public function resolve(
    Request $request,
    EmergencyEvent $emergency
): JsonResponse {
    $hospitalId = $request->attributes->get('hospital_id');

    abort_if(
        $hospitalId === null,
        403,
        'حسابك غير مرتبط بمستشفى نشط.'
    );

    abort_unless(
        (string) $emergency->checked_in_hospital_id === (string) $hospitalId,
        403,
        'لا يمكنك إنهاء حالة ليست ضمن مستشفاك.'
    );

    $validated = $request->validate([
        'resolution_notes' => ['nullable', 'string', 'max:2000'],
    ]);

    // لا تعتمد على Enum في هذه المرحلة حتى نتجنب عدم تطابق القيم.
    if (
        in_array((string) $emergency->status, ['resolved'], true) ||
        $emergency->resolved_at !== null
    ) {
        return response()->json([
            'message' => 'تم إنهاء هذه الحالة مسبقًا.',
            'data' => new EmergencyEventResource(
                $emergency->load([
                    'user',
                    'checkedInHospital',
                    'resolver',
                ])
            ),
        ]);
    }

    $emergency->update([
        'status' => 'resolved',
        'resolved_at' => now(),
        'resolved_by' => $request->user()->id,
        'resolution_notes' => $validated['resolution_notes'] ?? null,
    ]);

    return response()->json([
        'message' => 'تم إنهاء الحالة بنجاح.',
        'data' => new EmergencyEventResource(
            $emergency->fresh()->load([
                'user',
                'checkedInHospital',
                'resolver',
            ])
        ),
    ]);
}
}