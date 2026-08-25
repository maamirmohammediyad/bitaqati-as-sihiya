"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import {
  clearDashboardSession,
  getDashboardToken,
  getDashboardUser,
} from "@/lib/auth";

type HospitalStaffRole =
  | "admin"
  | "receptionist"
  | "doctor"
  | "nurse"
  | "staff";

type StaffMember = {
  id: string;
  user_id: string;
  name: string | null;
  email: string | null;
  employee_code: string | null;
  phone: string | null;
  role: HospitalStaffRole | string;
  is_active: boolean;
  joined_at: string | null;
};

type StaffResponse = {
  data: StaffMember[];
};

type UpdateStaffResponse = {
  message: string;
  data: StaffMember;
};

const ROLE_OPTIONS: Array<{
  value: HospitalStaffRole;
  label: string;
}> = [
  { value: "admin", label: "مسؤول المستشفى" },
  { value: "receptionist", label: "موظف استقبال" },
  { value: "doctor", label: "طبيب" },
  { value: "nurse", label: "ممرض / ممرضة" },
  { value: "staff", label: "موظف" },
];

function roleLabel(role: string): string {
  return ROLE_OPTIONS.find((item) => item.value === role)?.label || role;
}

function formatDate(value: string | null): string {
  if (!value) {
    return "غير متاح";
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "غير متاح";
  }

  return new Intl.DateTimeFormat("ar", {
    dateStyle: "medium",
  }).format(date);
}

