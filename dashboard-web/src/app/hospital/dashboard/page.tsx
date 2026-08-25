"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import {
  clearAdminSession,
  getAdminToken,
  getAdminUser,
} from "@/lib/auth";

type EmergencyStatus = "active" | "checked_in" | "resolved" | string;

type RecentEmergency = {
  id: string;
  status: EmergencyStatus;
  latitude: number | null;
  longitude: number | null;
  location_name: string | null;
  created_at: string | null;
  checked_in_at: string | null;
  patient: {
    id: string | null;
    name: string | null;
    phone: string | null;
    patient_code: string | null;
  };
};

type HospitalDashboardResponse = {
  data: {
    hospital: {
      id: string;
      name: string;
      type: string | null;
      phone: string | null;
      address: string | null;
      city: string | null;
      is_active: boolean;
    };
    staff: {
      id: string;
      name: string;
      role: string;
    };
    statistics: {
      active_emergencies: number;
      hospital_active_emergencies: number;
      checked_in_today: number;
      resolved_today: number;
      active_staff_count: number;
    };
    recent_emergencies: RecentEmergency[];
  };
};

type DashboardData = HospitalDashboardResponse["data"];

function getInitialDashboardData(): DashboardData {
  return {
    hospital: {
      id: "",
      name: "",
      type: null,
      phone: null,
      address: null,
      city: null,
      is_active: true,
    },
    staff: {
      id: "",
      name: "",
      role: "",
    },
    statistics: {
      active_emergencies: 0,
      hospital_active_emergencies: 0,
      checked_in_today: 0,
      resolved_today: 0,
      active_staff_count: 0,
    },
    recent_emergencies: [],
  };
}

