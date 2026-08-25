<?php

namespace App\Http\Controllers;
use App\Models\User;
use App\Models\HospitalMedication;
use App\Domain\Models\HospitalUser;
use Illuminate\Validation\ValidationException;
use App\Models\PatientMedication;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Domain\Enums\HospitalUserRole;
use App\Domain\Enums\UserRole;
class PatientMedicationController extends Controller
{
    public function index(Request $request, User $patient): JsonResponse
    {
        $this->ensureHospitalUser($request);

        $medications = PatientMedication::query()
            ->where('patient_id', $patient->id)
            ->with([
                'hospitalMedication:id,name,generic_name,recommended_doses',
                'addedBy:id,name',
            ])
            ->latest()
            ->get()
            ->map(function (PatientMedication $item): array {
                return [
                    'id' => $item->id,
                    'dose' => $item->dose,
                    'instructions' => $item->instructions,
                    'created_at' => $item->created_at?->toISOString(),
                    'medication' => [
                        'id' => $item->hospitalMedication?->id,
                        'name' => $item->hospitalMedication?->name,
                        'generic_name' => $item->hospitalMedication?->generic_name,
                        'recommended_doses' =>
                            $item->hospitalMedication?->recommended_doses ?? [],
                    ],
                    'added_by' => [
                        'id' => $item->addedBy?->id,
                        'name' => $item->addedBy?->name,
                    ],
                ];
            })
            ->values();

        return response()->json([
            'data' => $medications,
            'can_update' => $this->canManagePatientMedications($request),
        ]);
    }

    public function store(Request $request, User $patient): JsonResponse {
        $user = $this->ensureHospitalUser($request);

        if (!$this->canManagePatientMedications($request)) {
            return response()->json([
                'message' => 'لا تملك صلاحية إضافة أدوية للمريض.',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'hospital_medication_id' => ['required', 'uuid'],
            'dose' => ['required', 'string', 'max:255'],
            'instructions' => ['nullable', 'string', 'max:500'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'بيانات دواء المريض غير صحيحة.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        $hospitalMedication = HospitalMedication::query()
            ->where('id', $data['hospital_medication_id'])
            ->where('hospital_id', $user->hospital_id)
            ->where('is_active', true)
            ->first();

        if (!$hospitalMedication) {
            return response()->json([
                'message' => 'الدواء المحدد غير متاح في قائمة المستشفى.',
            ], 422);
        }

        $dose = trim($data['dose']);

        if (!in_array(
            $dose,
            $hospitalMedication->recommended_doses ?? [],
            true
        )) {
            return response()->json([
                'message' => 'يجب اختيار جرعة من الجرعات الموصى بها.',
            ], 422);
        }

        $alreadyExists = PatientMedication::query()
            ->where('patient_id', $patient->id)
            ->where('hospital_medication_id', $hospitalMedication->id)
            ->where('dose', $dose)
            ->exists();

        if ($alreadyExists) {
            return response()->json([
                'message' => 'هذا الدواء بهذه الجرعة مضاف للمريض بالفعل.',
            ], 422);
        }

        $patientMedication = PatientMedication::create([
            'patient_id' => $patient->id,
            'hospital_medication_id' => $hospitalMedication->id,
            'dose' => $dose,
            'instructions' => filled($data['instructions'] ?? null)
                ? trim($data['instructions'])
                : null,
            'added_by' => $request->user()->id,
        ]);

        $patientMedication->load([
            'hospitalMedication:id,name,generic_name,recommended_doses',
            'addedBy:id,name',
        ]);

        return response()->json([
            'message' => 'تمت إضافة الدواء للمريض.',
            'data' => [
                'id' => $patientMedication->id,
                'dose' => $patientMedication->dose,
                'instructions' => $patientMedication->instructions,
                'created_at' => $patientMedication->created_at?->toISOString(),
                'medication' => [
                    'id' => $patientMedication->hospitalMedication?->id,
                    'name' => $patientMedication->hospitalMedication?->name,
                    'generic_name' =>
                        $patientMedication->hospitalMedication?->generic_name,
                    'recommended_doses' =>
                        $patientMedication->hospitalMedication?->recommended_doses ?? [],
                ],
                'added_by' => [
                    'id' => $patientMedication->addedBy?->id,
                    'name' => $patientMedication->addedBy?->name,
                ],
            ],
        ], 201);
    }

    public function destroy(
        Request $request,
        User $patient,
        PatientMedication $patientMedication
    ): JsonResponse {
        $user = $this->ensureHospitalUser($request);

        if (!$this->canManagePatientMedications($request)) {
            return response()->json([
                'message' => 'لا تملك صلاحية حذف أدوية المريض.',
            ], 403);
        }

        if ($patientMedication->patient_id !== $patient->id) {
            return response()->json([
                'message' => 'الدواء لا يتبع للمريض المحدد.',
            ], 404);
        }

        $hospitalMedication = $patientMedication->hospitalMedication;

        if (
            !$hospitalMedication ||
            $hospitalMedication->hospital_id !== $user->hospital_id
        ) {
            return response()->json([
                'message' => 'لا تملك صلاحية حذف هذا الدواء.',
            ], 403);
        }

        $patientMedication->delete();

        return response()->json([
            'message' => 'تم حذف الدواء من قائمة المريض.',
        ]);
    }

    private function ensureHospitalUser(Request $request): HospitalUser
{
    $user = $request->user();

    if (!$user) {
        abort(401, 'غير مصادق.');
    }

    $hospitalUser = $user->hospitalUsers()
        ->where('is_active', true)
        ->first();

    if (!$hospitalUser) {
        return throw ValidationException::withMessages([
            'hospital' => ['حساب المستخدم غير مرتبط بمستشفى نشط.'],
        ]);
    }

    return $hospitalUser;
}

private function canManagePatientMedications(Request $request): bool
{
    $user = $request->user();

    if (!$user || $user->role !== UserRole::HealthWorker) {
        return false;
    }

    return $user->hospitalUsers()
        ->where('is_active', true)
        ->whereIn('role', [
            HospitalUserRole::Admin->value,
            HospitalUserRole::Doctor->value,
        ])
        ->exists();
}

public function myMedications(Request $request): JsonResponse
{
    $patient = $request->user();

    if (!$patient || $patient->role !== UserRole::Patient) {
        return response()->json([
            'message' => 'هذه الخدمة متاحة لحسابات المرضى فقط.',
        ], 403);
    }

    $medications = PatientMedication::query()
        ->where('patient_id', $patient->id)
        ->with([
            'hospitalMedication:id,name,generic_name',
            'addedBy:id,name',
        ])
        ->latest()
        ->get()
        ->map(function (PatientMedication $item): array {
            return [
                'id' => $item->id,
                'dose' => $item->dose,
                'instructions' => $item->instructions,
                'created_at' => $item->created_at?->toISOString(),
                'medication' => [
                    'id' => $item->hospitalMedication?->id,
                    'name' => $item->hospitalMedication?->name,
                    'generic_name' => $item->hospitalMedication?->generic_name,
                ],
                'added_by' => [
                    'id' => $item->addedBy?->id,
                    'name' => $item->addedBy?->name,
                ],
            ];
        })
        ->values();

    return response()->json([
        'data' => $medications,
    ]);
}
}