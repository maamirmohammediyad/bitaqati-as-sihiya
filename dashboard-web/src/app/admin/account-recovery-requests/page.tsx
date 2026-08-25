"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import AdminShell from "@/components/admin/AdminShell";
import { api } from "@/lib/api";
import { getAdminToken } from "@/lib/auth";

type RecoveryStatus = "pending" | "approved" | "rejected";

type RecoveryRequest = {
  id: string;
  national_id: string;
  full_name: string;
  phone: string | null;
  note: string | null;
  status: RecoveryStatus;
  admin_note: string | null;
  identity_document_name: string;
  identity_document_mime: string;
  identity_document_size: number;
  created_at: string | null;
  reviewed_at: string | null;
  user: {
    id: string;
    name: string;
    email: string | null;
    phone: string | null;
    national_id: string | null;
  } | null;
  reviewer: {
    id: string;
    name: string;
    email: string | null;
  } | null;
};

type RecoveryListResponse = {
  data: RecoveryRequest[];
  meta: {
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
  };
};

type ReviewResponse = {
  message: string;
  recovery_url: string | null;
};

const statusOptions: Array<{
  value: "all" | RecoveryStatus;
  label: string;
}> = [
  { value: "all", label: "كل الطلبات" },
  { value: "pending", label: "قيد المراجعة" },
  { value: "approved", label: "مقبولة" },
  { value: "rejected", label: "مرفوضة" },
];

