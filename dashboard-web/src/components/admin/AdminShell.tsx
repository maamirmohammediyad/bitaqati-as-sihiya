"use client";
import { api } from "@/lib/api";
import Link from "next/link";
import { ReactNode, useEffect, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import {
  clearAdminSession,
  getAdminToken,
  getAdminUser,
  type AdminUser,
} from "@/lib/auth";

type AdminShellProps = {
  title: string;
  description?: string;
  children: ReactNode;
};

const navigation = [
  { href: "/admin/dashboard", label: "الرئيسية", icon: "▦" },
  { href: "/admin/hospitals", label: "المستشفيات", icon: "⌂" },
  { href: "/admin/users", label: "المستخدمون", icon: "♙" },
  { href: "/admin/emergencies", label: "بلاغات الطوارئ", icon: "⚠" },
  { href: "/admin/account-recovery-requests", label: "طلبات الاستعادة", icon: "↻",},
  { href: "/admin/verification-requests", label: "طلبات التوثيق", icon: "✓", },
];

export default function AdminShell({
  title,
  description,
  children,
}: AdminShellProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [admin, setAdmin] = useState<AdminUser | null>(null);
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  useEffect(() => {
    const token = getAdminToken();
    const currentAdmin = getAdminUser();

    if (!token || !currentAdmin || currentAdmin.role !== "super_admin") {
      router.replace("/admin/login");
      return;
    }

    setAdmin(currentAdmin);
  }, [router]);

  async function logout() {
  if (isLoggingOut) {
    return;
  }

  const token = getAdminToken();

  setIsLoggingOut(true);

  try {
    if (token) {
      await api<{ message: string }>("/auth/logout", {
        method: "POST",
        token,
      });
    }
  } catch {
    // إذا انتهت الجلسة أو فشل الاتصال، نمسح الجلسة محليًا على أي حال.
  } finally {
    clearAdminSession();
    setAdmin(null);

    router.replace("/admin/login");
    router.refresh();
  }
}

  if (!admin) {
    return (
      <main
        dir="rtl"
        className="grid min-h-screen place-items-center bg-slate-950 text-sm text-slate-300"
      >
        جارٍ التحقق من صلاحيات الدخول...
      </main>
    );
  }

  return (
    <main dir="rtl" className="min-h-screen bg-slate-100 text-right">
      <div className="min-h-screen lg:grid lg:grid-cols-[260px_1fr]">
        <aside className="bg-slate-950 px-4 py-5 text-white lg:min-h-screen">
          <div className="flex items-center justify-between px-3 lg:block">
            <div>
              <p className="text-xs font-bold tracking-[0.16em] text-cyan-300">
                BITAQATI AS-SIHIYA
              </p>
              <h1 className="mt-1 text-lg font-bold">الإدارة المركزية</h1>
            </div>

            <span className="rounded-lg bg-cyan-500/15 px-2 py-1 text-xs text-cyan-200 lg:hidden">
              أدمن
            </span>
          </div>

          <nav className="mt-7 grid grid-cols-2 gap-2 lg:block lg:space-y-2">
            {navigation.map((item) => {
              const active = pathname === item.href;

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-semibold transition ${
                    active
                      ? "bg-cyan-600 text-white shadow-lg shadow-cyan-950/40"
                      : "text-slate-300 hover:bg-slate-800 hover:text-white"
                  }`}
                >
                  <span className="text-lg leading-none">{item.icon}</span>
                  {item.label}
                </Link>
              );
            })}
          </nav>

          <div className="mt-6 rounded-2xl border border-slate-800 bg-slate-900 p-4 lg:mt-10">
            <p className="truncate text-sm font-bold text-white">{admin.name}</p>
            <p className="mt-1 truncate text-xs text-slate-400">{admin.email}</p>

            <button
  type="button"
  onClick={logout}
  disabled={isLoggingOut}
  className="mt-4 w-full rounded-xl border border-slate-700 px-3 py-2 text-sm font-semibold text-slate-200 transition hover:bg-slate-800 hover:text-white disabled:cursor-not-allowed disabled:opacity-60"
>
  {isLoggingOut ? "جارٍ تسجيل الخروج..." : "تسجيل الخروج"}
</button>
          </div>
        </aside>

        <section className="min-w-0 p-5 sm:p-8">
          <header className="mb-7">
            <h2 className="text-2xl font-bold text-slate-900">{title}</h2>
            {description && (
              <p className="mt-2 text-sm leading-6 text-slate-500">
                {description}
              </p>
            )}
          </header>

          {children}
        </section>
      </div>
    </main>
  );
}