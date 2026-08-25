<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;
use App\Domain\Models\PatientProfile;
use App\Domain\Models\EmergencyEvent;
use App\Domain\Models\HospitalPatientQrScan;
use App\Domain\Models\HospitalPatientScanNote;
use App\Domain\Models\HospitalUser;
use App\Domain\Models\MedicalFile;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class HospitalPatientRecordController extends Controller
{
    public function show(Request $request, string $patient): JsonResponse
    {
        $hospitalId = $this->hospitalId($request);

        $this->ensureStaffScannedPatient($request, $hospitalId, $patient);

        $latestScan = $this->latestScan($hospitalId, $patient);

        $filesCount = MedicalFile::query()
            ->where('user_id', $patient)
            ->where(function (Builder $query) use ($hospitalId): void {
                $query->whereNull('hospital_id')
                    ->orWhere('hospital_id', $hospitalId);
            })
            ->count();

        $notesCount = HospitalPatientScanNote::query()
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patient)
            ->count();

        $emergenciesCount = EmergencyEvent::query()
            ->where('user_id', $patient)
            ->count();

        return response()->json([
            'data' => [
                'files_count' => $filesCount,
                'notes_count' => $notesCount,
                'emergencies_count' => $emergenciesCount,
                'latest_scan' => $latestScan === null ? null : [
                    'id' => (string) $latestScan->id,
                    'scanned_at' => $latestScan->scanned_at?->toIso8601String(),
                    'scanned_by' => [
                        'id' => (string) $latestScan->scannedBy?->id,
                        'name' => $latestScan->scannedBy?->name,
                        'employee_code' => $latestScan->scannedBy?->employee_code,
                    ],
                ],
            ],
        ]);
    }

    public function scanHistory(Request $request, string $patient): JsonResponse
    {
        $hospitalId = $this->hospitalId($request);

        $this->ensureStaffScannedPatient($request, $hospitalId, $patient);

        $scans = HospitalPatientQrScan::query()
            ->with('scannedBy:id,name,employee_code')
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patient)
            ->latest('scanned_at')
            ->get();

        return response()->json([
            'data' => $scans->map(
                fn (HospitalPatientQrScan $scan): array => [
                    'id' => (string) $scan->id,
                    'scanned_at' => $scan->scanned_at?->toIso8601String(),
                    'scanned_by' => [
                        'id' => (string) $scan->scannedBy?->id,
                        'name' => $scan->scannedBy?->name,
                        'employee_code' => $scan->scannedBy?->employee_code,
                    ],
                ],
            )->values(),
        ]);
    }

    public function notes(Request $request, string $patient): JsonResponse
    {
        $hospitalId = $this->hospitalId($request);

        $this->ensureStaffScannedPatient($request, $hospitalId, $patient);

        $notes = HospitalPatientScanNote::query()
            ->with([
                'author:id,name,employee_code',
                'scan:id,scanned_at,scanned_by_user_id',
            ])
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patient)
            ->latest('created_at')
            ->get();

        return response()->json([
            'data' => $notes->map(
                fn (HospitalPatientScanNote $note): array => $this->noteData(
                    $note,
                    $request,
                ),
            )->values(),
        ]);
    }

    public function storeNote(Request $request, string $patient): JsonResponse
    {
        $hospitalId = $this->hospitalId($request);

        $this->ensureStaffScannedPatient($request, $hospitalId, $patient);
        $this->ensureCanWriteNotes($request, $hospitalId);

        $validated = $request->validate([
            'note' => ['required', 'string', 'min:1', 'max:2000'],
        ]);

        $latestScan = $this->latestScan($hospitalId, $patient);

        abort_if(
            $latestScan === null,
            422,
            'لا توجد عملية مسح QR للمريض في هذا المستشفى لإرفاق الملاحظة بها.',
        );

        $note = DB::transaction(function () use (
            $hospitalId,
            $patient,
            $latestScan,
            $validated,
            $request,
        ): HospitalPatientScanNote {
            return HospitalPatientScanNote::query()->create([
                'hospital_id' => $hospitalId,
                'patient_id' => $patient,
                'hospital_patient_qr_scan_id' => $latestScan->id,
                'created_by_user_id' => $request->user()->id,
                'note' => trim($validated['note']),
            ]);
        });

        $note->load([
            'author:id,name,employee_code',
            'scan:id,scanned_at,scanned_by_user_id',
        ]);

        return response()->json([
            'message' => 'تمت إضافة الملاحظة بنجاح.',
            'data' => $this->noteData($note, $request),
        ], 201);
    }

    public function destroyNote(
        Request $request,
        string $patient,
        string $note,
    ): JsonResponse {
        $hospitalId = $this->hospitalId($request);

        $this->ensureStaffScannedPatient($request, $hospitalId, $patient);

        $noteModel = HospitalPatientScanNote::query()
            ->whereKey($note)
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patient)
            ->firstOrFail();

        $hospitalRole = $this->staffHospitalRole($request, $hospitalId);

        $canDelete = $hospitalRole === 'admin'
            || (string) $noteModel->created_by_user_id === (string) $request->user()->id;

        abort_unless(
            $canDelete,
            403,
            'يمكنك حذف ملاحظاتك فقط، بينما يملك مدير المستشفى صلاحية حذف جميع الملاحظات.',
        );

        $noteModel->delete();

        return response()->json([
            'message' => 'تم حذف الملاحظة بنجاح.',
        ]);
    }

    private function noteData(
        HospitalPatientScanNote $note,
        Request $request,
    ): array {
        $hospitalId = $this->hospitalId($request);
        $hospitalRole = $this->staffHospitalRole($request, $hospitalId);

        $canDelete = $hospitalRole === 'admin'
            || (string) $note->created_by_user_id === (string) $request->user()->id;

        return [
            'id' => (string) $note->id,
            'note' => $note->note,
            'patient_id' => (string) $note->patient_id,
            'hospital_patient_qr_scan_id' => (string) $note->hospital_patient_qr_scan_id,
            'created_at' => $note->created_at?->toIso8601String(),
            'updated_at' => $note->updated_at?->toIso8601String(),
            'author' => [
                'id' => (string) $note->author?->id,
                'name' => $note->author?->name,
                'employee_code' => $note->author?->employee_code,
            ],
            'scan' => [
                'id' => (string) $note->scan?->id,
                'scanned_at' => $note->scan?->scanned_at?->toIso8601String(),
            ],
            'can_delete' => $canDelete,
        ];
    }
