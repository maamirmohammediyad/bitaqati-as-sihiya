<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Domain\Models\User;
use App\Domain\Models\PatientProfile;
use App\Domain\Models\EmergencyEvent;
use App\Domain\Models\MedicalFile;
use App\Domain\Models\PatientQrToken;
use App\Domain\Models\Hospital;

use App\Http\Resources\UserResource;
use App\Http\Resources\EmergencyEventResource;
use App\Http\Resources\MedicalFileResource;

class PatientQrController extends Controller
{
    // إصدار / تجديد توكن QR للمريض الحالي
    public function issue(Request $request): JsonResponse
    {
   /** @var User $user */
    $user = $request->user();

    // لم نعد نتحقق من role، لأن شاشة QR موجودة فقط في واجهة المريض

    PatientQrToken::where('user_id', $user->id)
        ->where('expires_at', '<', now())
        ->delete();

    $plainToken = Str::random(40);

    $qr = PatientQrToken::create([
        'user_id'    => $user->id,
        'token'      => hash('sha256', $plainToken),
        'expires_at' => now()->addDay(),
    ]);

    return response()->json([
        'data' => [
            'token'      => $plainToken,
            'expires_at' => $qr->expires_at->toIso8601String(),
        ],
    ]);
}

    // قراءة بيانات المريض من توكن QR
  public function show(string $token): JsonResponse
{
    $hashed = hash('sha256', $token);

    /** @var PatientQrToken|null $qr */
    $qr = PatientQrToken::with('user')
        ->where('token', $hashed)
        ->where('expires_at', '>', now())
        ->first();

    if (! $qr || ! $qr->isValid()) {
        return response()->json([
            'message' => 'QR code is invalid or expired.',
        ], 404);
    }

    /** @var User $patient */
    $patient = $qr->user;

    // 1) الملف الشخصي
    $profile = PatientProfile::where('user_id', $patient->id)->first();

    // 2) الطوارئ
    $emergencyQuery = EmergencyEvent::where('user_id', $patient->id);
    $emergencyCount = $emergencyQuery->count();
    $lastEmergency  = $emergencyQuery->orderByDesc('created_at')->first();

    // 3) الملفات الطبية
    $medicalFilesQuery = MedicalFile::where('user_id', $patient->id)
        ->orderByDesc('created_at');

    $medicalFilesCount = (clone $medicalFilesQuery)->count();
    $recentMedicalFiles = $medicalFilesQuery
        ->limit(5)
        ->get();

    // 4) QR نفسه
    $qrToken = $qr;

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

            'qr' => [
                'token'      => $token,
                'expires_at' => $qrToken->expires_at?->toIso8601String(),
                'is_valid'   => $qrToken->isValid(),
            ],

            'emergency_contacts' => $emergencyContacts->map(function ($contact) {
                return [
                    'id'           => $contact->id,
                    'full_name'    => $contact->full_name,
                    'phone'        => $contact->phone,
                    'relationship' => $contact->relationship,
                    'is_notifiable'=> (bool) $contact->is_notifiable,
                ];
            }),

            'hospitals' => $hospitals->map(function (Hospital $hospital) {
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
public function issueForGuardian(Request $request, string $id): JsonResponse
{
    /** @var User $guardian */
    $guardian = $request->user();

    $patient = $guardian->patients()
        ->where('users.id', $id)
        ->first();

    if (! $patient) {
        return response()->json([
            'message' => 'هذا المريض غير مرتبط بحسابك.',
        ], 403);
    }

    PatientQrToken::where('user_id', $patient->id)
        ->where('expires_at', '<', now())
        ->delete();

    $plainToken = Str::random(40);

    $qr = PatientQrToken::create([
        'user_id' => $patient->id,
        'token' => hash('sha256', $plainToken),
        'expires_at' => now()->addDay(),
    ]);

    return response()->json([
        'data' => [
            'token' => $plainToken,
            'expires_at' => $qr->expires_at->toIso8601String(),
        ],
    ]);
}
}