<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Domain\Enums\FileType;
use App\Domain\Models\HospitalPatientQrScan;
use App\Domain\Models\MedicalFile;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Resources\MedicalFileResource;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class HospitalMedicalFileController extends Controller
{
    public function index(Request $request, string $patient): JsonResponse
    {
        $hospitalId = $this->hospitalId($request);

        $this->ensureDoctorCanAccessPatient(
            $request,
            $hospitalId,
            $patient,
        );

        $files = MedicalFile::query()
            ->with('uploader:id,name')
            ->where('user_id', $patient)
            ->where(function (Builder $query) use ($hospitalId): void {
                $query->whereNull('hospital_id')
                    ->orWhere('hospital_id', $hospitalId);
            })
            ->latest('created_at')
            ->get();

        return response()->json([
            'data' => MedicalFileResource::collection($files),
        ]);
    }

    public function store(Request $request, string $patient): JsonResponse
    {
        $hospitalId = $this->hospitalId($request);

        $this->ensureDoctorCanAccessPatient(
            $request,
            $hospitalId,
            $patient,
        );

        $validated = $request->validate([
            'file' => [
                'required',
                'file',
                'max:10240',
                'mimes:pdf,jpg,jpeg,png,webp',
            ],
            'file_type' => [
                'nullable',
                Rule::enum(FileType::class),
            ],
            'description' => [
                'nullable',
                'string',
                'max:500',
            ],
        ]);

        $uploadedFile = $validated['file'];

        $path = $uploadedFile->store(
            "medical_files/{$hospitalId}/{$patient}",
            'private',
        );

        $medicalFile = MedicalFile::query()->create([
            'user_id' => $patient,
            'hospital_id' => $hospitalId,
            'uploaded_by' => $request->user()->id,
            'original_name' => $uploadedFile->getClientOriginalName(),
            'storage_path' => $path,
            'mime_type' => $uploadedFile->getMimeType(),
            'size_bytes' => $uploadedFile->getSize(),
            'file_type' => $validated['file_type'] ?? FileType::Other->value,
            'description' => $validated['description'] ?? null,
        ]);

        $medicalFile->load('uploader:id,name');

        return response()->json([
            'message' => 'تم رفع الملف الطبي بنجاح.',
            'data' => new MedicalFileResource($medicalFile),
        ], 201);
    }

    public function download(
        Request $request,
        string $patient,
        string $medicalFile,
    ) {
        $hospitalId = $this->hospitalId($request);

        $this->ensureDoctorCanAccessPatient(
            $request,
            $hospitalId,
            $patient,
        );

        $file = MedicalFile::query()
            ->whereKey($medicalFile)
            ->where('user_id', $patient)
            ->where(function (Builder $query) use ($hospitalId): void {
                $query->whereNull('hospital_id')
                    ->orWhere('hospital_id', $hospitalId);
            })
            ->firstOrFail();

        abort_unless(
            Storage::disk('private')->exists($file->storage_path),
            404,
            'الملف غير موجود في التخزين.',
        );

        return Storage::disk('private')->download(
            $file->storage_path,
            $file->original_name,
        );
    }

    public function destroy(
        Request $request,
        string $patient,
        string $medicalFile,
    ): JsonResponse {
        $hospitalId = $this->hospitalId($request);

        $this->ensureDoctorCanAccessPatient(
            $request,
            $hospitalId,
            $patient,
        );

        $file = MedicalFile::query()
            ->whereKey($medicalFile)
            ->where('user_id', $patient)
            ->where('hospital_id', $hospitalId)
            ->firstOrFail();

        abort_unless(
            (string) $file->uploaded_by === (string) $request->user()->id,
            403,
            'يمكنك حذف الملفات التي قمت برفعها فقط.',
        );

        Storage::disk('private')->delete($file->storage_path);

        $file->delete();

        return response()->json([
            'message' => 'تم حذف الملف الطبي بنجاح.',
        ]);
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

    private function ensureDoctorCanAccessPatient(
        Request $request,
        string $hospitalId,
        string $patientId,
    ): void {
        User::query()
            ->whereKey($patientId)
            ->firstOrFail();

        $hasScan = HospitalPatientQrScan::query()
            ->where('hospital_id', $hospitalId)
            ->where('patient_id', $patientId)
            ->where('scanned_by_user_id', $request->user()->id)
            ->exists();

        abort_unless(
            $hasScan,
            403,
            'لا يمكنك الوصول إلى ملفات هذا المريض قبل مسح رمز QR الخاص به.',
        );
    }
}