function formatDate(value: string | null) {
  if (!value) {
    return "—";
  }

  return new Intl.DateTimeFormat("ar", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

function formatFileSize(size: number) {
  if (!size) {
    return "—";
  }

  const megabytes = size / (1024 * 1024);

  if (megabytes >= 1) {
    return `${megabytes.toFixed(2)} MB`;
  }

  return `${Math.ceil(size / 1024)} KB`;
}

function statusLabel(status: RecoveryStatus) {
  switch (status) {
    case "pending":
      return "قيد المراجعة";
    case "approved":
      return "مقبول";
    case "rejected":
      return "مرفوض";
  }
}

function statusClasses(status: RecoveryStatus) {
  switch (status) {
    case "pending":
      return "border-amber-200 bg-amber-50 text-amber-800";
    case "approved":
      return "border-emerald-200 bg-emerald-50 text-emerald-800";
    case "rejected":
      return "border-red-200 bg-red-50 text-red-700";
  }
}

export default function AccountRecoveryRequestsPage() {
  const [requests, setRequests] = useState<RecoveryRequest[]>([]);
  const [selectedStatus, setSelectedStatus] = useState<"all" | RecoveryStatus>(
    "pending"
  );
  const [loading, setLoading] = useState(true);
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [selectedRequest, setSelectedRequest] =
    useState<RecoveryRequest | null>(null);
  const [adminNote, setAdminNote] = useState("");
  const [recoveryUrl, setRecoveryUrl] = useState<string | null>(null);

  const pendingCount = useMemo(
    () => requests.filter((request) => request.status === "pending").length,
    [requests]
  );

  const loadRequests = useCallback(async () => {
    const token = getAdminToken();

    if (!token) {
      return;
    }

    setLoading(true);
    setError("");

    try {
      const statusQuery =
        selectedStatus === "all" ? "" : `?status=${selectedStatus}`;

      const response = await api<RecoveryListResponse>(
        `/admin/account-recovery-requests${statusQuery}`,
        { token }
      );

      const payload = response.data as unknown;

const list = Array.isArray(payload)
  ? payload
  : Array.isArray((payload as { data?: unknown })?.data)
    ? ((payload as { data: RecoveryRequest[] }).data)
    : [];

setRequests(list);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تحميل طلبات استعادة الحساب."
      );
    } finally {
      setLoading(false);
    }
  }, [selectedStatus]);

  useEffect(() => {
    loadRequests();
  }, [loadRequests]);

  function openReviewModal(request: RecoveryRequest) {
    setSelectedRequest(request);
    setAdminNote(request.admin_note ?? "");
    setRecoveryUrl(null);
    setSuccess("");
    setError("");
  }

  function closeReviewModal() {
    if (actionLoadingId) {
      return;
    }

    setSelectedRequest(null);
    setAdminNote("");
    setRecoveryUrl(null);
  }

  async function reviewRequest(action: "approve" | "reject") {
    if (!selectedRequest) {
      return;
    }

    const token = getAdminToken();

    if (!token) {
      setError("انتهت جلسة الدخول. سجّل الدخول مرة أخرى.");
      return;
    }

    const confirmationText =
      action === "approve"
        ? "هل أنت متأكد من قبول طلب الاستعادة؟ سيتم إنشاء رابط مؤقت لتعيين كلمة مرور جديدة."
        : "هل أنت متأكد من رفض طلب الاستعادة؟";

    if (!window.confirm(confirmationText)) {
      return;
    }

    setActionLoadingId(selectedRequest.id);
    setError("");
    setSuccess("");

    try {
      const response = await api<ReviewResponse>(
        `/admin/account-recovery-requests/${selectedRequest.id}/review`,
        {
          method: "PATCH",
          token,
          body: JSON.stringify({
            action,
            admin_note: adminNote.trim() || null,
          }),
        }
      );

      setSuccess(response.message);
      setRecoveryUrl(response.recovery_url);

      await loadRequests();

      if (action === "reject") {
        closeReviewModal();
      }
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تنفيذ مراجعة طلب الاستعادة."
      );
    } finally {
      setActionLoadingId(null);
    }
  }

  async function openIdentityDocument(request: RecoveryRequest) {
    const token = getAdminToken();

    if (!token) {
      setError("انتهت جلسة الدخول. سجّل الدخول مرة أخرى.");
      return;
    }

    setActionLoadingId(request.id);
    setError("");

    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL;

      if (!apiUrl) {
        throw new Error("NEXT_PUBLIC_API_URL غير موجود في ملف .env.local");
      }

      const response = await fetch(
        `${apiUrl}/admin/account-recovery-requests/${request.id}/identity-document`,
        {
          headers: {
            Accept: request.identity_document_mime,
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!response.ok) {
        const data = await response.json().catch(() => null);

        throw new Error(
          data?.message ?? "تعذر فتح وثيقة إثبات الهوية."
        );
      }

      const fileBlob = await response.blob();
      const objectUrl = URL.createObjectURL(fileBlob);

      window.open(objectUrl, "_blank", "noopener,noreferrer");

      window.setTimeout(() => URL.revokeObjectURL(objectUrl), 60_000);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر فتح وثيقة إثبات الهوية."
      );
    } finally {
      setActionLoadingId(null);
    }
  }

  async function copyRecoveryUrl() {
    if (!recoveryUrl) {
      return;
    }

    try {
      await navigator.clipboard.writeText(recoveryUrl);
      setSuccess("تم نسخ رابط إكمال الاستعادة. أرسله للمستخدم عبر قناة آمنة.");
    } catch {
      setError("تعذر نسخ الرابط تلقائيًا. انسخه يدويًا.");
    }
  }

  return (
    <AdminShell
      title="طلبات استعادة الحساب"
      description="راجع وثائق الهوية، ثم اقبل الطلب أو ارفضه حسب التحقق من بيانات صاحب الحساب."
    >
      {error && (
        <div
          role="alert"
          className="mb-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm leading-6 text-red-700"
        >
          {error}
        </div>
      )}

      {success && (
        <div
          role="status"
          className="mb-6 rounded-2xl border border-emerald-200 bg-emerald-50 px-5 py-4 text-sm leading-6 text-emerald-800"
        >
          {success}
        </div>
      )}

      <section className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
        <div className="flex flex-col justify-between gap-4 lg:flex-row lg:items-center">
          <div>
            <h3 className="text-base font-bold text-slate-900">
              قائمة الطلبات
            </h3>
            <p className="mt-1 text-sm text-slate-500">
              الطلبات المعروضة: {loading ? "..." : requests.length}
              {selectedStatus === "pending" && !loading
                ? `، قيد المراجعة: ${pendingCount}`
                : ""}
            </p>
          </div>

          <div className="flex flex-wrap gap-2">
            {statusOptions.map((option) => (
              <button
                key={option.value}
                type="button"
                onClick={() => setSelectedStatus(option.value)}
                className={`rounded-xl px-4 py-2 text-sm font-bold transition ${
                  selectedStatus === option.value
                    ? "bg-cyan-600 text-white"
                    : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                }`}
              >
                {option.label}
              </button>
            ))}

            <button
              type="button"
              onClick={loadRequests}
              disabled={loading}
              className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
            >
              تحديث
            </button>
          </div>
        </div>

        <div className="mt-6 overflow-x-auto">
          <table className="min-w-[980px] w-full border-separate border-spacing-0 text-right">
            <thead>
              <tr className="bg-slate-50 text-xs text-slate-500">
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  مقدم الطلب
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  رقم الهوية
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  وثيقة الهوية
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  تاريخ الإرسال
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  الحالة
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  الإجراء
                </th>
              </tr>
            </thead>

            <tbody>
              {loading ? (
                <tr>
                  <td
                    colSpan={6}
                    className="border-b border-slate-100 px-4 py-10 text-center text-sm text-slate-500"
                  >
                    جارٍ تحميل طلبات الاستعادة...
                  </td>
                </tr>
              ) : requests.length === 0 ? (
                <tr>
                  <td
                    colSpan={6}
                    className="border-b border-slate-100 px-4 py-10 text-center text-sm text-slate-500"
                  >
                    لا توجد طلبات ضمن الفلتر المحدد.
                  </td>
                </tr>
              ) : (
                requests.map((request) => (
                  <tr
                    key={request.id}
                    className="text-sm text-slate-700 transition hover:bg-slate-50"
                  >
                    <td className="border-b border-slate-100 px-4 py-4">
                      <p className="font-bold text-slate-900">
                        {request.full_name}
                      </p>
                      <p className="mt-1 text-xs text-slate-500">
                        {request.phone || "لا يوجد رقم هاتف"}
                      </p>
                      {request.user && (
                        <p className="mt-1 text-xs text-cyan-700">
                          حساب مرتبط: {request.user.email || request.user.name}
                        </p>
                      )}
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4 font-mono text-xs">
                      {request.national_id}
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4">
                      <p className="max-w-44 truncate font-semibold text-slate-800">
                        {request.identity_document_name}
                      </p>
                      <p className="mt-1 text-xs text-slate-500">
                        {formatFileSize(request.identity_document_size)}
                      </p>
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4 text-xs text-slate-600">
                      {formatDate(request.created_at)}
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4">
                      <span
                        className={`inline-flex rounded-full border px-3 py-1 text-xs font-bold ${statusClasses(
                          request.status
                        )}`}
                      >
                        {statusLabel(request.status)}
                      </span>
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4">
                      <div className="flex gap-2">
                        <button
                          type="button"
                          onClick={() => openIdentityDocument(request)}
                          disabled={actionLoadingId === request.id}
                          className="rounded-lg border border-cyan-200 px-3 py-2 text-xs font-bold text-cyan-700 transition hover:bg-cyan-50 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                          الوثيقة
                        </button>

                        <button
                          type="button"
                          onClick={() => openReviewModal(request)}
                          className="rounded-lg bg-slate-900 px-3 py-2 text-xs font-bold text-white transition hover:bg-slate-700"
                        >
                          التفاصيل
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {selectedRequest && (
        <div
          className="fixed inset-0 z-50 overflow-y-auto bg-slate-950/55 p-4 sm:p-8"
          onMouseDown={closeReviewModal}
        >
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="recovery-request-title"
            className="mx-auto my-6 w-full max-w-2xl rounded-3xl bg-white p-6 shadow-2xl sm:p-8"
            onMouseDown={(event) => event.stopPropagation()}
          >
            <div className="flex items-start justify-between gap-5">
              <div>
                <h3
                  id="recovery-request-title"
                  className="text-xl font-bold text-slate-900"
                >
                  مراجعة طلب الاستعادة
                </h3>
                <p className="mt-2 text-sm leading-6 text-slate-500">
                  تحقق من بيانات مقدم الطلب ووثيقة الهوية قبل اتخاذ القرار.
                </p>
              </div>

              <button
                type="button"
                onClick={closeReviewModal}
                disabled={actionLoadingId === selectedRequest.id}
                className="rounded-xl bg-slate-100 px-3 py-2 text-sm font-bold text-slate-700 hover:bg-slate-200 disabled:opacity-60"
              >
                إغلاق
              </button>
            </div>

            <div className="mt-7 grid gap-4 rounded-2xl bg-slate-50 p-5 sm:grid-cols-2">
              <DetailItem label="الاسم الكامل" value={selectedRequest.full_name} />
              <DetailItem
                label="رقم الهوية"
                value={selectedRequest.national_id}
                mono
              />
              <DetailItem
                label="رقم الهاتف"
                value={selectedRequest.phone || "غير مضاف"}
              />
              <DetailItem
                label="تاريخ الإرسال"
                value={formatDate(selectedRequest.created_at)}
              />
              <DetailItem
                label="اسم الوثيقة"
                value={selectedRequest.identity_document_name}
              />
              <DetailItem
                label="حجم الوثيقة"
                value={formatFileSize(selectedRequest.identity_document_size)}
              />
            </div>

            <div className="mt-5 rounded-2xl border border-slate-200 p-5">
              <p className="text-sm font-bold text-slate-800">ملاحظات المستخدم</p>
              <p className="mt-2 whitespace-pre-wrap text-sm leading-7 text-slate-600">
                {selectedRequest.note || "لا توجد ملاحظات."}
              </p>
            </div>

            {selectedRequest.user ? (
              <div className="mt-5 rounded-2xl border border-cyan-100 bg-cyan-50 p-5">
                <p className="text-sm font-bold text-cyan-900">
                  الحساب المرتبط
                </p>
                <p className="mt-2 text-sm text-cyan-800">
                  {selectedRequest.user.name}
                  {selectedRequest.user.email
                    ? ` — ${selectedRequest.user.email}`
                    : ""}
                </p>
              </div>
            ) : (
              <div className="mt-5 rounded-2xl border border-amber-200 bg-amber-50 p-5 text-sm leading-6 text-amber-800">
                لا يوجد حساب مرتبط برقم الهوية هذا؛ لا يمكن قبول الطلب قبل
                التحقق من وجود الحساب.
              </div>
            )}

            {selectedRequest.status === "pending" ? (
              <>
                <div className="mt-5">
                  <label
                    htmlFor="adminNote"
                    className="mb-2 block text-sm font-bold text-slate-800"
                  >
                    ملاحظة المدير — اختيارية
                  </label>
                  <textarea
                    id="adminNote"
                    value={adminNote}
                    onChange={(event) => setAdminNote(event.target.value)}
                    rows={4}
                    maxLength={1000}
                    placeholder="اكتب ملاحظة داخلية عن قرار المراجعة..."
                    disabled={actionLoadingId === selectedRequest.id}
                    className="w-full resize-y rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:bg-slate-100"
                  />
                </div>

                <button
                  type="button"
                  onClick={() => openIdentityDocument(selectedRequest)}
                  disabled={actionLoadingId === selectedRequest.id}
                  className="mt-5 w-full rounded-xl border border-cyan-200 bg-cyan-50 px-4 py-3 text-sm font-bold text-cyan-800 transition hover:bg-cyan-100 disabled:cursor-not-allowed disabled:opacity-60"
                >
                  فتح وثيقة إثبات الهوية
                </button>

                <div className="mt-5 grid gap-3 sm:grid-cols-2">
                  <button
                    type="button"
                    onClick={() => reviewRequest("reject")}
                    disabled={actionLoadingId === selectedRequest.id}
                    className="rounded-xl border border-red-200 bg-red-50 px-4 py-3.5 text-sm font-bold text-red-700 transition hover:bg-red-100 disabled:cursor-not-allowed disabled:opacity-60"
                  >
                    {actionLoadingId === selectedRequest.id
                      ? "جارٍ الحفظ..."
                      : "رفض الطلب"}
                  </button>

                  <button
                    type="button"
                    onClick={() => reviewRequest("approve")}
                    disabled={
                      actionLoadingId === selectedRequest.id ||
                      selectedRequest.user === null
                    }
                    className="rounded-xl bg-emerald-600 px-4 py-3.5 text-sm font-bold text-white transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:bg-emerald-300"
                  >
                    {actionLoadingId === selectedRequest.id
                      ? "جارٍ الحفظ..."
                      : "قبول وإنشاء الرابط"}
                  </button>
                </div>
              </>
            ) : (
              <div className="mt-5 rounded-2xl border border-slate-200 bg-slate-50 p-5">
                <p className="text-sm font-bold text-slate-800">
                  تمت مراجعة الطلب
                </p>
                <p className="mt-2 text-sm text-slate-600">
                  الحالة: {statusLabel(selectedRequest.status)}
                </p>
                <p className="mt-1 text-sm text-slate-600">
                  وقت المراجعة: {formatDate(selectedRequest.reviewed_at)}
                </p>
                <p className="mt-1 text-sm text-slate-600">
                  المراجع: {selectedRequest.reviewer?.name || "—"}
                </p>
                {selectedRequest.admin_note && (
                  <p className="mt-3 whitespace-pre-wrap text-sm leading-6 text-slate-600">
                    ملاحظة المدير: {selectedRequest.admin_note}
                  </p>
                )}
              </div>
            )}

            {recoveryUrl && (
              <div className="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50 p-5">
                <p className="text-sm font-bold text-emerald-900">
                  رابط إكمال الاستعادة
                </p>
                <p className="mt-2 text-xs leading-6 text-emerald-800">
                  انسخ الرابط وأرسله للمستخدم عبر وسيلة آمنة. الرابط صالح لمدة
                  24 ساعة ويجب عدم مشاركته علنًا.
                </p>

                <div className="mt-4 flex flex-col gap-3 sm:flex-row">
                  <input
                    value={recoveryUrl}
                    readOnly
                    dir="ltr"
                    className="min-w-0 flex-1 rounded-xl border border-emerald-200 bg-white px-3 py-3 text-left text-xs text-slate-700 outline-none"
                  />

                  <button
                    type="button"
                    onClick={copyRecoveryUrl}
                    className="rounded-xl bg-emerald-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-emerald-800"
                  >
                    نسخ الرابط
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </AdminShell>
  );
}

function DetailItem({
  label,
  value,
  mono = false,
}: {
  label: string;
  value: string;
  mono?: boolean;
}) {
  return (
    <div>
      <p className="text-xs font-bold text-slate-500">{label}</p>
      <p
        className={`mt-1 break-words text-sm font-semibold text-slate-800 ${
          mono ? "font-mono" : ""
        }`}
      >
        {value}
      </p>
    </div>
  );
}