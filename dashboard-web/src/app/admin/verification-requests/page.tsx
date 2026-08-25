"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import AdminShell from "@/components/admin/AdminShell";
import { api } from "@/lib/api";
import { getAdminToken } from "@/lib/auth";

type VerificationStatus = "pending" | "approved" | "rejected";

type VerificationUser = {
  id: string;
  name: string;
  phone: string | null;
  email: string | null;
  national_id: string | null;
  patient_code: string | null;
  role: string;
  is_active: boolean;
};

type Reviewer = {
  id: string;
  name: string;
};

type VerificationDocument = {
  id: string;
  original_name: string;
  mime_type: string;
  size_bytes: number;
  submitted_at: string | null;
  status: VerificationStatus;
  rejection_reason: string | null;
  reviewed_at: string | null;
  user: VerificationUser | null;
  reviewer?: Reviewer | null;
};

type DocumentListResponse = {
  data: VerificationDocument[];
  meta?: {
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
  };
};

type ReviewResponse = {
  message: string;
  data: VerificationDocument;
};

const statusOptions: Array<{
  value: "all" | VerificationStatus;
  label: string;
}> = [
  { value: "all", label: "كل الطلبات" },
  { value: "pending", label: "قيد المراجعة" },
  { value: "approved", label: "مقبولة" },
  { value: "rejected", label: "مرفوضة" },
];

