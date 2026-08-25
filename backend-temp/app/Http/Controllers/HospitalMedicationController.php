<?php

namespace App\Http\Controllers;

use App\Models\HospitalMedication;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class HospitalMedicationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $hospitalId = $this->hospitalId($request);

if (!$hospitalId) {
    return response()->json([
        'message' => 'حساب المستخدم غير مرتبط بمستشفى.',
    ], 422);
}

        $search = trim((string) $request->query('search', ''));

        $medications = HospitalMedication::query()
            ->where('hospital_id', $hospitalId)
            ->where('is_active', true)
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($subQuery) use ($search) {
                    $subQuery
                        ->where('name', 'like', "%{$search}%")
                        ->orWhere('generic_name', 'like', "%{$search}%");
                });
            })
            ->orderBy('name')
            ->limit(50)
            ->get([
                'id',
                'name',
                'generic_name',
                'recommended_doses',
            ]);

        return response()->json([
            'data' => $medications,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $hospitalId = $this->hospitalId($request);

        if (!$hospitalId) {
            return response()->json([
                'message' => 'حساب المستخدم غير مرتبط بمستشفى.',
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:150'],
            'generic_name' => ['nullable', 'string', 'max:150'],
            'recommended_doses' => ['required', 'array', 'min:1', 'max:20'],
            'recommended_doses.*' => ['required', 'string', 'max:255'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'بيانات الدواء غير صحيحة.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $medication = HospitalMedication::create([
            'hospital_id' => $hospitalId,
            'created_by' => $user->id,
            'name' => trim($validator->validated()['name']),
            'generic_name' => filled($validator->validated()['generic_name'] ?? null)
                ? trim($validator->validated()['generic_name'])
                : null,
            'recommended_doses' => array_values(
                array_unique(
                    array_map(
                        static fn (string $dose): string => trim($dose),
                        $validator->validated()['recommended_doses']
                    )
                )
            ),
            'is_active' => true,
        ]);

        return response()->json([
            'message' => 'تمت إضافة الدواء إلى قائمة المستشفى.',
            'data' => $medication,
        ], 201);
    }

    public function update(
        Request $request,
        HospitalMedication $medication
    ): JsonResponse {
        $user = $request->user();

        $hospitalId = $this->hospitalId($request);

        if ($medication->hospital_id !== $hospitalId) {
            return response()->json([
                'message' => 'لا تملك صلاحية تعديل هذا الدواء.',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => ['sometimes', 'required', 'string', 'max:150'],
            'generic_name' => ['nullable', 'string', 'max:150'],
            'recommended_doses' => ['sometimes', 'required', 'array', 'min:1', 'max:20'],
            'recommended_doses.*' => ['required', 'string', 'max:255'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'بيانات الدواء غير صحيحة.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        if (array_key_exists('name', $data)) {
            $data['name'] = trim($data['name']);
        }

        if (array_key_exists('generic_name', $data)) {
            $data['generic_name'] = filled($data['generic_name'])
                ? trim($data['generic_name'])
                : null;
        }

        if (array_key_exists('recommended_doses', $data)) {
            $data['recommended_doses'] = array_values(
                array_unique(
                    array_map(
                        static fn (string $dose): string => trim($dose),
                        $data['recommended_doses']
                    )
                )
            );
        }

        $medication->update($data);

        return response()->json([
            'message' => 'تم تحديث الدواء.',
            'data' => $medication->fresh(),
        ]);
    }

    public function destroy(
        Request $request,
        HospitalMedication $medication
    ): JsonResponse {
        $user = $request->user();

        $hospitalId = $this->hospitalId($request);

        if ($medication->hospital_id !== $hospitalId) {
            return response()->json([
                'message' => 'لا تملك صلاحية حذف هذا الدواء.',
            ], 403);
        }

        if ($medication->patientMedications()->exists()) {
            $medication->update(['is_active' => false]);

            return response()->json([
                'message' => 'الدواء مستخدم لدى مرضى، لذلك تم تعطيله بدل حذفه.',
            ]);
        }

        $medication->delete();

        return response()->json([
            'message' => 'تم حذف الدواء من قائمة المستشفى.',
        ]);
    }
    private function hospitalId(Request $request): ?string
{
    return $request->user()
        ?->hospitals()
        ->wherePivot('is_active', true)
        ->value('hospitals.id');
}
}