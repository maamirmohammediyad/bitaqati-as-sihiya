"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { api } from "@/lib/api";
import { getDashboardToken } from "@/lib/auth";

type MedicalFile = {
  id: string;
  original_name?: string | null;
  file_name?: string | null;
  name?: string | null;
  mime_type?: string | null;
  size?: number | null;
  file_size?: number | null;
  created_at?: string | null;
  uploaded_at?: string | null;
  uploaded_by?: {
    id?: string;
    name?: string | null;
  } | null;
};

type MedicalFilesResponse = {
  data: MedicalFile[];
};

type PageProps = {
  params: Promise<{
    patientId: string;
  }>;
};

export default function HospitalPatientPage({ params }: PageProps) {
  const [patientId, setPatientId] = useState("");
  const [files, setFiles] = useState<MedicalFile[]>([]);
  const [loading, setLoading] = useState(true);
  const [openingId, setOpeningId] = useState<string | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    void params.then(({ patientId: id }) => setPatientId(id));
  }, [params]);

  const loadFiles = useCallback(async () => {
    if (!patientId) return;

    const token = getDashboardToken();

    if (!token) {
      setError("انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.");
      setLoading(false);
      return;
    }

    setLoading(true);
    setError("");

    try {
      const response = await api<MedicalFilesResponse>(
        `/hospital/patients/${patientId}/medical-files`,
        { token },
      );

      setFiles(response.data || []);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تحميل الملفات الطبية.",
      );
    } finally {
      setLoading(false);
    }
  }, [patientId]);

  useEffect(() => {
    void loadFiles();
  }, [loadFiles]);

  async function previewFile(file: MedicalFile) {
    const token = getDashboardToken();

    if (!token || !patientId) {
      setError("انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.");
      return;
    }

    const previewWindow = window.open("", "_blank");

    if (!previewWindow) {
      setError("تعذر فتح نافذة المعاينة. تحقق من السماح بالنوافذ المنبثقة.");
      return;
    }

    setOpeningId(file.id);
    setError("");

    try {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL;

      if (!baseUrl) {
        throw new Error("NEXT_PUBLIC_API_URL غير موجود في ملف .env.local");
      }

      const response = await fetch(
        `${baseUrl}/hospital/patients/${patientId}/medical-files/${file.id}/download`,
        {
          headers: {
            Accept: "application/pdf,image/*,application/octet-stream,*/*",
            Authorization: `Bearer ${token}`,
          },
        },
      );

      if (!response.ok) {
        const json = await response.json().catch(() => null);

        throw new Error(json?.message || "تعذر فتح الملف للمعاينة.");
      }

      const blob = await response.blob();
      const url = URL.createObjectURL(blob);

      previewWindow.location.href = url;

      window.setTimeout(() => {
        URL.revokeObjectURL(url);
      }, 60_000);
    } catch (err) {
      previewWindow.close();

      setError(
        err instanceof Error ? err.message : "تعذر معاينة الملف الطبي.",
      );
    } finally {
      setOpeningId(null);
    }
  }

  return (
    <main
      dir="rtl"
      className="min-h-screen bg-slate-50 px-4 py-8 text-right sm:px-6 lg:px-10"
    >
      <div className="mx-auto max-w-6xl">
        <header className="rounded-3xl bg-slate-950 px-6 py-7 text-white shadow-xl sm:px-8">
          <Link
            href="/hospital/emergencies"
            className="text-sm font-bold text-cyan-300 transition hover:text-cyan-200"
          >
            ← العودة إلى حالات الطوارئ
          </Link>

          <p className="mt-5 text-sm font-semibold text-cyan-300">
            السجل الطبي للمريض
          </p>

          <h1 className="mt-1 text-3xl font-bold">الملفات الطبية</h1>

          <p className="mt-2 break-all text-sm text-slate-300">
            معرّف المريض: {patientId || "جارٍ التحميل..."}
          </p>

          <p className="mt-4 inline-flex rounded-full border border-cyan-400/30 bg-cyan-400/10 px-3 py-1.5 text-xs font-bold text-cyan-200">
            وضع العرض فقط — لا يمكن رفع أو حذف أو تعديل الملفات من هذه الصفحة
          </p>
        </header>

        {error ? (
          <div
            role="alert"
            className="mt-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700"
          >
            {error}
          </div>
        ) : null}

        <section className="mt-6 overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
          <div className="flex flex-col gap-3 border-b border-slate-100 px-6 py-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h2 className="text-xl font-bold text-slate-900">
                المستندات المرفوعة
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                يمكنك معاينة التقارير الطبية ونتائج التحاليل والأشعة والوصفات
                العلاجية.
              </p>
            </div>

            <button
              type="button"
              onClick={() => void loadFiles()}
              disabled={loading}
              className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {loading ? "جارٍ التحديث..." : "تحديث"}
            </button>
          </div>

          {loading ? (
            <p className="px-6 py-14 text-center text-sm text-slate-500">
              جارٍ تحميل الملفات الطبية...
            </p>
          ) : files.length === 0 ? (
            <div className="px-6 py-14 text-center">
              <p className="text-base font-bold text-slate-700">
                لا توجد ملفات طبية مرفوعة لهذا المريض.
              </p>

              <p className="mt-2 text-sm text-slate-500">
                ستظهر هنا الملفات التي رفعها المريض أو الطبيب المخوّل.
              </p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {files.map((file) => (
                <article
                  key={file.id}
                  className="flex flex-col gap-4 p-6 lg:flex-row lg:items-center lg:justify-between"
                >
                  <div className="min-w-0">
                    <h3 className="truncate text-base font-bold text-slate-900">
                      {getFileName(file)}
                    </h3>

                    <div className="mt-2 flex flex-wrap gap-x-5 gap-y-2 text-sm text-slate-500">
                      <span>{file.mime_type || "نوع الملف غير معروف"}</span>

                      <span>
                        {formatFileSize(file.size ?? file.file_size)}
                      </span>

                      <span>
                        تاريخ الرفع:{" "}
                        {formatDate(file.created_at || file.uploaded_at)}
                      </span>

                      {file.uploaded_by?.name ? (
                        <span>رُفع بواسطة: {file.uploaded_by.name}</span>
                      ) : null}
                    </div>
                  </div>

                  <button
                    type="button"
                    onClick={() => void previewFile(file)}
                    disabled={openingId === file.id}
                    className="w-fit rounded-xl border border-cyan-200 bg-cyan-50 px-4 py-2.5 text-sm font-bold text-cyan-700 transition hover:bg-cyan-100 disabled:cursor-not-allowed disabled:opacity-60"
                  >
                    {openingId === file.id
                      ? "جارٍ فتح الملف..."
                      : "معاينة الملف"}
                  </button>
                </article>
              ))}
            </div>
          )}
        </section>
      </div>
    </main>
  );
}

function getFileName(file: MedicalFile) {
  return file.original_name || file.file_name || file.name || "ملف طبي";
}

function formatDate(value?: string | null) {
  if (!value) return "غير متوفر";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat("ar-DZ", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}

function formatFileSize(bytes?: number | null) {
  if (!bytes || bytes <= 0) return "الحجم غير متوفر";

  if (bytes < 1024) return `${bytes} B`;

  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  }

  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}