function formatDate(value: string | null) {
  if (!value) return "—";

  return new Intl.DateTimeFormat("ar", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

function formatFileSize(size: number) {
  if (!size) return "—";

  const megabytes = size / (1024 * 1024);

  if (megabytes >= 1) {
    return `${megabytes.toFixed(2)} MB`;
  }

  return `${Math.ceil(size / 1024)} KB`;
}

function statusLabel(status: VerificationStatus) {
  switch (status) {
    case "pending":
      return "قيد المراجعة";
    case "approved":
      return "مقبول";
    case "rejected":
      return "مرفوض";
  }
}

function statusClasses(status: VerificationStatus) {
  switch (status) {
    case "pending":
      return "border-amber-200 bg-amber-50 text-amber-800";
    case "approved":
      return "border-emerald-200 bg-emerald-50 text-emerald-800";
    case "rejected":
      return "border-red-200 bg-red-50 text-red-700";
  }
}

function roleLabel(role: string | undefined) {
  if (role === "patient") return "مريض";
  if (role === "guardian") return "ولي أمر";
  return role || "—";
}

export default function VerificationRequestsPage() {
  const [documents, setDocuments] = useState<VerificationDocument[]>([]);
  const [selectedStatus, setSelectedStatus] = useState<
    "all" | VerificationStatus
  >("pending");
  const [loading, setLoading] = useState(true);
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);
  const [selectedDocument, setSelectedDocument] =
    useState<VerificationDocument | null>(null);
  const [rejectionReason, setRejectionReason] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const pendingCount = useMemo(
    () => documents.filter((document) => document.status === "pending").length,
    [documents]
  );

  const loadDocuments = useCallback(async () => {
    const token = getAdminToken();

    if (!token) return;

    setLoading(true);
    setError("");

    try {
      const query =
        selectedStatus === "all"
          ? "?per_page=100"
          : `?status=${selectedStatus}&per_page=100`;

      const response = await api<DocumentListResponse>(
        `/admin/account-verification-documents${query}`,
        { token }
      );

      setDocuments(Array.isArray(response.data) ? response.data : []);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تحميل طلبات توثيق الحساب."
      );
    } finally {
      setLoading(false);
    }
  }, [selectedStatus]);

  useEffect(() => {
    loadDocuments();
  }, [loadDocuments]);

  function openReviewModal(document: VerificationDocument) {
    setSelectedDocument(document);
    setRejectionReason(document.rejection_reason ?? "");
    setError("");
    setSuccess("");
  }

  function closeReviewModal() {
    if (actionLoadingId) return;

    setSelectedDocument(null);
    setRejectionReason("");
  }

  async function openDocumentFile(document: VerificationDocument) {
    const token = getAdminToken();

    if (!token) {
      setError("انتهت جلسة الدخول. سجّل الدخول مرة أخرى.");
      return;
    }

    const apiUrl = process.env.NEXT_PUBLIC_API_URL;

    if (!apiUrl) {
      setError("NEXT_PUBLIC_API_URL غير موجود في ملف .env.local");
      return;
    }

    setActionLoadingId(document.id);
    setError("");

    try {
      const response = await fetch(
        `${apiUrl}/admin/account-verification-documents/${document.id}/document`,
        {
          headers: {
            Accept: document.mime_type || "application/octet-stream",
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!response.ok) {
        const data = await response.json().catch(() => null);

        throw new Error(data?.message ?? "تعذر فتح وثيقة التحقق.");
      }

      const blob = await response.blob();
      const objectUrl = URL.createObjectURL(blob);

      window.open(objectUrl, "_blank", "noopener,noreferrer");

      window.setTimeout(() => URL.revokeObjectURL(objectUrl), 60_000);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "تعذر فتح وثيقة التحقق."
      );
    } finally {
      setActionLoadingId(null);
    }
  }

  async function reviewDocument(status: "approved" | "rejected") {
    if (!selectedDocument) return;

    const token = getAdminToken();

    if (!token) {
      setError("انتهت جلسة الدخول. سجّل الدخول مرة أخرى.");
      return;
    }

    const reason = rejectionReason.trim();

    if (status === "rejected" && !reason) {
      setError("سبب الرفض مطلوب قبل رفض الوثيقة.");
      return;
    }

    const confirmationText =
      status === "approved"
        ? "هل أنت متأكد من قبول الوثيقة؟ سيتم تفعيل حساب المستخدم."
        : "هل أنت متأكد من رفض الوثيقة؟ سيُطلب من المستخدم رفع ملف جديد.";

    if (!window.confirm(confirmationText)) return;

    setActionLoadingId(selectedDocument.id);
    setError("");
    setSuccess("");

    try {
      const response = await api<ReviewResponse>(
        `/admin/account-verification-documents/${selectedDocument.id}/review`,
        {
          method: "PATCH",
          token,
          body: JSON.stringify({
            status,
            rejection_reason: status === "rejected" ? reason : null,
          }),
        }
      );

      setSuccess(response.message);
      await loadDocuments();
      closeReviewModal();
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تنفيذ مراجعة وثيقة التحقق."
      );
    } finally {
      setActionLoadingId(null);
    }
  }

  return (
    <AdminShell
      title="طلبات توثيق الحسابات"
      description="راجع وثائق المرضى والأولياء، ثم فعّل الحساب عند القبول أو اكتب سببًا واضحًا عند الرفض."
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
              قائمة وثائق التحقق
            </h3>
            <p className="mt-1 text-sm text-slate-500">
              الطلبات المعروضة: {loading ? "..." : documents.length}
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
              onClick={loadDocuments}
              disabled={loading}
              className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
            >
              تحديث
            </button>
          </div>
        </div>

        <div className="mt-6 overflow-x-auto">
          <table className="min-w-[1080px] w-full border-separate border-spacing-0 text-right">
            <thead>
              <tr className="bg-slate-50 text-xs text-slate-500">
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  المستخدم
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  الدور
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  رقم الهوية
                </th>
                <th className="border-y border-slate-200 px-4 py-3 font-bold">
                  الوثيقة
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
                    colSpan={7}
                    className="border-b border-slate-100 px-4 py-10 text-center text-sm text-slate-500"
                  >
                    جارٍ تحميل طلبات التوثيق...
                  </td>
                </tr>
              ) : documents.length === 0 ? (
                <tr>
                  <td
                    colSpan={7}
                    className="border-b border-slate-100 px-4 py-10 text-center text-sm text-slate-500"
                  >
                    لا توجد طلبات ضمن الفلتر المحدد.
                  </td>
                </tr>
              ) : (
                documents.map((document) => (
                  <tr
                    key={document.id}
                    className="text-sm text-slate-700 transition hover:bg-slate-50"
                  >
                    <td className="border-b border-slate-100 px-4 py-4">
                      <p className="font-bold text-slate-900">
                        {document.user?.name || "مستخدم غير معروف"}
                      </p>
                      <p className="mt-1 text-xs text-slate-500">
                        {document.user?.phone ||
                          document.user?.email ||
                          "لا توجد وسيلة اتصال"}
                      </p>
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4">
                      <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-700">
                        {roleLabel(document.user?.role)}
                      </span>
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4 font-mono text-xs">
                      {document.user?.national_id || "—"}
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4">
                      <p className="max-w-48 truncate font-semibold text-slate-800">
                        {document.original_name}
                      </p>
                      <p className="mt-1 text-xs text-slate-500">
                        {formatFileSize(document.size_bytes)}
                      </p>
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4 text-xs text-slate-600">
                      {formatDate(document.submitted_at)}
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4">
                      <span
                        className={`inline-flex rounded-full border px-3 py-1 text-xs font-bold ${statusClasses(
                          document.status
                        )}`}
                      >
                        {statusLabel(document.status)}
                      </span>
                    </td>

                    <td className="border-b border-slate-100 px-4 py-4">
                      <div className="flex gap-2">
                        <button
                          type="button"
                          onClick={() => openDocumentFile(document)}
                          disabled={actionLoadingId === document.id}
                          className="rounded-lg border border-cyan-200 px-3 py-2 text-xs font-bold text-cyan-700 transition hover:bg-cyan-50 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                          الوثيقة
                        </button>

                        <button
                          type="button"
                          onClick={() => openReviewModal(document)}
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

      {selectedDocument && (
        <div
          className="fixed inset-0 z-50 overflow-y-auto bg-slate-950/55 p-4 sm:p-8"
          onMouseDown={closeReviewModal}
        >
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="verification-document-title"
            className="mx-auto my-6 w-full max-w-2xl rounded-3xl bg-white p-6 shadow-2xl sm:p-8"
            onMouseDown={(event) => event.stopPropagation()}
          >
            <div className="flex items-start justify-between gap-5">
              <div>
                <h3
                  id="verification-document-title"
                  className="text-xl font-bold text-slate-900"
                >
                  مراجعة وثيقة التحقق
                </h3>
                <p className="mt-2 text-sm leading-6 text-slate-500">
                  تحقق من هوية المستخدم ووضوح الملف قبل اتخاذ القرار.
                </p>
              </div>

              <button
                type="button"
                onClick={closeReviewModal}
                disabled={actionLoadingId === selectedDocument.id}
                className="rounded-xl bg-slate-100 px-3 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-200 disabled:opacity-60"
              >
                إغلاق
              </button>
            </div>

            <div className="mt-7 grid gap-4 rounded-2xl bg-slate-50 p-5 sm:grid-cols-2">
              <DetailItem
                label="اسم المستخدم"
                value={selectedDocument.user?.name || "—"}
              />
              <DetailItem
                label="الدور"
                value={roleLabel(selectedDocument.user?.role)}
              />
              <DetailItem
                label="رقم الهوية"
                value={selectedDocument.user?.national_id || "—"}
                mono
              />
              <DetailItem
                label="رقم الهاتف"
                value={selectedDocument.user?.phone || "غير مضاف"}
              />
              <DetailItem
                label="البريد الإلكتروني"
                value={selectedDocument.user?.email || "غير مضاف"}
              />
              <DetailItem
                label="كود المريض"
                value={selectedDocument.user?.patient_code || "—"}
              />
              <DetailItem
                label="اسم الوثيقة"
                value={selectedDocument.original_name}
              />
              <DetailItem
                label="حجم الملف"
                value={formatFileSize(selectedDocument.size_bytes)}
              />
              <DetailItem
                label="تاريخ الإرسال"
                value={formatDate(selectedDocument.submitted_at)}
              />
              <DetailItem
                label="حالة الحساب"
                value={
                  selectedDocument.user?.is_active
                    ? "الحساب مفعّل"
                    : "الحساب غير مفعّل"
                }
              />
            </div>

            <button
              type="button"
              onClick={() => openDocumentFile(selectedDocument)}
              disabled={actionLoadingId === selectedDocument.id}
              className="mt-5 w-full rounded-xl border border-cyan-200 bg-cyan-50 px-4 py-3 text-sm font-bold text-cyan-800 transition hover:bg-cyan-100 disabled:cursor-not-allowed disabled:opacity-60"
            >
              فتح وثيقة التحقق
            </button>

            {selectedDocument.status === "pending" ? (
              <>
                <div className="mt-5">
                  <label
                    htmlFor="rejectionReason"
                    className="mb-2 block text-sm font-bold text-slate-800"
                  >
                    سبب الرفض
                    <span className="mr-1 text-xs font-normal text-slate-500">
                      (مطلوب عند الرفض)
                    </span>
                  </label>

                  <textarea
                    id="rejectionReason"
                    value={rejectionReason}
                    onChange={(event) =>
                      setRejectionReason(event.target.value)
                    }
                    rows={4}
                    maxLength={1000}
                    placeholder="مثال: صورة الهوية غير واضحة، يرجى رفع صورة واضحة وكاملة للهوية."
                    disabled={actionLoadingId === selectedDocument.id}
                    className="w-full resize-y rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:bg-slate-100"
                  />
                </div>

                <div className="mt-5 grid gap-3 sm:grid-cols-2">
                  <button
                    type="button"
                    onClick={() => reviewDocument("rejected")}
                    disabled={actionLoadingId === selectedDocument.id}
                    className="rounded-xl border border-red-200 bg-red-50 px-4 py-3.5 text-sm font-bold text-red-700 transition hover:bg-red-100 disabled:cursor-not-allowed disabled:opacity-60"
                  >
                    {actionLoadingId === selectedDocument.id
                      ? "جارٍ الحفظ..."
                      : "رفض وطلب ملف جديد"}
                  </button>

                  <button
                    type="button"
                    onClick={() => reviewDocument("approved")}
                    disabled={actionLoadingId === selectedDocument.id}
                    className="rounded-xl bg-emerald-600 px-4 py-3.5 text-sm font-bold text-white transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:bg-emerald-300"
                  >
                    {actionLoadingId === selectedDocument.id
                      ? "جارٍ الحفظ..."
                      : "قبول وتفعيل الحساب"}
                  </button>
                </div>
              </>
            ) : (
              <div className="mt-5 rounded-2xl border border-slate-200 bg-slate-50 p-5">
                <p className="text-sm font-bold text-slate-800">
                  تمت مراجعة هذه الوثيقة
                </p>
                <p className="mt-2 text-sm text-slate-600">
                  الحالة: {statusLabel(selectedDocument.status)}
                </p>
                <p className="mt-1 text-sm text-slate-600">
                  وقت المراجعة: {formatDate(selectedDocument.reviewed_at)}
                </p>
                <p className="mt-1 text-sm text-slate-600">
                  المراجع: {selectedDocument.reviewer?.name || "—"}
                </p>

                {selectedDocument.rejection_reason && (
                  <p className="mt-3 whitespace-pre-wrap rounded-xl border border-red-100 bg-red-50 px-4 py-3 text-sm leading-6 text-red-800">
                    سبب الرفض: {selectedDocument.rejection_reason}
                  </p>
                )}
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