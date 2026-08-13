<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Domain\Enums\FileType;
use Illuminate\Validation\Rule;
use App\Domain\Actions\Patient\CompleteProfileAction;
use App\Domain\Models\PatientProfile;
use App\Domain\Enums\UserRole;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Requests\Patient\CompleteProfileRequest;
use App\Http\Resources\PatientProfileResource;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Domain\Models\MedicalFile;
use App\Domain\Models\EmergencyEventRead;
use App\Http\Resources\MedicalFileResource;
use App\Http\Resources\EmergencyEventResource;
use App\Domain\Models\EmergencyEvent;
use App\Domain\Models\PatientQrToken;
use App\Domain\Models\Hospital;

class PatientController extends Controller
{
    public function __construct(
        private readonly CompleteProfileAction $completeProfileAction,
    ) {}

public function completeProfile(CompleteProfileRequest $request): JsonResponse
{
    /** @var User $authUser */
    $authUser = $request->user();
    \Log::info('HIT_COMPLETE_PROFILE', [
    'auth_id'    => $authUser->id,
    'patient_id' => $request->input('patient_id'),
    ]);
    // لو أرسل patient_id، نعتبر أنه يريد تحديث ملف هذا المريض
    if ($request->filled('patient_id')) {
        // نبحث عن هذا المريض ضمن مرضى هذا الولي (للحماية)
        $patient = $authUser->patients()
            ->where('users.id', $request->input('patient_id'))
            ->firstOrFail();

        $targetUserId = $patient->id;
    } else {
        // لو ما فيه patient_id، نحدّث ملف نفس المستخدم (مريض يسجّل بنفسه مثلاً)
        $targetUserId = $authUser->id;
    }

    $data = collect($request->validated())
    ->except('patient_id')
    ->filter(fn ($value) => $value !== null && $value !== '')
    ->all();

    $profile = $this->completeProfileAction->execute(
        $targetUserId,
        $data,
    );

    return response()->json([
        'data' => new PatientProfileResource($profile),
    ]);
}

    public function showProfile(Request $request): JsonResponse
    {
        $profile = PatientProfile::where('user_id', $request->user()->id)->firstOrFail();

        return response()->json([
            'data' => new PatientProfileResource($profile),
        ]);
    }

    public function myPatients(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $patients = $user->patients()
            ->with('patientProfile')
            ->get();

        return response()->json([
            'data' => UserResource::collection($patients),
        ]);
    }

    public function guardianShowPatient(string $id, Request $request): JsonResponse
    {
        /** @var User $guardian */
        $guardian = $request->user();

        // هنا نحدد users.id حتى لا يصبح العمود id غامضاً في join
        $patient = $guardian->patients()
            ->with('patientProfile')
            ->where('users.id', $id)
            ->firstOrFail();

        return response()->json([
            'data' => new UserResource($patient),
        ]);
    }