public function updateMedications(
    Request $request,
    string $patient,
): JsonResponse {
    $hospitalId = $this->hospitalId($request);

    $this->ensureStaffScannedPatient($request, $hospitalId, $patient);
    $this->ensureCanUpdateMedications($request, $hospitalId);

    $validated = $request->validate([
        'medications' => ['nullable', 'string', 'max:5000'],
    ]);

    $profile = PatientProfile::query()
        ->where('user_id', $patient)
        ->firstOrFail();

    $medications = trim((string) ($validated['medications'] ?? ''));

    $profile->update([
        'medications' => $medications === '' ? null : $medications,
    ]);

    return response()->json([
        'message' => 'تم تحديث أدوية المريض بنجاح.',
        'data' => [
            'medications' => $profile->fresh()->medications,
        ],
    ]);
}

private function ensureCanUpdateMedications(
    Request $request,
    string $hospitalId,
): void {
    $role = $this->staffHospitalRole($request, $hospitalId);

    abort_unless(
        in_array($role, ['admin', 'doctor'], true),
        403,
        'تعديل أدوية المريض متاح لمدير المستشفى والطبيب فقط.',
    );
}
    private function latestScan(
        string $hospitalId,
        string $patientId,
    ): ?HospitalPatientQrScan {
        return HospitalPatientQrScan::query()
            ->with('scannedBy:id,name,employee_code')
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patientId)
            ->latest('scanned_at')
            ->first();
    }

    private function ensureStaffScannedPatient(
        Request $request,
        string $hospitalId,
        string $patientId,
    ): void {
        User::query()
            ->whereKey($patientId)
            ->where('role', 'patient')
            ->firstOrFail();

        $hasScan = HospitalPatientQrScan::query()
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patientId)
            ->where('scanned_by_user_id', $request->user()->id)
            ->exists();

        abort_unless(
            $hasScan,
            403,
            'لا يمكنك الوصول إلى سجل هذا المريض قبل مسح رمز QR الخاص به.',
        );
    }

    private function ensureCanWriteNotes(
        Request $request,
        string $hospitalId,
    ): void {
        $role = $this->staffHospitalRole($request, $hospitalId);

        abort_unless(
            in_array($role, ['admin', 'doctor', 'nurse'], true),
            403,
            'إضافة الملاحظات متاحة لمدير المستشفى والطبيب والممرض فقط.',
        );
    }

    private function staffHospitalRole(
        Request $request,
        string $hospitalId,
    ): string {
        $role = HospitalUser::query()
            ->where('hospital_id', $hospitalId)
            ->where('user_id', $request->user()->id)
            ->where('is_active', true)
            ->value('role');

        abort_if(
            empty($role),
            403,
            'لا يوجد ربط نشط بين الموظف والمستشفى.',
        );

        return $role instanceof \BackedEnum
            ? (string) $role->value
            : (string) $role;
    }

    private function hospitalId(Request $request): string
    {
        $hospitalId = $request->attributes->get('hospital_id');

        abort_if(
            $hospitalId === null,
            403,
            'تعذر تحديد المستشفى.',
        );

        return (string) $hospitalId;
    }
}