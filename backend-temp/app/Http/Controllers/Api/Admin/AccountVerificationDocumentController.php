<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;
use App\Domain\Models\AccountVerificationDocument;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AccountVerificationDocumentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['nullable', Rule::in(['pending', 'approved', 'rejected'])],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);

        $documents = AccountVerificationDocument::query()
            ->with([
    'user:id,name,phone,email,national_id,patient_code,is_active',
])
            ->when(
                $validated['status'] ?? null,
                fn ($query, string $status) => $query->where('status', $status),
            )
            ->latest('submitted_at')
            ->paginate($validated['per_page'] ?? 20);

        return response()->json($documents);
    }

    public function show(AccountVerificationDocument $document): JsonResponse
    {
        $document->load([
    'user:id,name,phone,email,national_id,patient_code',
    'reviewer:id,name',
]);

        return response()->json([
            'data' => $this->documentData($document),
        ]);
    }

    
public function review(
    Request $request,
    AccountVerificationDocument $document,
): JsonResponse {
    $validated = $request->validate([
        'status' => ['required', Rule::in(['approved', 'rejected'])],
        'rejection_reason' => [
            'nullable',
            'string',
            'max:1000',
            'required_if:status,rejected',
        ],
    ]);

    $document = DB::transaction(function () use (
        $request,
        $document,
        $validated,
    ): AccountVerificationDocument {
        $isRejected = $validated['status'] === 'rejected';

        $document->update([
            'status' => $validated['status'],
            'rejection_reason' => $isRejected
                ? trim((string) $validated['rejection_reason'])
                : null,
            'reviewed_by' => $request->user()->id,
            'reviewed_at' => now(),
        ]);

        $document->user()->update([
            'is_active' => ! $isRejected,
        ]);

        return $document->fresh([
            'user:id,name,phone,email,national_id,patient_code,is_active',
            'reviewer:id,name',
        ]);
    });

    return response()->json([
        'message' => $document->status === 'rejected'
            ? 'تم رفض وثيقة التحقق.'
            : 'تمت الموافقة على وثيقة التحقق وتفعيل الحساب.',
        'data' => $this->documentData($document),
    ]);
}

    private function documentData(
        AccountVerificationDocument $document,
    ): array {
        return [
            'id' => $document->id,
            'original_name' => $document->original_name,
            'mime_type' => $document->mime_type,
            'size_bytes' => $document->size_bytes,
            'submitted_at' => $document->submitted_at?->toISOString(),
            'status' => $document->status,
            'rejection_reason' => $document->rejection_reason,
            'reviewed_at' => $document->reviewed_at?->toISOString(),
            'user' => $document->user === null ? null : [
                'id' => $document->user->id,
                'name' => $document->user->name,
                'phone' => $document->user->phone,
                'email' => $document->user->email,
                'national_id' => $document->user->national_id,
                'patient_code' => $document->user->patient_code,
                'is_active' => $document->user->is_active,
            ],
            'reviewer' => $document->reviewer === null ? null : [
                'id' => $document->reviewer->id,
                'name' => $document->reviewer->name,
            ],
        ];
    }

    public function showDocument(
    AccountVerificationDocument $document,
): StreamedResponse {
    $disk = Storage::disk('private');

    abort_unless(
        $disk->exists($document->storage_path),
        404,
        'ملف وثيقة التحقق غير موجود.'
    );

    return $disk->response(
        $document->storage_path,
        $document->original_name,
        [
            'Content-Type' => $document->mime_type,
            'Content-Disposition' => sprintf(
                'inline; filename="%s"',
                addslashes($document->original_name),
            ),
            'Cache-Control' => 'private, no-store, max-age=0',
            'X-Content-Type-Options' => 'nosniff',
        ],
    );
}
}