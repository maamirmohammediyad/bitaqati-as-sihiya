"use client";

import { FormEvent, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { getAdminToken } from "@/lib/auth";

type AlertState =
  | {
      type: "success" | "error";
      message: string;
    }
  | null;

export default function HospitalPasswordSettingsPage() {
  const router = useRouter();

  const [currentPassword, setCurrentPassword] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [alert, setAlert] = useState<AlertState>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setAlert(null);

    if (!currentPassword || !password || !passwordConfirmation) {
      setAlert({
        type: "error",
        message: "يرجى تعبئة جميع حقول كلمة المرور.",
      });
      return;
    }

    if (password.length < 8) {
      setAlert({
        type: "error",
        message: "يجب أن تتكون كلمة المرور الجديدة من 8 أحرف على الأقل.",
      });
      return;
    }

    if (password !== passwordConfirmation) {
      setAlert({
        type: "error",
        message: "كلمتا المرور الجديدتان غير متطابقتين.",
      });
      return;
    }

    const token = getAdminToken();

    if (!token) {
      setAlert({
        type: "error",
        message: "انتهت جلسة تسجيل الدخول. يرجى تسجيل الدخول مجددًا.",
      });
      return;
    }

    try {
      setIsSubmitting(true);

      const response = await api<{
  message?: string;
}>("/auth/password", {
  method: "PUT",
  token,
  body: JSON.stringify({
    current_password: currentPassword,
    password,
    password_confirmation: passwordConfirmation,
  }),
});

      setAlert({
        type: "success",
        message: response.message ?? "تم تغيير كلمة المرور بنجاح.",
      });

      setCurrentPassword("");
      setPassword("");
      setPasswordConfirmation("");
    } catch (error) {
      setAlert({
        type: "error",
        message:
          error instanceof Error
            ? error.message
            : "تعذر تغيير كلمة المرور. حاول مرة أخرى.",
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main
      dir="rtl"
      className="min-h-screen bg-slate-50 px-4 py-8 text-right sm:px-6 lg:px-8"
    >
      <div className="mx-auto max-w-2xl">
        <div className="mb-6 flex items-center justify-between gap-4">
          <div>
            <p className="text-sm font-bold text-cyan-700">إعدادات الحساب</p>
            <h1 className="mt-1 text-2xl font-black text-slate-900">
              تغيير كلمة المرور
            </h1>
            <p className="mt-2 text-sm leading-6 text-slate-500">
              استخدم كلمة مرور قوية وفريدة لحماية حساب المستشفى.
            </p>
          </div>

          <button
            type="button"
            onClick={() => router.back()}
            className="rounded-xl border border-slate-300 bg-white px-4 py-2.5 text-sm font-bold text-slate-700 transition hover:bg-slate-50"
          >
            رجوع
          </button>
        </div>

        <section className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200 sm:p-7">
          {alert ? (
            <div
              className={[
                "mb-6 flex items-start justify-between gap-4 rounded-xl border px-4 py-3 text-sm",
                alert.type === "success"
                  ? "border-emerald-200 bg-emerald-50 text-emerald-800"
                  : "border-red-200 bg-red-50 text-red-700",
              ].join(" ")}
              role="alert"
            >
              <span>{alert.message}</span>

              <button
                type="button"
                onClick={() => setAlert(null)}
                className="font-bold opacity-70 transition hover:opacity-100"
                aria-label="إغلاق الرسالة"
              >
                ×
              </button>
            </div>
          ) : null}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label
                htmlFor="current_password"
                className="mb-2 block text-sm font-bold text-slate-800"
              >
                كلمة المرور الحالية
              </label>

              <input
                id="current_password"
                name="current_password"
                type="password"
                autoComplete="current-password"
                value={currentPassword}
                onChange={(event) => setCurrentPassword(event.target.value)}
                disabled={isSubmitting}
                className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10 disabled:cursor-not-allowed disabled:bg-slate-100"
                placeholder="أدخل كلمة المرور الحالية"
              />
            </div>

            <div>
              <label
                htmlFor="password"
                className="mb-2 block text-sm font-bold text-slate-800"
              >
                كلمة المرور الجديدة
              </label>

              <input
                id="password"
                name="password"
                type="password"
                autoComplete="new-password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                disabled={isSubmitting}
                minLength={8}
                className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10 disabled:cursor-not-allowed disabled:bg-slate-100"
                placeholder="8 أحرف على الأقل"
              />

              <p className="mt-2 text-xs leading-5 text-slate-500">
                اختر كلمة مرور لا تقل عن 8 أحرف، وتجنب استخدام كلمة مرور سهلة
                التخمين.
              </p>
            </div>

            <div>
              <label
                htmlFor="password_confirmation"
                className="mb-2 block text-sm font-bold text-slate-800"
              >
                تأكيد كلمة المرور الجديدة
              </label>

              <input
                id="password_confirmation"
                name="password_confirmation"
                type="password"
                autoComplete="new-password"
                value={passwordConfirmation}
                onChange={(event) =>
                  setPasswordConfirmation(event.target.value)
                }
                disabled={isSubmitting}
                minLength={8}
                className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10 disabled:cursor-not-allowed disabled:bg-slate-100"
                placeholder="أعد إدخال كلمة المرور الجديدة"
              />
            </div>

            <div className="flex flex-col-reverse gap-3 border-t border-slate-100 pt-5 sm:flex-row sm:items-center sm:justify-between">
              <Link
                href="/hospital/dashboard"
                className="rounded-xl px-4 py-3 text-center text-sm font-bold text-slate-600 transition hover:bg-slate-100"
              >
                إلغاء
              </Link>

              <button
                type="submit"
                disabled={isSubmitting}
                className="rounded-xl bg-cyan-600 px-6 py-3 text-sm font-bold text-white transition hover:bg-cyan-700 disabled:cursor-not-allowed disabled:opacity-60"
              >
                {isSubmitting ? "جارٍ حفظ كلمة المرور..." : "حفظ كلمة المرور"}
              </button>
            </div>
          </form>
        </section>
      </div>
    </main>
  );
}