export default function HospitalStaffPage() {
  const router = useRouter();

  const [staff, setStaff] = useState<StaffMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");

  const loadStaff = useCallback(
    async (isRefresh = false) => {
      const token = getDashboardToken();
      const user = getDashboardUser();

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
        const response = await api<StaffResponse>("/hospital/staff", {
          token,
        });

        setStaff(response.data);
      } catch (err) {
        const nextError =
          err instanceof Error ? err.message : "تعذر تحميل موظفي المستشفى.";

        setError(nextError);

        if (
          nextError.includes("Unauthenticated") ||
          nextError.includes("غير مصادق") ||
          nextError.includes("Unauthorized")
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
    void loadStaff();
  }, [loadStaff]);

  async function updateStaff(
    member: StaffMember,
    updates: Partial<Pick<StaffMember, "role" | "is_active">>
  ) {
    const token = getDashboardToken();

    if (!token) {
      clearDashboardSession();
      window.location.replace("/admin/login");
      return;
    }

    setUpdatingId(member.id);
    setError("");
    setMessage("");

    try {
      const response = await api<UpdateStaffResponse>(
        `/hospital/staff/${encodeURIComponent(member.id)}`,
        {
          method: "PATCH",
          token,
          body: JSON.stringify(updates),
        }
      );

      setStaff((current) =>
        current.map((item) =>
          item.id === member.id ? response.data : item
        )
      );

      setMessage(response.message || "تم تحديث بيانات الموظف بنجاح.");
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "تعذر تحديث بيانات الموظف."
      );
    } finally {
      setUpdatingId(null);
    }
  }

  function handleRoleChange(member: StaffMember, role: string) {
    if (role === member.role) {
      return;
    }

    void updateStaff(member, { role });
  }

  function handleStatusChange(member: StaffMember) {
    const action = member.is_active ? "تعطيل" : "تفعيل";

    const confirmed = window.confirm(
      `هل تريد ${action} حساب الموظف: ${member.name || "هذا الموظف"}؟`
    );

    if (!confirmed) {
      return;
    }

    void updateStaff(member, {
      is_active: !member.is_active,
    });
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
              إدارة موظفي المستشفى
            </h1>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <button
              type="button"
              onClick={() => router.push("/hospital/staff/new")}
              className="rounded-xl bg-cyan-700 px-4 py-2 text-sm font-bold text-white transition hover:bg-cyan-800"
            >
              إضافة موظف
            </button>

            <button
              type="button"
              onClick={() => void loadStaff(true)}
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
            إدارة حسابات الموظفين
          </p>

          <h2 className="mt-3 text-2xl font-bold sm:text-3xl">
            الطاقم العامل في المستشفى
          </h2>

          <p className="mt-3 max-w-3xl text-sm leading-7 text-slate-300">
            أضف موظفين جدد، حدّد دور كل موظف، أو عطّل الحسابات التي لم تعد
            بحاجة إلى الوصول للنظام.
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

        {message && (
          <div
            role="status"
            className="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50 px-5 py-4 text-sm font-medium text-emerald-700"
          >
            {message}
          </div>
        )}

        <section className="mt-7 overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between border-b border-slate-100 px-5 py-5 sm:px-6">
            <div>
              <h2 className="text-lg font-bold text-slate-900">
                قائمة الموظفين
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                {loading
                  ? "جارٍ تحميل البيانات..."
                  : `إجمالي الموظفين: ${staff.length.toLocaleString("ar")}`}
              </p>
            </div>
          </div>

          {loading ? (
            <div className="space-y-4 p-5 sm:p-6">
              <SkeletonRow />
              <SkeletonRow />
              <SkeletonRow />
            </div>
          ) : staff.length === 0 ? (
            <div className="p-10 text-center">
              <p className="font-bold text-slate-700">
                لا يوجد موظفون مسجلون حاليًا.
              </p>

              <button
                type="button"
                onClick={() => router.push("/hospital/staff/new")}
                className="mt-4 rounded-xl bg-cyan-700 px-4 py-2 text-sm font-bold text-white transition hover:bg-cyan-800"
              >
                إضافة أول موظف
              </button>
            </div>
          ) : (
            <div className="divide-y divide-slate-100">
              {staff.map((member) => {
                const isUpdating = updatingId === member.id;

                return (
                  <article
                    key={member.id}
                    className="flex flex-col gap-5 px-5 py-5 sm:px-6 lg:flex-row lg:items-center lg:justify-between"
                  >
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <h3 className="font-bold text-slate-900">
                          {member.name || "موظف غير معروف"}
                        </h3>

                        <span
                          className={`rounded-full px-2.5 py-1 text-xs font-bold ${
                            member.is_active
                              ? "bg-emerald-50 text-emerald-700"
                              : "bg-slate-100 text-slate-600"
                          }`}
                        >
                          {member.is_active ? "نشط" : "معطّل"}
                        </span>
                      </div>

                      <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-sm text-slate-500">
                        {member.email && (
                          <span dir="ltr">{member.email}</span>
                        )}

                        {member.phone && (
                          <span dir="ltr">{member.phone}</span>
                        )}

                        {member.employee_code && (
                          <span dir="ltr">
                            كود الموظف: {member.employee_code}
                          </span>
                        )}

                        <span>
                          تاريخ الانضمام: {formatDate(member.joined_at)}
                        </span>
                      </div>
                    </div>

                    <div className="flex flex-wrap items-center gap-3">
                      <label className="text-sm font-bold text-slate-700">
                        <span className="sr-only">دور الموظف</span>

                        <select
                          value={member.role}
                          disabled={isUpdating}
                          onChange={(event) =>
                            handleRoleChange(member, event.target.value)
                          }
                          className="rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm font-semibold text-slate-700 outline-none transition focus:border-cyan-500 focus:ring-2 focus:ring-cyan-100 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                          {ROLE_OPTIONS.map((option) => (
                            <option key={option.value} value={option.value}>
                              {option.label}
                            </option>
                          ))}
                        </select>
                      </label>

                      <button
                        type="button"
                        disabled={isUpdating}
                        onClick={() => handleStatusChange(member)}
                        className={`rounded-xl px-4 py-2 text-sm font-bold transition disabled:cursor-not-allowed disabled:opacity-60 ${
                          member.is_active
                            ? "border border-red-200 text-red-700 hover:bg-red-50"
                            : "border border-emerald-200 text-emerald-700 hover:bg-emerald-50"
                        }`}
                      >
                        {isUpdating
                          ? "جارٍ الحفظ..."
                          : member.is_active
                            ? "تعطيل الحساب"
                            : "تفعيل الحساب"}
                      </button>
                    </div>
                  </article>
                );
              })}
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
      <div className="h-4 w-44 rounded bg-slate-200" />
      <div className="mt-3 h-3 w-72 max-w-full rounded bg-slate-200" />
    </div>
  );
}