export default function HospitalDashboardPage() {
  const router = useRouter();

  const [dashboard, setDashboard] = useState<DashboardData>(
    getInitialDashboardData
  );
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState("");

  const loadDashboard = useCallback(
    async (isRefresh = false) => {
      const token = getAdminToken();
      const user = getAdminUser();

      if (!token || !user) {
        router.replace("/admin/login");
        return;
      }

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
        const response = await api<HospitalDashboardResponse>(
          "/hospital/dashboard",
          { token }
        );

        setDashboard(response.data);
      } catch (err) {
        const message =
          err instanceof Error
            ? err.message
            : "تعذر تحميل بيانات لوحة المستشفى.";

        setError(message);

        if (
          message.includes("Unauthenticated") ||
          message.includes("غير مصادق") ||
          message.includes("Unauthorized")
        ) {
          clearAdminSession();
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
    void loadDashboard();
  }, [loadDashboard]);

  async function handleLogout() {
    const token = getAdminToken();

    try {
      if (token) {
        await api("/auth/logout", {
          method: "POST",
          token,
        });
      }
    } catch {
      // تمسح الجلسة محليًا حتى عند تعذر الوصول إلى الخادم.
    } finally {
      clearAdminSession();
      window.location.replace("/admin/login");
    }
  }

  return (
    <main dir="rtl" className="min-h-screen bg-slate-100 text-right">
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4 sm:px-6">
          <div>
            <p className="text-xs font-bold tracking-wide text-cyan-700">
              BITAQATI AS-SIHIYA
            </p>
            <h1 className="mt-1 text-lg font-bold text-slate-900">
              لوحة إدارة المستشفى
            </h1>
          </div>
<ActionCard
  title="إعدادات الحساب"
  description="تغيير كلمة مرور حساب الموظف الحالي."
  action="تغيير كلمة المرور"
  onClick={() => router.push("/hospital/settings/password")}
/>
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => void loadDashboard(true)}
              disabled={loading || refreshing}
              className="rounded-xl border border-cyan-200 px-4 py-2 text-sm font-bold text-cyan-700 transition hover:bg-cyan-50 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {refreshing ? "جارٍ التحديث..." : "تحديث البيانات"}
            </button>

            <button
              type="button"
              onClick={() => void handleLogout()}
              className="rounded-xl border border-red-200 px-4 py-2 text-sm font-bold text-red-700 transition hover:bg-red-50"
            >
              تسجيل الخروج
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-8 sm:px-6">
        {error && (
          <div
            role="alert"
            className="mb-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700"
          >
            {error}
          </div>
        )}

        <section className="rounded-3xl bg-slate-900 p-7 text-white shadow-xl sm:p-9">
          <div className="flex flex-col justify-between gap-5 sm:flex-row sm:items-start">
            <div>
              <p className="text-sm font-semibold text-cyan-300">
                {loading ? "جارٍ التحميل..." : dashboard.hospital.name}
              </p>

              <h2 className="mt-3 text-2xl font-bold sm:text-3xl">
                مرحبًا، {dashboard.staff.name || "مسؤول المستشفى"}
              </h2>

              <p className="mt-3 max-w-2xl text-sm leading-7 text-slate-300">
                تابع طوارئ المستشفى، حالة الاستقبال، والطاقم الطبي من مكان
                واحد.
              </p>
            </div>

            {!loading && dashboard.hospital.city && (
              <div className="rounded-2xl border border-slate-700 bg-slate-800/80 px-4 py-3 text-sm text-slate-300">
                <p className="font-bold text-white">
                  {dashboard.hospital.city}
                </p>
                {dashboard.hospital.type && (
                  <p className="mt-1 text-xs text-slate-400">
                    {dashboard.hospital.type}
                  </p>
                )}
              </div>
            )}
          </div>
        </section>

        <section className="mt-7 grid gap-5 sm:grid-cols-2 xl:grid-cols-5">
          <StatCard
            label="طوارئ متاحة"
            value={dashboard.statistics.active_emergencies}
            loading={loading}
            tone="red"
          />
          <StatCard
            label="حالات قيد المتابعة"
            value={dashboard.statistics.hospital_active_emergencies}
            loading={loading}
            tone="amber"
          />
          <StatCard
            label="استقبال اليوم"
            value={dashboard.statistics.checked_in_today}
            loading={loading}
            tone="blue"
          />
          <StatCard
            label="حالات منتهية اليوم"
            value={dashboard.statistics.resolved_today}
            loading={loading}
            tone="emerald"
          />
          <StatCard
            label="الطاقم النشط"
            value={dashboard.statistics.active_staff_count}
            loading={loading}
            tone="violet"
          />
        </section>

        <section className="mt-7 grid gap-5 lg:grid-cols-3">
  <ActionCard
    title="الطاقم الطبي"
    description="عرض الموظفين، إضافة موظف جديد، وتحديد الدور والصلاحيات."
    action="إدارة الطاقم"
    onClick={() => router.push("/hospital/staff")}
  />

  <ActionCard
    title="الطوارئ"
    description="مراجعة البلاغات المتاحة، استقبال الحالات، ومتابعة السجل."
    action="فتح الطوارئ"
    onClick={() => router.push("/hospital/emergencies")}
  />

  <ActionCard
    title="سجلات QR"
    description="عرض المرضى الذين تم التحقق من QR الخاص بهم في المستشفى."
    action="عرض المرضى"
    onClick={() => router.push("/hospital/patients")}
  />
</section>

        <section className="mt-7 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between border-b border-slate-100 px-5 py-5 sm:px-6">
            <div>
              <h2 className="text-lg font-bold text-slate-900">
                آخر بلاغات الطوارئ
              </h2>
              <p className="mt-1 text-sm text-slate-500">
                أحدث البلاغات المتاحة والحالات المرتبطة بهذا المستشفى.
              </p>
            </div>

            <span className="rounded-lg bg-slate-100 px-3 py-1.5 text-xs font-bold text-slate-600">
              {loading
                ? "..."
                : `${dashboard.recent_emergencies.length.toLocaleString("ar")} بلاغ`}
            </span>
          </div>

          {loading ? (
            <div className="space-y-4 p-5 sm:p-6">
              <SkeletonRow />
              <SkeletonRow />
              <SkeletonRow />
            </div>
          ) : dashboard.recent_emergencies.length === 0 ? (
            <div className="p-10 text-center">
              <p className="font-bold text-slate-700">
                لا توجد بلاغات طوارئ حاليًا.
              </p>
              <p className="mt-2 text-sm text-slate-500">
                ستظهر البلاغات الجديدة هنا عند إنشائها.
              </p>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {dashboard.recent_emergencies.map((emergency) => (
                <EmergencyRow key={emergency.id} emergency={emergency} />
              ))}
            </div>
          )}
        </section>
      </main>
    </main>
  );
}