    public function patientMedicalFiles(string $id): JsonResponse
    {
        /** @var User $guardian */
        $guardian = auth()->user();

        // نفس الفكرة: تحديد users.id بوضوح
        $patient = $guardian->patients()
            ->where('users.id', $id)
            ->firstOrFail();

        $files = $patient->medicalFiles()->latest()->get();

        return response()->json([
            'data' => MedicalFileResource::collection($files),
        ]);
    }
public function myMedicalFiles(Request $request)
{
    $user = $request->user();

    $files = MedicalFile::where('user_id', $user->id)
        ->orderByDesc('created_at')
        ->get(); // أو paginate

    return MedicalFileResource::collection($files);
}

public function myEmergencies(Request $request)
{
    $user = $request->user();

    $events = EmergencyEvent::where('user_id', $user->id)
        ->orderByDesc('created_at')
        ->paginate(20);

    return EmergencyEventResource::collection($events);
}
    public function guardianPatientDashboard(string $id, Request $request): JsonResponse
    {
        /** @var \App\Domain\Models\User $guardian */
        $guardian = $request->user();

        // تأكد أن هذا المريض فعلاً مرتبط بهذا الولي (عبر علاقة patients/guardians)
        // واستخدم users.id بدلاً من id فقط لتجنب الغموض في الاستعلام
        $patient = $guardian->patients()
            ->with(['patientProfile'])
            ->where('users.id', $id)
            ->firstOrFail();

        // 1) معلومات الملف الشخصي
        $profile = $patient->patientProfile;

        // 2) إحصائيات الطوارئ
        $emergencyQuery = EmergencyEvent::where('user_id', $patient->id);
        $emergencyCount = $emergencyQuery->count();
        $lastEmergency  = $emergencyQuery->orderByDesc('created_at')->first();

        // 3) الملفات الطبية
        $medicalFilesQuery = $patient->medicalFiles();
        $medicalFilesCount = $medicalFilesQuery->count();
        $recentMedicalFiles = $medicalFilesQuery
            ->orderByDesc('created_at')
            ->limit(5)
            ->get();

        // 4) QR Token الحالي (آخر واحد ساري)
        $qrToken = PatientQrToken::where('user_id', $patient->id)
            ->orderByDesc('created_at')
            ->first();

        // 5) جهات الاتصال في الطوارئ
        $emergencyContacts = $patient->emergencyContacts()->get();

        // 6) المستشفيات النشطة
        $hospitals = Hospital::where('is_active', true)
            ->orderBy('name')
            ->limit(10)
            ->get();

        return response()->json([
            'data' => [
                'patient' => new UserResource($patient),

                'profile' => $profile ? [
    'full_name' => $profile->full_name,
    'date_of_birth' => optional($profile->date_of_birth)?->toDateString(),
    'blood_group' => $profile->blood_group?->value,
    'gender' => $profile->gender,
    'height_cm' => $profile->height_cm,
    'weight_kg' => $profile->weight_kg,
    'allergies' => $profile->allergies,
    'chronic_diseases' => $profile->chronic_diseases,
    'is_profile_complete' => (bool) $profile->is_profile_complete,
] : null,

                'emergency' => [
                    'count'      => $emergencyCount,
                    'last_event' => $lastEmergency
                        ? new EmergencyEventResource($lastEmergency)
                        : null,
                ],

                'medical_files' => [
                    'count'  => $medicalFilesCount,
                    'recent' => MedicalFileResource::collection($recentMedicalFiles),
                ],

                'qr' => $qrToken ? [
                    'token'      => $qrToken->token,
                    'expires_at' => $qrToken->expires_at?->toIso8601String(),
                    'is_valid'   => $qrToken->isValid(),
                ] : null,

                'emergency_contacts' => $emergencyContacts->map(function ($contact) {
                    return [
                        'id'            => $contact->id,
                        'full_name'     => $contact->full_name,
                        'phone'         => $contact->phone,
                        'relationship'  => $contact->relationship,
                        'is_notifiable' => (bool) $contact->is_notifiable,
                    ];
                }),

                'hospitals' => $hospitals->map(function ($hospital) {
                    return [
                        'id'        => $hospital->id,
                        'name'      => $hospital->name,
                        'city'      => $hospital->city,
                        'state'     => $hospital->state,
                        'country'   => $hospital->country,
                        'latitude'  => $hospital->latitude,
                        'longitude' => $hospital->longitude,
                        'phone'     => $hospital->phone,
                    ];
                }),
            ],
        ]);
    }

public function guardianPatientEmergencies(
    string $id,
    Request $request,
): JsonResponse {
    /** @var User $guardian */
    $guardian = $request->user();

    $patient = $guardian->patients()
        ->where('users.id', $id)
        ->firstOrFail();

    $events = EmergencyEvent::query()
        ->where('user_id', $patient->id)
        ->withExists([
            'reads as is_read' => fn ($query) => $query
                ->where('guardian_id', $guardian->id),
        ])
        ->orderByDesc('created_at')
        ->get();

    return response()->json([
        'data' => EmergencyEventResource::collection($events),
    ]);
}

public function uploadMedicalFile(Request $request, string $id): JsonResponse
{
    /** @var User $guardian */
    $guardian = $request->user();

    // لا يسمح إلا للولي المرتبط بالمريض برفع ملفه
    $patient = $guardian->patients()
        ->where('users.id', $id)
        ->firstOrFail();

    $validated = $request->validate([
        'file' => ['required', 'file', 'max:10240'],
        'file_type' => ['nullable', Rule::enum(FileType::class)],
        'description' => ['nullable', 'string', 'max:255'],
    ]);

    $uploadedFile = $validated['file'];

    $path = $uploadedFile->store(
        "medical_files/{$patient->id}",
        'public',
    );

    $medicalFile = MedicalFile::create([
        'user_id' => $patient->id,
        'original_name' => $uploadedFile->getClientOriginalName(),
        'storage_path' => $path,
        'mime_type' => $uploadedFile->getClientMimeType(),
        'size_bytes' => $uploadedFile->getSize(),
        'file_type' => $validated['file_type'] ?? null,
        'description' => $validated['description'] ?? null,
    ]);

    return response()->json([
        'data' => new MedicalFileResource($medicalFile),
    ], 201);
}
public function guardianPatientEmergencyDetail(
    string $patientId,
    string $eventId,
    Request $request,
): JsonResponse {
    /** @var User $guardian */
    $guardian = $request->user();

    $patient = $guardian->patients()
        ->where('users.id', $patientId)
        ->firstOrFail();

    $event = EmergencyEvent::query()
        ->where('id', $eventId)
        ->where('user_id', $patient->id)
        ->withExists([
            'reads as is_read' => fn ($query) => $query
                ->where('guardian_id', $guardian->id),
        ])
        ->firstOrFail();

    return response()->json([
        'data' => new EmergencyEventResource($event),
    ]);
}
public function markGuardianEmergencyAsRead(
    string $patientId,
    string $eventId,
    Request $request,
): JsonResponse {
    /** @var User $guardian */
    $guardian = $request->user();

    $patient = $guardian->patients()
        ->where('users.id', $patientId)
        ->firstOrFail();

    $event = EmergencyEvent::query()
        ->where('id', $eventId)
        ->where('user_id', $patient->id)
        ->firstOrFail();

    $read = EmergencyEventRead::firstOrCreate(
        [
            'emergency_event_id' => $event->id,
            'guardian_id' => $guardian->id,
        ],
        [
            'read_at' => now(),
        ],
    );

    return response()->json([
        'data' => [
            'event_id' => $event->id,
            'is_read' => true,
            'read_at' => $read->read_at?->toIso8601String(),
        ],
    ]);
}
public function updateMyEmail(Request $request): JsonResponse
{
    /** @var User $user */
    $user = $request->user();

    if ($user->role !== UserRole::Patient) {
        abort(403, 'هذه العملية متاحة للمريض فقط.');
    }

    $data = $request->validate([
        'email' => [
            'required',
            'email',
            'max:255',
            Rule::unique('users', 'email')->ignore($user->id),
        ],
    ]);

    $user->update([
        'email' => strtolower(trim($data['email'])),
    ]);

    return response()->json([
        'message' => 'تم حفظ البريد الإلكتروني بنجاح.',
        'data' => new UserResource($user->fresh()),
    ]);
}
}