<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Domain\Enums\FileType;
use Illuminate\Validation\Rule;
use App\Domain\Actions\Patient\CompleteProfileAction;
use App\Domain\Models\PatientProfile;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Requests\Patient\CompleteProfileRequest;
use App\Http\Resources\PatientProfileResource;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Domain\Models\MedicalFile;
// تأكد من استيراد هذه الموارد/الموديلات إن لم تكن مستوردة مسبقاً
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

    $data = $request->validated();
    unset($data['patient_id']);

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
                    'full_name'           => $profile->full_name,
                    'date_of_birth'       => optional($profile->date_of_birth)?->toDateString(),
                    'blood_group'         => $profile->blood_group?->value,
                    'gender'              => $profile->gender,
                    'height_cm'           => $profile->height_cm,
                    'weight_kg'           => $profile->weight_kg,
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

public function guardianPatientEmergencies(string $id, Request $request): JsonResponse
{
    $guardian = $request->user();

    // تأكد أن هذا المريض مرتبط بهذا الولي (لكن بدون استخدام Middleware الدور)
    $isLinked = $guardian->patients()
        ->where('patient_id', $id)
        ->exists();

    if (! $isLinked) {
        return response()->json([
            'message' => 'You are not authorized to view this patient emergencies.',
        ], 403);
    }

    $events = EmergencyEvent::where('user_id', $id)
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
}