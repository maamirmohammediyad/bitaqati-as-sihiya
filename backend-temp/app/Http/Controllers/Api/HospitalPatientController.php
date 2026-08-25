<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Domain\Models\HospitalPatientQrScan;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HospitalPatientController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $hospitalId = $this->hospitalId($request);

        $validated = $request->validate([
            'employee_id' => ['nullable', 'uuid'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);

        $perPage = (int) ($validated['per_page'] ?? 20);

        $scans = HospitalPatientQrScan::query()
            ->with([
                'patient:id,name,phone,patient_code',
                'patient.patientProfile:user_id,full_name,blood_group',
                'scannedBy:id,name,employee_code',
            ])
            ->where('hospital_id', $hospitalId)
            ->when(
                isset($validated['employee_id']),
                fn ($query) => $query->where(
                    'scanned_by_user_id',
                    $validated['employee_id'],
                ),
            )
            ->orderBy('scanned_at', 'asc')
            ->paginate($perPage);

        return response()->json([
            'data' => $scans->through(
                fn (HospitalPatientQrScan $scan): array => $this->scanData($scan),
            ),
        ]);
    }

public function myScans(Request $request): JsonResponse
{
    $hospitalId = $this->hospitalId($request);

    $validated = $request->validate([
        'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
    ]);

    $perPage = (int) ($validated['per_page'] ?? 20);

    $scans = HospitalPatientQrScan::query()
        ->select('patient_id')
        ->selectRaw('COUNT(*) as scan_count')
        ->selectRaw('MAX(scanned_at) as last_scanned_at')
        ->where('hospital_id', $hospitalId)
        ->where('scanned_by_user_id', $request->user()->id)
        ->groupBy('patient_id')
        ->with([
            'patient:id,name,phone,patient_code',
            'patient.patientProfile:user_id,full_name,blood_group',
        ])
        ->orderByDesc('last_scanned_at')
        ->paginate($perPage);

    return response()->json([
        'data' => $scans->through(function (HospitalPatientQrScan $scan): array {
            return [
                'patient' => [
                    'id' => (string) $scan->patient?->id,
                    'name' => $scan->patient?->patientProfile?->full_name
                        ?? $scan->patient?->name,
                    'patient_code' => $scan->patient?->patient_code,
                    'phone' => $scan->patient?->phone,
                    'blood_group' => $scan->patient?->patientProfile?->blood_group?->value,
                ],
                'scan_count' => (int) $scan->scan_count,
                'last_scanned_at' => $scan->last_scanned_at,
            ];
        }),
    ]);
}

    private function hospitalId(Request $request): string
    {
        $hospitalId = $request->attributes->get('hospital_id');

        abort_if($hospitalId === null, 403, 'تعذر تحديد المستشفى.');

        return (string) $hospitalId;
    }

    private function scanData(HospitalPatientQrScan $scan): array
    {
        return [
            'id' => (string) $scan->id,
            'scanned_at' => $scan->scanned_at?->toISOString(),

            'patient' => [
                'id' => (string) $scan->patient?->id,
                'name' => $scan->patient?->patientProfile?->full_name
                    ?? $scan->patient?->name,
                'patient_code' => $scan->patient?->patient_code,
                'phone' => $scan->patient?->phone,
                'blood_group' => $scan->patient?->patientProfile?->blood_group?->value,
            ],

            'scanned_by' => [
                'id' => (string) $scan->scannedBy?->id,
                'name' => $scan->scannedBy?->name,
                'employee_code' => $scan->scannedBy?->employee_code,
            ],
        ];
    }
}