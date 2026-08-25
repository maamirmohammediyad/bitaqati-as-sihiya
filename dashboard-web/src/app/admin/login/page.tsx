"use client";

import Image from "next/image";
import Link from "next/link";
import { FormEvent, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import {
  getAdminToken,
  getAdminUser,
  saveAdminSession,
} from "@/lib/auth";

type LoginResponse = {
  data: {
    token: string;
    user: {
      id: string;
      name: string;
      email: string | null;
      role: string;
    };
  };
};

function looksLikeEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

export default function AdminLoginPage() {
  const router = useRouter();

  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    const token = getAdminToken();
    const user = getAdminUser();

    if (!token || !user) {
      return;
    }

    if (user.role === "super_admin") {
      router.replace("/admin/dashboard");
      return;
    }

    if (user.role === "health_worker") {
      router.replace("/hospital/dashboard");
      return;
    }

    router.replace("/admin/login");
  }, [router]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const cleanIdentifier = identifier.trim();

    if (!cleanIdentifier || !password) {
      setError("أدخل كود الموظف وكلمة المرور.");
      return;
    }

    setError("");
    setIsLoading(true);

    try {
      const isEmailLogin = looksLikeEmail(cleanIdentifier);

      const body = isEmailLogin
  ? {
      role: "super_admin",
      email: cleanIdentifier,
      password,
    }
  : {
      role: "health_worker",
      employee_code: cleanIdentifier,
      password,
    };

      const response = await api<LoginResponse>("/auth/login", {
        method: "POST",
        body: JSON.stringify(body),
      });

      const user = response.data.user;

      saveAdminSession(response.data.token, user);

      if (user.role === "super_admin") {
        router.replace("/admin/dashboard");
        return;
      }

      if (user.role === "health_worker") {
        router.replace("/hospital/dashboard");
        return;
      }

      setError("هذا الحساب غير مخول للدخول إلى هذه البوابة.");
    } catch (err) {
      const genericError = "تعذر تسجيل الدخول. تحقق من كود الموظف وكلمة المرور.";

      setError(
        err instanceof Error && err.message
          ? err.message
          : genericError
      );
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <main dir="rtl" className="min-h-screen bg-[#F7FBFF] text-right text-[#152235]">
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex h-[76px] max-w-7xl items-center justify-between px-5 lg:px-8">
          <Link href="/" className="flex items-center gap-3">
            <Image
              src="/logo.png"
              alt="صحّتك تيك — DZ HEALTH TECH"
              width={44}
              height={44}
              className="h-11 w-11 rounded-xl object-contain"
              priority
            />

            <div className="leading-tight">
              <p className="text-base font-extrabold text-[#07182A]">
                صحّتك تيك
              </p>
              <p className="mt-0.5 text-[10px] font-bold tracking-[0.16em] text-slate-500">
                DZ HEALTH TECH
              </p>
            </div>
          </Link>

          <Link
            href="/"
            className="rounded-lg px-3 py-2 text-sm font-bold text-slate-600 transition hover:bg-slate-100 hover:text-sky-700"
          >
            العودة إلى الرئيسية
          </Link>
        </div>
      </header>

      <div className="mx-auto grid min-h-[calc(100vh-76px)] max-w-7xl items-center gap-10 px-5 py-10 lg:grid-cols-[0.95fr_1.05fr] lg:px-8 lg:py-16">
        <section className="order-2 max-w-lg lg:order-1">
          <span className="inline-flex items-center gap-2 rounded-full border border-sky-200 bg-white px-4 py-2 text-xs font-bold text-sky-700 shadow-sm">
            <span className="h-2 w-2 rounded-full bg-sky-500" />
            بوابة آمنة للمؤسسات الصحية
          </span>

          <h1 className="mt-6 text-4xl font-black leading-tight text-[#07182A] sm:text-5xl">
            إدارة منظّمة،
            <br />
            <span className="text-sky-600">وصول واضح وآمن.</span>
          </h1>

          <p className="mt-5 max-w-md text-base leading-8 text-slate-600">
            سجّل الدخول إلى مساحة مؤسستك لإدارة الموظفين، متابعة المرضى،
            والوصول إلى المعلومات حسب الصلاحيات الممنوحة لك.
          </p>

          <div className="mt-9 space-y-4">
            <FeatureItem text="وصول مخصص لكل مؤسسة صحية" />
            <FeatureItem text="صلاحيات منظمة حسب دور الموظف" />
            <FeatureItem text="بيانات صحية في مساحة عمل موحدة" />
          </div>

          <div className="mt-10 rounded-2xl border border-sky-100 bg-sky-50 p-5">
            <p className="text-sm font-extrabold text-[#07182A]">
              لا تملك كود الموظف؟
            </p>

            <p className="mt-2 text-sm leading-7 text-slate-600">
              تواصل مع مدير مؤسستك للحصول على بيانات الدخول، أو تواصل معنا
              إذا كنت ترغب في تسجيل مؤسسة صحية جديدة.
            </p>

            <a
              href="https://wa.me/213542916461?text=%D8%A7%D9%84%D8%B3%D9%84%D8%A7%D9%85%20%D8%B9%D9%84%D9%8A%D9%83%D9%85%D8%8C%20%D9%84%D8%AF%D9%8A%20%D8%A7%D8%B3%D8%AA%D9%81%D8%B3%D8%A7%D8%B1%20%D8%A8%D8%AE%D8%B5%D9%88%D8%B5%20%D8%A8%D9%8A%D8%A7%D9%86%D8%A7%D8%AA%20%D8%A7%D9%84%D8%AF%D8%AE%D9%88%D9%84%20%D8%A5%D9%84%D9%89%20%D9%85%D9%86%D8%B5%D8%A9%20%D8%B5%D8%AD%D9%91%D8%AA%D9%83%20%D8%AA%D9%8A%D9%83."
              target="_blank"
              rel="noreferrer"
              className="mt-4 inline-flex text-sm font-bold text-sky-700 transition hover:text-sky-900"
            >
              تواصل عبر واتساب ←
            </a>
          </div>
        </section>

        <section className="order-1 mx-auto w-full max-w-md lg:order-2">
          <div className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-xl shadow-slate-200/60">
            <div className="border-b border-slate-100 px-7 pb-6 pt-7 sm:px-8 sm:pt-8">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-sky-50">
                <span className="text-xl font-black text-sky-700">⌁</span>
              </div>

              <h2 className="mt-5 text-2xl font-black text-[#07182A]">
                تسجيل الدخول
              </h2>

              <p className="mt-2 text-sm leading-7 text-slate-600">
                أدخل كود الموظف وكلمة المرور للوصول إلى حساب المؤسسة.
              </p>
            </div>

            <div className="p-7 sm:p-8">
              {error && (
                <div
                  role="alert"
                  className="mb-5 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm leading-6 text-red-700"
                >
                  {error}
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-5">
                <div>
                  <label
                    htmlFor="identifier"
                    className="mb-2 block text-sm font-bold text-slate-700"
                  >
                    كود الموظف
                  </label>

                  <input
                    id="identifier"
                    name="identifier"
                    type="text"
                    value={identifier}
                    onChange={(event) => setIdentifier(event.target.value)}
                    placeholder="مثال: HSP-ADM-001"
                    autoComplete="username"
                    required
                    disabled={isLoading}
                    dir="ltr"
                    className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3.5 text-left text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-sky-600 focus:ring-4 focus:ring-sky-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                  />

                  <p className="mt-2 text-xs leading-5 text-slate-500">
                    استخدم الكود الذي منحته لك إدارة المؤسسة.
                  </p>
                </div>

                <div>
                  <div className="mb-2 flex items-center justify-between gap-3">
                    <label
                      htmlFor="password"
                      className="text-sm font-bold text-slate-700"
                    >
                      كلمة المرور
                    </label>

                    <Link
                      href="/forgot-password"
                      className="text-xs font-bold text-sky-700 transition hover:text-sky-900"
                    >
                      نسيت كلمة المرور؟
                    </Link>
                  </div>

                  <input
                    id="password"
                    name="password"
                    type="password"
                    value={password}
                    onChange={(event) => setPassword(event.target.value)}
                    placeholder="••••••••"
                    autoComplete="current-password"
                    required
                    disabled={isLoading}
                    dir="ltr"
                    className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3.5 text-left text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-sky-600 focus:ring-4 focus:ring-sky-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                  />
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full rounded-xl bg-sky-600 px-4 py-3.5 text-sm font-bold text-white transition hover:bg-sky-700 focus:outline-none focus:ring-4 focus:ring-sky-200 disabled:cursor-not-allowed disabled:bg-sky-400"
                >
                  {isLoading ? "جارٍ التحقق..." : "تسجيل الدخول"}
                </button>
              </form>
            </div>

            <div className="border-t border-slate-100 bg-slate-50 px-7 py-4 text-center text-xs leading-6 text-slate-500">
              دخول مخصص للمستخدمين المخولين داخل المؤسسات الصحية.
            </div>
          </div>
        </section>
      </div>

      <footer className="border-t border-slate-200 bg-white">
        <div className="mx-auto flex max-w-7xl flex-col gap-2 px-5 py-5 text-center text-xs text-slate-500 sm:flex-row sm:items-center sm:justify-between sm:text-start lg:px-8">
          <p>© 2026 DZ HEALTH TECH. جميع الحقوق محفوظة.</p>

          <div className="flex items-center justify-center gap-4 sm:justify-end">
            <Link href="/terms" className="transition hover:text-sky-700">
              الشروط والبنود
            </Link>

            <Link href="/terms#privacy" className="transition hover:text-sky-700">
              سياسة الخصوصية
            </Link>
          </div>
        </div>
      </footer>
    </main>
  );
}

function FeatureItem({ text }: { text: string }) {
  return (
    <div className="flex items-center gap-3 text-sm font-semibold text-slate-700">
      <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-sky-100 text-xs font-black text-sky-700">
        ✓
      </span>
      {text}
    </div>
  );
}