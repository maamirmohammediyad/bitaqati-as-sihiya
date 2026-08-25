"use client";

import Image from "next/image";
import Link from "next/link";
import { FormEvent, useState } from "react";

const API_URL = process.env.NEXT_PUBLIC_API_URL;

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setMessage("");
    setError("");
    setIsLoading(true);

    try {
      const response = await fetch(`${API_URL}/auth/forgot-password`, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email }),
      });

      const data = await response.json();

      if (!response.ok) {
        setError(data.message || "تعذر إرسال رابط إعادة التعيين.");
        return;
      }

      setMessage(
        data.message ||
          "إذا كان البريد مسجلًا، فسيصلك رابط إعادة تعيين كلمة المرور."
      );
    } catch {
      setError("تعذر الاتصال بالخادم. تأكد من أن Laravel يعمل.");
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <main
      dir="rtl"
      className="min-h-screen bg-slate-50 px-4 py-8 text-right sm:px-6 lg:px-8"
    >
      <div className="mx-auto flex min-h-[calc(100vh-4rem)] max-w-md items-center">
        <section className="w-full overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-xl shadow-slate-200/60">
          <div className="bg-gradient-to-l from-cyan-700 to-sky-600 px-8 py-9 text-center">
            <div className="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-2xl bg-white/15 p-2 ring-1 ring-white/25">
              <Image
                src="/logo.png"
                alt="شعار بطاقتي الصحية"
                width={64}
                height={64}
                className="h-16 w-16 object-contain"
                priority
              />
            </div>

            <h1 className="text-2xl font-bold text-white">
              بطاقتي الصحية
            </h1>

            <p className="mt-2 text-sm text-cyan-50">
              إدارة صحية أكثر أمانًا وسهولة
            </p>
          </div>

          <div className="p-7 sm:p-8">
            <h2 className="text-xl font-bold text-slate-900">
              نسيت كلمة المرور؟
            </h2>

            <p className="mt-3 text-sm leading-7 text-slate-600">
              أدخل بريدك الإلكتروني وسنرسل لك رابطًا آمنًا لتعيين كلمة مرور
              جديدة.
            </p>

            {message && (
              <div
                role="status"
                className="mt-5 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm leading-6 text-emerald-800"
              >
                {message}
              </div>
            )}

            {error && (
              <div
                role="alert"
                className="mt-5 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm leading-6 text-red-700"
              >
                {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="mt-7 space-y-5">
              <div>
                <label
                  htmlFor="email"
                  className="mb-2 block text-sm font-semibold text-slate-700"
                >
                  البريد الإلكتروني
                </label>

                <input
                  id="email"
                  name="email"
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="example@gmail.com"
                  autoComplete="email"
                  required
                  disabled={isLoading}
                  className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                  dir="ltr"
                />
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full rounded-xl bg-cyan-700 px-4 py-3.5 text-sm font-bold text-white transition hover:bg-cyan-800 focus:outline-none focus:ring-4 focus:ring-cyan-200 disabled:cursor-not-allowed disabled:bg-cyan-400"
              >
                {isLoading
                  ? "جارٍ إرسال الرابط..."
                  : "إرسال رابط إعادة التعيين"}
              </button>
            </form>

            <div className="mt-7 border-t border-slate-100 pt-6 text-center">
              <Link
                href="admin/login"
                className="text-sm font-semibold text-cyan-700 transition hover:text-cyan-900"
              >
                العودة إلى تسجيل الدخول
              </Link>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}