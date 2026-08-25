"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import AdminShell from "@/components/admin/AdminShell";
import { api } from "@/lib/api";
import { getAdminToken } from "@/lib/auth";

type HospitalResponse = {
  total: number;
};

type PaginatedResponse<T> = {
  data: T[];
  meta: {
    total: number;
  };
};

type User = {
  id: string;
  role: string;
  is_active: boolean;
};

type Emergency = {
  id: string;
  status: "active" | "resolved" | string;
};

export default function AdminDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [stats, setStats] = useState({
    hospitals: 0,
    users: 0,
    activeEmergencies: 0,
    totalEmergencies: 0,
  });

  useEffect(() => {
    async function loadDashboard() {
      const token = getAdminToken();

      if (!token) {
        return;
      }

      try {
        const [hospitals, users, emergencies] = await Promise.all([
          api<HospitalResponse>("/admin/hospitals", { token }),
          api<PaginatedResponse<User>>("/admin/users?per_page=1", { token }),
          api<PaginatedResponse<Emergency>>(
            "/admin/emergency-events?per_page=20",
            { token }
          ),
        ]);

        const activeEmergencies = emergencies.data.filter(
          (event) => event.status === "active"
        ).length;

        setStats({
          hospitals: hospitals.total,
          users: users.meta.total,
          activeEmergencies,
          totalEmergencies: emergencies.meta.total,
        });
      } catch (err) {
        setError(
          err instanceof Error
            ? err.message
            : "تعذر تحميل بيانات لوحة التحكم."
        );
      } finally {
        setLoading(false);
      }
    }

    loadDashboard();
  }, []);

  return (
    <AdminShell
      title="لوحة التحكم"
      description="متابعة عامة للمستشفيات والمستخدمين وبلاغات الطوارئ."
    >
      {error && (
        <div className="mb-6 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700">
          {error}
        </div>
      )}

      <section className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="المستشفيات المسجلة"
          value={stats.hospitals}
          loading={loading}
          tone="blue"
        />
        <StatCard
          label="إجمالي المستخدمين"
          value={stats.users}
          loading={loading}
          tone="violet"
        />
        <StatCard
          label="بلاغات طوارئ نشطة"
          value={stats.activeEmergencies}
          loading={loading}
          tone="red"
        />
        <StatCard
          label="إجمالي البلاغات"
          value={stats.totalEmergencies}
          loading={loading}
          tone="emerald"
        />
      </section>

      <section className="mt-7 grid gap-5 lg:grid-cols-3">
        <QuickLink
          href="/admin/hospitals"
          title="إدارة المستشفيات"
          description="عرض المؤسسات الصحية المسجلة وإضافة مؤسسة جديدة."
        />
        <QuickLink
          href="/admin/users"
          title="إدارة المستخدمين"
          description="البحث والتصفية حسب دور المستخدم وحالة حسابه."
        />
        <QuickLink
          href="/admin/emergencies"
          title="مراقبة الطوارئ"
          description="عرض البلاغات النشطة والمنتهية وآخر تحديثاتها."
        />
      </section>
    </AdminShell>
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
  tone: "blue" | "violet" | "red" | "emerald";
}) {
  const colors = {
    blue: "border-blue-100 bg-blue-50 text-blue-700",
    violet: "border-violet-100 bg-violet-50 text-violet-700",
    red: "border-red-100 bg-red-50 text-red-700",
    emerald: "border-emerald-100 bg-emerald-50 text-emerald-700",
  };

  return (
    <article className={`rounded-2xl border p-5 ${colors[tone]}`}>
      <p className="text-sm font-semibold opacity-80">{label}</p>
      <p className="mt-4 text-4xl font-bold">
        {loading ? "..." : value.toLocaleString("ar")}
      </p>
    </article>
  );
}

function QuickLink({
  href,
  title,
  description,
}: {
  href: string;
  title: string;
  description: string;
}) {
  return (
    <Link
      href={href}
      className="group rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200 transition hover:-translate-y-0.5 hover:shadow-md"
    >
      <h3 className="text-base font-bold text-slate-900 group-hover:text-cyan-700">
        {title}
      </h3>
      <p className="mt-2 text-sm leading-6 text-slate-500">{description}</p>
      <p className="mt-4 text-sm font-bold text-cyan-700">فتح الصفحة ←</p>
    </Link>
  );
}