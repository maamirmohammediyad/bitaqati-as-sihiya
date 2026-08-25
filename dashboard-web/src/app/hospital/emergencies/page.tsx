"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { api } from "@/lib/api";
import { getDashboardToken } from "@/lib/auth";
import Link from "next/link";
type Patient = {
  id?: string;
  name?: string | null;
  phone?: string | null;
  patient_code?: string | null;
};

type Emergency = {
  id: string;
  status: "active" | "checked_in" | "resolved" | string;
  created_at?: string | null;
  checked_in_at?: string | null;
  resolved_at?: string | null;
  distance_km?: number | null;
  location_name?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  user?: Patient | null;
  patient?: Patient | null;
};

type Pagination<T> = {
  data: T[];
  current_page?: number;
  last_page?: number;
  total?: number;
};

type EmergenciesResponse = {
  data: {
    available_emergencies: Pagination<Emergency>;
    hospital_emergencies: Pagination<Emergency>;
  };
};
function formatDate(value?: string | null) {
  if (!value) return "غير متوفر";

  return new Intl.DateTimeFormat("ar-DZ", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

function getPatientName(emergency: Emergency) {
  return emergency.patient?.name || emergency.user?.name || "مريض غير معروف";
}

function getPatientCode(emergency: Emergency) {
  return emergency.patient?.patient_code || emergency.user?.patient_code || "—";
}

function getPatientPhone(emergency: Emergency) {
  return emergency.patient?.phone || emergency.user?.phone || "—";
}

function statusLabel(status: Emergency["status"]) {
  const labels: Record<string, string> = {
    active: "بانتظار الاستقبال",
    checked_in: "وصل إلى المستشفى",
    resolved: "تم إنهاء الحالة",
  };

  return labels[status] || status;
}

function statusClass(status: Emergency["status"]) {
  const classes: Record<string, string> = {
    active: "bg-amber-50 text-amber-700 ring-amber-200",
    checked_in: "bg-sky-50 text-sky-700 ring-sky-200",
    resolved: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  };

  return classes[status] || "bg-slate-100 text-slate-700 ring-slate-200";
}

export default function HospitalEmergenciesPage() {
  const [available, setAvailable] = useState<Emergency[]>([]);
  const [hospitalCases, setHospitalCases] = useState<Emergency[]>([]);
  const [hospitalStatus, setHospitalStatus] = useState("");
  const [loading, setLoading] = useState(true);
  const [actionId, setActionId] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");

  const token = useMemo(() => getDashboardToken(), []);

  const loadEmergencies = useCallback(async () => {
    if (!token) {
      setError("انتهت الجلسة. سجّل الدخول مرة أخرى.");
      setLoading(false);
      return;
    }

    setLoading(true);
    setError("");

    try {
      const query = new URLSearchParams({
        per_page: "20",
      });

      if (hospitalStatus) {
        query.set("status", hospitalStatus);
      }

      const response = await api<EmergenciesResponse>(
  `/hospital/emergencies?${query.toString()}`,
  {
    token,
  },
);

      setAvailable(response.data.available_emergencies.data || []);
      setHospitalCases(response.data.hospital_emergencies.data || []);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تحميل حالات الطوارئ.",
      );
    } finally {
      setLoading(false);
    }
  }, [hospitalStatus, token]);

  useEffect(() => {
    void loadEmergencies();
  }, [loadEmergencies]);

  async function checkIn(emergency: Emergency) {
    const confirmed = window.confirm(
      `هل تؤكد تسجيل وصول المريض "${getPatientName(emergency)}" إلى المستشفى؟`,
    );

    if (!confirmed || !token) return;

    setActionId(emergency.id);
    setError("");
    setMessage("");

    try {
      await api(`/emergency/${emergency.id}/check-in`, {
  method: "POST",
  token,
});

      setMessage("تم تسجيل وصول المريض إلى المستشفى بنجاح.");
      await loadEmergencies();
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تسجيل وصول المريض.",
      );
    } finally {
      setActionId(null);
    }
  }

  async function resolveEmergency(emergency: Emergency) {
    const notes = window.prompt("أضف ملاحظة ختامية للحالة (اختياري):");

    if (notes === null || !token) return;

    setActionId(emergency.id);
    setError("");
    setMessage("");

    try {
      await api(`/hospital/emergencies/${emergency.id}/resolve`, {
  method: "POST",
  token,
  body: JSON.stringify({
    resolution_notes: notes,
  }),
});

      setMessage("تم إنهاء حالة الطوارئ بنجاح.");
      await loadEmergencies();
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر إنهاء حالة الطوارئ.",
      );
    } finally {
      setActionId(null);
    }
  }

  function openMap(emergency: Emergency) {
    if (emergency.latitude === null || emergency.longitude === null) {
      setError("لا تتوفر إحداثيات موقع لهذه الحالة.");
      return;
    }

    window.open(
      `https://www.google.com/maps?q=${emergency.latitude},${emergency.longitude}`,
      "_blank",
      "noopener,noreferrer",
    );
  }

  return (
    <main dir="rtl" className="min-h-screen bg-slate-50 px-4 py-8 text-right sm:px-6 lg:px-10">
      <div className="mx-auto max-w-7xl">
        <section className="rounded-3xl bg-slate-950 px-6 py-8 text-white shadow-xl sm:px-8">
          <p className="text-sm font-semibold text-cyan-300">
            إدارة استقبال الحالات
          </p>

          <div className="mt-2 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <h1 className="text-3xl font-bold">حالات الطوارئ</h1>
              <p className="mt-2 text-sm leading-7 text-slate-300">
                استقبل الحالات القريبة، سجّل وصول المرضى، وتابع الحالات داخل المستشفى.
              </p>
            </div>

            <button
              type="button"
              onClick={() => void loadEmergencies()}
              disabled={loading}
              className="rounded-xl bg-cyan-600 px-5 py-3 text-sm font-bold transition hover:bg-cyan-500 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {loading ? "جارٍ التحديث..." : "تحديث القائمة"}
            </button>
          </div>
        </section>

        {error ? (
          <div
            role="alert"
            className="mt-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700"
          >
            {error}
          </div>
        ) : null}

        {message ? (
          <div className="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50 px-5 py-4 text-sm text-emerald-700">
            {message}
          </div>
        ) : null}

        <section className="mt-6 grid gap-4 sm:grid-cols-3">
          <div className="rounded-2xl border border-amber-100 bg-amber-50 p-5">
            <p className="text-sm font-medium text-amber-700">حالات متاحة</p>
            <p className="mt-1 text-3xl font-bold text-amber-900">{available.length}</p>
          </div>

          <div className="rounded-2xl border border-sky-100 bg-sky-50 p-5">
            <p className="text-sm font-medium text-sky-700">داخل المستشفى</p>
            <p className="mt-1 text-3xl font-bold text-sky-900">{hospitalCases.length}</p>
          </div>

          <div className="rounded-2xl border border-emerald-100 bg-emerald-50 p-5">
            <p className="text-sm font-medium text-emerald-700">الحالة المعروضة</p>
            <p className="mt-1 text-lg font-bold text-emerald-900">
              {hospitalStatus ? statusLabel(hospitalStatus) : "كل الحالات"}
            </p>
          </div>
        </section>

        <section className="mt-8 overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
          <div className="border-b border-slate-100 px-6 py-5">
            <h2 className="text-xl font-bold text-slate-900">حالات متاحة للاستقبال</h2>
            <p className="mt-1 text-sm text-slate-500">
              هذه حالات طوارئ نشطة وقريبة من موقع المستشفى.
            </p>
          </div>

          {loading ? (
            <p className="px-6 py-12 text-center text-slate-500">جارٍ تحميل الحالات...</p>
          ) : available.length === 0 ? (
            <p className="px-6 py-12 text-center text-slate-500">
              لا توجد حالات طوارئ متاحة حاليًا.
            </p>
          ) : (
            <div className="divide-y divide-slate-100">
              {available.map((emergency) => (
                <article key={emergency.id} className="p-6">
                  <div className="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
                    <div>
                      <div className="flex flex-wrap items-center gap-3">
                        <h3 className="text-lg font-bold text-slate-900">
                          {getPatientName(emergency)}
                        </h3>
                        <span className={`rounded-full px-3 py-1 text-xs font-bold ring-1 ${statusClass(emergency.status)}`}>
                          {statusLabel(emergency.status)}
                        </span>
                      </div>

                      <div className="mt-3 flex flex-wrap gap-x-5 gap-y-2 text-sm text-slate-600">
                        <span>رقم البطاقة: {getPatientCode(emergency)}</span>
                        <span>الهاتف: {getPatientPhone(emergency)}</span>
                        <span>الموقع: {emergency.location_name || "غير محدد"}</span>
                        <span>
                          المسافة:{" "}
                          {emergency.distance_km !== null && emergency.distance_km !== undefined
                            ? `${Number(emergency.distance_km).toFixed(1)} كم`
                            : "غير متوفرة"}
                        </span>
                        <span>وقت الطلب: {formatDate(emergency.created_at)}</span>
                      </div>
                    </div>

                    <div className="flex flex-wrap gap-3">
                      <button
                        type="button"
                        onClick={() => openMap(emergency)}
                        className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-bold text-slate-700 transition hover:bg-slate-50"
                      >
                        فتح الخريطة
                      </button>

                      <button
                        type="button"
                        onClick={() => void checkIn(emergency)}
                        disabled={actionId === emergency.id}
                        className="rounded-xl bg-cyan-600 px-4 py-2.5 text-sm font-bold text-white transition hover:bg-cyan-500 disabled:cursor-not-allowed disabled:opacity-60"
                      >
                        {actionId === emergency.id ? "جارٍ التسجيل..." : "تسجيل الوصول"}
                      </button>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>

        <section className="mt-8 overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
          <div className="flex flex-col gap-4 border-b border-slate-100 px-6 py-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h2 className="text-xl font-bold text-slate-900">حالات المستشفى</h2>
              <p className="mt-1 text-sm text-slate-500">
                الحالات التي تم تسجيل وصولها إلى المستشفى.
              </p>
            </div>

            <select
              value={hospitalStatus}
              onChange={(event) => setHospitalStatus(event.target.value)}
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 outline-none focus:border-cyan-500 focus:ring-4 focus:ring-cyan-100"
            >
              <option value="">كل الحالات</option>
              <option value="checked_in">وصلت إلى المستشفى</option>
              <option value="resolved">تم إنهاؤها</option>
            </select>
          </div>

          {loading ? (
            <p className="px-6 py-12 text-center text-slate-500">جارٍ تحميل الحالات...</p>
          ) : hospitalCases.length === 0 ? (
            <p className="px-6 py-12 text-center text-slate-500">
              لا توجد حالات مسجلة في المستشفى ضمن هذا الفلتر.
            </p>
          ) : (
            <div className="divide-y divide-slate-100">
              {hospitalCases.map((emergency) => (
                <article key={emergency.id} className="p-6">
                  <div className="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
                    <div>
                      <div className="flex flex-wrap items-center gap-3">
                        <h3 className="text-lg font-bold text-slate-900">
                          {getPatientName(emergency)}
                        </h3>
                        <span className={`rounded-full px-3 py-1 text-xs font-bold ring-1 ${statusClass(emergency.status)}`}>
                          {statusLabel(emergency.status)}
                        </span>
                      </div>

                      <div className="mt-3 flex flex-wrap gap-x-5 gap-y-2 text-sm text-slate-600">
                        <span>رقم البطاقة: {getPatientCode(emergency)}</span>
                        <span>الهاتف: {getPatientPhone(emergency)}</span>
                        <span>وقت الوصول: {formatDate(emergency.checked_in_at)}</span>
                        <span>وقت الطلب: {formatDate(emergency.created_at)}</span>
                      </div>
                    </div>

                    <div className="flex flex-wrap gap-3">
                      {emergency.status === "checked_in" ? (
                        <button
                          type="button"
                          onClick={() => void resolveEmergency(emergency)}
                          disabled={actionId === emergency.id}
                          className="rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-bold text-white transition hover:bg-emerald-500 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                          {actionId === emergency.id ? "جارٍ الإنهاء..." : "إنهاء الحالة"}
                        </button>
                      ) : null}
                      <Link
  href={`/hospital/patients/${emergency.patient?.id || emergency.user?.id}`}
  className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-bold text-slate-700 transition hover:bg-slate-50"
>
  ملف المريض
</Link>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>
      </div>
    </main>
  );
}