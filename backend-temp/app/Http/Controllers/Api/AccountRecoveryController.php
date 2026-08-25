<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Domain\Models\AccountRecoveryRequest;
use App\Domain\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password as PasswordRule;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AccountRecoveryController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'national_id' => ['required', 'string', 'max:50'],
            'full_name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'note' => ['nullable', 'string', 'max:1000'],
            'identity_document' => [
                'required',
                'file',
                'mimes:jpg,jpeg,png,webp,pdf',
                'max:5120',
            ],
        ]);

        $nationalId = trim($validated['national_id']);

        $hasPendingRequest = AccountRecoveryRequest::query()
            ->where('national_id', $nationalId)
            ->where('status', 'pending')
            ->exists();

        if ($hasPendingRequest) {
            return response()->json([
                'message' => 'يوجد طلب استعادة قيد المراجعة لهذه البيانات بالفعل.',
            ], 422);
        }

        $file = $validated['identity_document'];

        $storagePath = $file->store(
            'account-recovery/' . now()->format('Y/m'),
            'private',
        );

        if ($storagePath === false) {
            return response()->json([
                'message' => 'تعذر رفع صورة بطاقة الهوية. يرجى المحاولة لاحقًا.',
            ], 503);
        }

        $user = User::query()
            ->where('national_id', $nationalId)
            ->first();

        AccountRecoveryRequest::query()->create([
            'user_id' => $user?->id,
            'national_id' => $nationalId,
            'full_name' => trim($validated['full_name']),
            'phone' => filled($validated['phone'] ?? null)
                ? trim($validated['phone'])
                : null,
            'note' => filled($validated['note'] ?? null)
                ? trim($validated['note'])
                : null,
            'identity_document_path' => $storagePath,
            'identity_document_name' => $file->getClientOriginalName(),
            'identity_document_mime' => $file->getMimeType()
                ?: 'application/octet-stream',
            'identity_document_size' => $file->getSize(),
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'تم استلام طلبك وسيتم مراجعته من فريق الإدارة.',
        ], 201);
    }

    public function complete(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => ['required', 'string', 'size:64'],
            'email' => ['nullable', 'email', 'max:255'],
            'password' => [
                'required',
                'confirmed',
                PasswordRule::min(8)->letters()->numbers(),
            ],
        ]);

        $tokenHash = hash('sha256', $validated['token']);

        $recovery = AccountRecoveryRequest::query()
            ->where('completion_token_hash', $tokenHash)
            ->where('status', 'approved')
            ->whereNull('completion_token_used_at')
            ->where('completion_token_expires_at', '>', now())
            ->with('user')
            ->first();

        if ($recovery === null || $recovery->user === null) {
            return response()->json([
                'message' => 'رابط استعادة الحساب غير صالح أو انتهت صلاحيته.',
            ], 422);
        }

        $user = $recovery->user;
        $email = null;

        /*
         * البريد لا يتغير إذا كان الحساب لديه بريد مسجل.
         * أما الحساب بلا بريد، فيجب أن يضيف المستخدم بريدًا جديدًا.
         */
        if (blank($user->email)) {
            if (blank($validated['email'] ?? null)) {
                return response()->json([
                    'message' => 'يرجى إدخال بريد إلكتروني لإكمال تأمين الحساب.',
                ], 422);
            }

            $email = strtolower(trim($validated['email']));

            $emailInUse = User::query()
                ->where('email', $email)
                ->whereKeyNot($user->id)
                ->exists();

            if ($emailInUse) {
                return response()->json([
                    'message' => 'هذا البريد الإلكتروني مستخدم في حساب آخر.',
                ], 422);
            }
        }

        DB::transaction(function () use (
            $recovery,
            $user,
            $email,
            $validated,
        ): void {
            $updates = [
                'password' => Hash::make($validated['password']),
                'is_active' => true,
            ];

            if ($email !== null) {
                $updates['email'] = $email;
            }

            $user->forceFill($updates)->save();

            // إنهاء كل جلسات/API tokens القديمة بعد تغيير كلمة المرور.
            $user->tokens()->delete();

            $recovery->forceFill([
                'completion_token_used_at' => now(),
                'completion_token_hash' => null,
                'completion_token_expires_at' => null,
            ])->save();
        });

        return response()->json([
            'message' => 'تم تأمين حسابك وتعيين كلمة مرور جديدة بنجاح.',
        ]);
    }

    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['nullable', Rule::in(['pending', 'approved', 'rejected'])],
            'page' => ['nullable', 'integer', 'min:1'],
        ]);

        $requests = AccountRecoveryRequest::query()
            ->with([
                'user:id,name,email,phone,national_id',
                'reviewer:id,name,email',
            ])
            ->when(
                $validated['status'] ?? null,
                fn ($query, string $status) => $query->where('status', $status),
            )
            ->latest()
            ->paginate(20);

        return response()->json([
            'data' => $requests->through(
                fn (AccountRecoveryRequest $item) => [
                    'id' => $item->id,
                    'national_id' => $item->national_id,
                    'full_name' => $item->full_name,
                    'phone' => $item->phone,
                    'note' => $item->note,
                    'status' => $item->status,
                    'admin_note' => $item->admin_note,
                    'identity_document_name' => $item->identity_document_name,
                    'identity_document_mime' => $item->identity_document_mime,
                    'identity_document_size' => $item->identity_document_size,
                    'created_at' => $item->created_at?->toIso8601String(),
                    'reviewed_at' => $item->reviewed_at?->toIso8601String(),
                    'user' => $item->user ? [
                        'id' => $item->user->id,
                        'name' => $item->user->name,
                        'email' => $item->user->email,
                        'phone' => $item->user->phone,
                        'national_id' => $item->user->national_id,
                    ] : null,
                    'reviewer' => $item->reviewer ? [
                        'id' => $item->reviewer->id,
                        'name' => $item->reviewer->name,
                        'email' => $item->reviewer->email,
                    ] : null,
                ],
            ),
            'meta' => [
                'current_page' => $requests->currentPage(),
                'last_page' => $requests->lastPage(),
                'per_page' => $requests->perPage(),
                'total' => $requests->total(),
            ],
        ]);
    }

    public function showIdentityDocument(
        Request $request,
        AccountRecoveryRequest $accountRecoveryRequest,
    ): StreamedResponse {
        $disk = Storage::disk('private');
        $path = $accountRecoveryRequest->identity_document_path;

        abort_unless(
            $disk->exists($path),
            404,
            'صورة الهوية غير متاحة.',
        );

        return $disk->response(
            $path,
            $accountRecoveryRequest->identity_document_name,
            [
                'Content-Type' => $accountRecoveryRequest->identity_document_mime,
                'Content-Disposition' => sprintf(
                    'inline; filename="%s"',
                    addslashes($accountRecoveryRequest->identity_document_name),
                ),
                'Cache-Control' => 'private, no-store, max-age=0',
                'X-Content-Type-Options' => 'nosniff',
            ],
        );
    }

    public function review(
        Request $request,
        AccountRecoveryRequest $accountRecoveryRequest,
    ): JsonResponse {
        $validated = $request->validate([
            'action' => ['required', Rule::in(['approve', 'reject'])],
            'admin_note' => ['nullable', 'string', 'max:1000'],
        ]);

        $accountRecoveryRequest->loadMissing('user');

        if ($accountRecoveryRequest->status !== 'pending') {
            return response()->json([
                'message' => 'تمت مراجعة هذا الطلب مسبقًا.',
            ], 422);
        }

        if (
            $validated['action'] === 'approve'
            && $accountRecoveryRequest->user === null
        ) {
            return response()->json([
                'message' => 'لا يوجد حساب مرتبط برقم الهوية في هذا الطلب، لذلك لا يمكن قبوله.',
            ], 422);
        }

        if (
            $validated['action'] === 'approve'
            && $accountRecoveryRequest->user->national_id
                !== $accountRecoveryRequest->national_id
        ) {
            return response()->json([
                'message' => 'رقم الهوية في الطلب لا يطابق رقم الهوية في الحساب المرتبط.',
            ], 422);
        }

        $status = $validated['action'] === 'approve'
            ? 'approved'
            : 'rejected';

        $plainToken = null;

        $updates = [
            'status' => $status,
            'admin_note' => filled($validated['admin_note'] ?? null)
                ? trim($validated['admin_note'])
                : null,
            'reviewed_by' => $request->user()->id,
            'reviewed_at' => now(),
            'completion_token_hash' => null,
            'completion_token_expires_at' => null,
            'completion_token_used_at' => null,
        ];

        if ($status === 'approved') {
            $plainToken = Str::random(64);

            $updates['completion_token_hash'] = hash('sha256', $plainToken);
            $updates['completion_token_expires_at'] = now()->addHours(24);
        }

        $accountRecoveryRequest->update($updates);

        return response()->json([
            'message' => $status === 'approved'
                ? 'تم قبول الطلب. امنح المستخدم رابط إكمال الاستعادة بشكل آمن.'
                : 'تم رفض طلب استعادة الحساب.',
            'recovery_url' => $plainToken
                ? rtrim((string) config('app.frontend_url'), '/')
                    . '/account-recovery/complete?token='
                    . urlencode($plainToken)
                : null,
        ]);
    }
}