function StatCard({
  label,
  value,
  loading,
  tone,
}: {
  label: string;
  value: number;
  loading: boolean;
  tone: "red" | "amber" | "blue" | "emerald" | "violet";
}) {
  const colors = {
    red: "border-red-100 bg-red-50 text-red-700",
    amber: "border-amber-100 bg-amber-50 text-amber-700",
    blue: "border-blue-100 bg-blue-50 text-blue-700",
    emerald: "border-emerald-100 bg-emerald-50 text-emerald-700",
    violet: "border-violet-100 bg-violet-50 text-violet-700",
  };

  return (
    <article className={`rounded-2xl border p-5 ${colors[tone]}`}>
      <p className="text-sm font-semibold opacity-80">{label}</p>
      <p className="mt-4 text-3xl font-bold">
        {loading ? "..." : value.toLocaleString("ar")}
      </p>
    </article>
  );
}

function ActionCard({
  title,
  description,
  action,
  onClick,
}: {
  title: string;
  description: string;
  action: string;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="rounded-2xl bg-white p-6 text-right shadow-sm ring-1 ring-slate-200 transition hover:-translate-y-0.5 hover:ring-cyan-300"
    >
      <h3 className="text-base font-bold text-slate-900">{title}</h3>
      <p className="mt-2 text-sm leading-6 text-slate-500">{description}</p>
      <span className="mt-5 inline-flex rounded-lg bg-cyan-50 px-3 py-1.5 text-xs font-bold text-cyan-700">
        {action}
      </span>
    </button>
  );
}

function EmergencyRow({ emergency }: { emergency: RecentEmergency }) {
  const status = getEmergencyStatus(emergency.status);
  const createdAt = formatDateTime(emergency.created_at);

  return (
    <article className="flex flex-col gap-4 px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-6">
      <div className="min-w-0">
        <div className="flex flex-wrap items-center gap-2">
          <h3 className="font-bold text-slate-900">
            {emergency.patient.name || "مريض غير معروف"}
          </h3>
          <span
            className={`rounded-full px-2.5 py-1 text-xs font-bold ${status.className}`}
          >
            {status.label}
          </span>
        </div>

        <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-sm text-slate-500">
          {emergency.patient.patient_code && (
            <span dir="ltr">
              رقم المريض: {emergency.patient.patient_code}
            </span>
          )}

          {emergency.location_name && (
            <span>الموقع: {emergency.location_name}</span>
          )}

          {!emergency.location_name &&
            emergency.latitude !== null &&
            emergency.longitude !== null && (
              <span dir="ltr">
                {emergency.latitude}, {emergency.longitude}
              </span>
            )}
        </div>
      </div>

      <div className="shrink-0 text-sm text-slate-500 sm:text-left">
        <p>{createdAt}</p>
        {emergency.patient.phone && (
          <p className="mt-1" dir="ltr">
            {emergency.patient.phone}
          </p>
        )}
      </div>
    </article>
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

function getEmergencyStatus(status: EmergencyStatus): {
  label: string;
  className: string;
} {
  if (status === "active") {
    return {
      label: "بانتظار الاستقبال",
      className: "bg-red-100 text-red-700",
    };
  }

  if (status === "checked_in") {
    return {
      label: "قيد المتابعة",
      className: "bg-amber-100 text-amber-700",
    };
  }

  if (status === "resolved") {
    return {
      label: "تمت المعالجة",
      className: "bg-emerald-100 text-emerald-700",
    };
  }

  return {
    label: status || "غير محدد",
    className: "bg-slate-100 text-slate-700",
  };
}

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