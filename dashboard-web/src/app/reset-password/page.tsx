"use client";

import Image from "next/image";
import Link from "next/link";
import { FormEvent, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";

const API_URL = process.env.NEXT_PUBLIC_API_URL;

export default function ResetPasswordPage() {
  const searchParams = useSearchParams();

  const token = useMemo(() => searchParams.get("token") ?? "", [searchParams]);
  const email = useMemo(() => searchParams.get("email") ?? "", [searchParams]);

  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setMessage("");
    setError("");

    if (!token || !email) {
      setError("رابط إعادة التعيين غير صالح أو ناقص البيانات.");
      return;
    }

    if (password !== passwordConfirmation) {
      setError("كلمتا المرور غير متطابقتين.");
      return;
    }

    setIsLoading(true);

    try {
      const response = await fetch(`${API_URL}/auth/reset-password`, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          token,
          email,
          password,
          password_confirmation: passwordConfirmation,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        setError(
          data.message ||
            "تعذر تغيير كلمة المرور. ربما انتهت صلاحية الرابط."
        );
        return;
      }

      setMessage(
        data.message ||
          "تم تغيير كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن."
      );
      setIsSuccess(true);
      setPassword("");
      setPasswordConfirmation("");
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
            {isSuccess ? (
              <div className="text-center">
                <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-emerald-100 text-2xl text-emerald-700">
                  ✓
                </div>

                <h2 className="mt-5 text-xl font-bold text-slate-900">
                  تم تغيير كلمة المرور
                </h2>

                <p className="mt-3 text-sm leading-7 text-slate-600">
                  أصبحت كلمة المرور الجديدة فعالة. يمكنك الآن تسجيل الدخول إلى
                  حسابك.
                </p>
              </div>
            ) : (
              <>
                <h2 className="text-xl font-bold text-slate-900">
                  تعيين كلمة مرور جديدة
                </h2>

                <p className="mt-3 text-sm leading-7 text-slate-600">
                  اختر كلمة مرور قوية لحماية حسابك. يجب أن تحتوي على 8 أحرف
                  على الأقل، وحروف وأرقام.
                </p>

                {error && (
                  <div
                    role="alert"
                    className="mt-5 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm leading-6 text-red-700"
                  >
                    {error}
                  </div>
                )}

                {message && (
                  <div
                    role="status"
                    className="mt-5 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm leading-6 text-emerald-800"
                  >
                    {message}
                  </div>
                )}

                <form onSubmit={handleSubmit} className="mt-7 space-y-5">
                  <div>
                    <label
                      htmlFor="password"
                      className="mb-2 block text-sm font-semibold text-slate-700"
                    >
                      كلمة المرور الجديدة
                    </label>

                    <input
                      id="password"
                      name="password"
                      type="password"
                      value={password}
                      onChange={(event) => setPassword(event.target.value)}
                      placeholder="اكتب كلمة مرور قوية"
                      autoComplete="new-password"
                      minLength={8}
                      required
                      disabled={isLoading}
                      className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition placeholder:text-right placeholder:text-slate-400 focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                      dir="ltr"
                    />
                  </div>

                  <div>
                    <label
                      htmlFor="password_confirmation"
                      className="mb-2 block text-sm font-semibold text-slate-700"
                    >
                      تأكيد كلمة المرور الجديدة
                    </label>

                    <input
                      id="password_confirmation"
                      name="password_confirmation"
                      type="password"
                      value={passwordConfirmation}
                      onChange={(event) =>
                        setPasswordConfirmation(event.target.value)
                      }
                      placeholder="أعد كتابة كلمة المرور"
                      autoComplete="new-password"
                      minLength={8}
                      required
                      disabled={isLoading}
                      className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition placeholder:text-right placeholder:text-slate-400 focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                      dir="ltr"
                    />
                  </div>

                  <button
                    type="submit"
                    disabled={isLoading || !token || !email}
                    className="w-full rounded-xl bg-cyan-700 px-4 py-3.5 text-sm font-bold text-white transition hover:bg-cyan-800 focus:outline-none focus:ring-4 focus:ring-cyan-200 disabled:cursor-not-allowed disabled:bg-cyan-400"
                  >
                    {isLoading
                      ? "جارٍ حفظ كلمة المرور..."
                      : "حفظ كلمة المرور الجديدة"}
                  </button>
                </form>

                <div className="mt-7 border-t border-slate-100 pt-6 text-center">
                  <Link
                    href="/forgot-password"
                    className="text-sm font-semibold text-cyan-700 transition hover:text-cyan-900"
                  >
                    طلب رابط جديد
                  </Link>
                </div>
              </>
            )}
          </div>
        </section>
      </div>
    </main>
  );
}