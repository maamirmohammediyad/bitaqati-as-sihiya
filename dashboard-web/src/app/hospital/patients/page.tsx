"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import {
  clearDashboardSession,
  getDashboardToken,
  getDashboardUser,
} from "@/lib/auth";

type ScanPatient = {
  id: string;
  name: string | null;
  patient_code: string | null;
  phone: string | null;
  blood_group: string | null;
};

type ScanEmployee = {
  id: string;
  name: string | null;
  employee_code: string | null;
};

type QrScan = {
  id: string;
  scanned_at: string | null;
  patient: ScanPatient;
  scanned_by: ScanEmployee;
};

type Paginator<T> = {
  current_page: number;
  data: T[];
  last_page: number;
  total: number;
};

type QrScansResponse = {
  data: Paginator<QrScan>;
};

function formatDateTime(value: string | null): string {
  if (!value) {
    return "وقت غير متاح";
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "وقت غير متاح";
  }

  return new Intl.DateTimeFormat("ar", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}

export default function HospitalPatientsPage() {
  const router = useRouter();

  const [scans, setScans] = useState<QrScan[]>([]);
  const [page, setPage] = useState(1);
  const [lastPage, setLastPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState("");

  const loadScans = useCallback(
    async (requestedPage = 1, isRefresh = false) => {
      const token = getDashboardToken();
      const user = getDashboardUser();

      if (!token || !user) {
        router.replace("/admin/login");
        return;
      }

      /*
       * الموقع مخصص لمسؤول المستشفى فقط.
       * الصحة الفعلية للصلاحية تُفحص كذلك من الـbackend.
       */
      if (user.role !== "health_worker") {
        router.replace("/admin/dashboard");
        return;
      }

      if (isRefresh) {
        setRefreshing(true);
      } else {
        setLoading(true);
      }

      setError("");

      try {
        const response = await api<QrScansResponse>(
          `/hospital/patients?per_page=20&page=${requestedPage}`,
          { token }
        );

        setScans(response.data.data);
        setPage(response.data.current_page);
        setLastPage(response.data.last_page);
        setTotal(response.data.total);
      } catch (err) {
        const message =
          err instanceof Error
            ? err.message
            : "تعذر تحميل سجل مرضى QR.";

        setError(message);

        if (
          message.includes("Unauthenticated") ||
          message.includes("غير مصادق") ||
          message.includes("Unauthorized")
        ) {
          clearDashboardSession();
          window.location.replace("/admin/login");
        }
      } finally {
        setLoading(false);
        setRefreshing(false);
      }
    },
    [router]
  );

  useEffect(() => {
    void loadScans();
  }, [loadScans]);

  return (
    <main dir="rtl" className="min-h-screen bg-slate-100 text-right">
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4 sm:px-6">
          <div>
            <p className="text-xs font-bold tracking-wide text-cyan-700">
              BITAQATI AS-SIHIYA
            </p>
            <h1 className="mt-1 text-lg font-bold text-slate-900">
              سجل مرضى QR
            </h1>
          </div>

          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => void loadScans(page, true)}
              disabled={loading || refreshing}
              className="rounded-xl border border-cyan-200 px-4 py-2 text-sm font-bold text-cyan-700 transition hover:bg-cyan-50 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {refreshing ? "جارٍ التحديث..." : "تحديث"}
            </button>

            <button
              type="button"
              onClick={() => router.push("/hospital/dashboard")}
              className="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50"
            >
              العودة للوحة التحكم
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-8 sm:px-6">
        <section className="rounded-3xl bg-slate-900 p-7 text-white shadow-xl sm:p-9">
          <p className="text-sm font-semibold text-cyan-300">
            سجل التحقق من المرضى
          </p>

          <h2 className="mt-3 text-2xl font-bold sm:text-3xl">
            المرضى الذين تم مسح رمز QR الخاص بهم
          </h2>

          <p className="mt-3 max-w-3xl text-sm leading-7 text-slate-300">
            يعرض هذا السجل جميع عمليات مسح QR التي تمت داخل المستشفى، مع اسم
            الموظف الذي نفّذ عملية المسح.
          </p>
        </section>

        {error && (
          <div
            role="alert"
            className="mt-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-medium text-red-700"
          >
            {error}
          </div>
        )}

        <section className="mt-7 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between border-b border-slate-100 px-5 py-5 sm:px-6">
            <div>
              <h2 className="text-lg font-bold text-slate-900">
                المرضى المسجلون
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                {loading
                  ? "جارٍ تحميل البيانات..."
                  : `إجمالي عمليات المسح: ${total.toLocaleString("ar")}`}
              </p>
            </div>
          </div>

          {loading ? (
            <div className="space-y-4 p-5 sm:p-6">
              <SkeletonRow />
              <SkeletonRow />
              <SkeletonRow />
            </div>
          ) : scans.length === 0 ? (
            <div className="p-10 text-center">
              <p className="font-bold text-slate-700">
                لا توجد عمليات مسح QR حتى الآن.
              </p>

              <p className="mt-2 text-sm text-slate-500">
                ستظهر هنا عمليات التحقق التي يجريها موظفو المستشفى من تطبيق
                الهاتف.
              </p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {scans.map((scan) => (
                <article
                  key={scan.id}
                  className="flex flex-col gap-4 px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-6"
                >
                  <div className="min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="font-bold text-slate-900">
                        {scan.patient.name || "مريض غير معروف"}
                      </h3>

                      {scan.patient.blood_group && (
                        <span className="rounded-full bg-red-50 px-2.5 py-1 text-xs font-bold text-red-700">
                          فصيلة الدم: {scan.patient.blood_group}
                        </span>
                      )}
                    </div>

                    <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-sm text-slate-500">
                      {scan.patient.patient_code && (
                        <span dir="ltr">
                          رقم المريض: {scan.patient.patient_code}
                        </span>
                      )}

                      {scan.patient.phone && (
                        <span dir="ltr">{scan.patient.phone}</span>
                      )}

                      {scan.scanned_by.name && (
                        <span>
                          تم المسح بواسطة: {scan.scanned_by.name}
                          {scan.scanned_by.employee_code && (
                            <span dir="ltr">
                              {" "}
                              ({scan.scanned_by.employee_code})
                            </span>
                          )}
                        </span>
                      )}
                    </div>
                  </div>

                  <div className="shrink-0 text-sm text-slate-500 sm:text-left">
                    <p>{formatDateTime(scan.scanned_at)}</p>
                  </div>
                </article>
              ))}
            </div>
          )}

          {!loading && lastPage > 1 && (
            <div className="flex items-center justify-between border-t border-slate-100 px-5 py-4 sm:px-6">
              <button
                type="button"
                disabled={page <= 1}
                onClick={() => void loadScans(page - 1)}
                className="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
              >
                السابق
              </button>

              <span className="text-sm font-bold text-slate-600">
                صفحة {page.toLocaleString("ar")} من{" "}
                {lastPage.toLocaleString("ar")}
              </span>

              <button
                type="button"
                disabled={page >= lastPage}
                onClick={() => void loadScans(page + 1)}
                className="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
              >
                التالي
              </button>
            </div>
          )}
        </section>
      </main>
    </main>
  );
}

function SkeletonRow() {
  return (
    <div className="animate-pulse rounded-2xl bg-slate-50 p-5">
      <div className="h-4 w-40 rounded bg-slate-200" />
      <div className="mt-3 h-3 w-64 max-w-full rounded bg-slate-200" />
    </div>
  );
}