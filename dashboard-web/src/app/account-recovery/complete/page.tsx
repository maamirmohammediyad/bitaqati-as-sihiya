'use client';

import { FormEvent, useMemo, useState } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';

const API_URL = process.env.NEXT_PUBLIC_API_URL;

export default function CompleteAccountRecoveryPage() {
  const searchParams = useSearchParams();
  const token = useMemo(() => searchParams.get('token') ?? '', [searchParams]);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setMessage('');
    setError('');

    if (!token) {
      setError('رابط الاستعادة غير صالح أو لا يحتوي على رمز التحقق.');
      return;
    }

    if (password !== passwordConfirmation) {
      setError('كلمتا المرور غير متطابقتين.');
      return;
    }

    setIsLoading(true);

    try {
      const response = await fetch(`${API_URL}/auth/account-recovery/complete`, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          token,
          email: email.trim() || null,
          password,
          password_confirmation: passwordConfirmation,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        setError(data.message ?? 'تعذر إكمال استعادة الحساب.');
        return;
      }

      setMessage(data.message ?? 'تم تعيين كلمة المرور بنجاح.');
      setIsSuccess(true);
      setEmail('');
      setPassword('');
      setPasswordConfirmation('');
    } catch {
      setError('تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مجددًا.');
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
          <header className="bg-gradient-to-l from-cyan-700 to-sky-600 px-8 py-9 text-center text-white">
            <h1 className="text-2xl font-bold">استعادة الحساب</h1>
            <p className="mt-2 text-sm text-cyan-50">
              أنشئ كلمة مرور جديدة لحسابك
            </p>
          </header>

          <div className="p-7 sm:p-8">
            {isSuccess ? (
              <div className="text-center">
                <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-emerald-100 text-2xl text-emerald-700">
                  ✓
                </div>

                <h2 className="mt-5 text-xl font-bold text-slate-900">
                  اكتملت استعادة الحساب
                </h2>

                <p className="mt-3 text-sm leading-7 text-slate-600">
                  {message}
                </p>

                <Link
                  href="/login"
                  className="mt-7 inline-flex w-full justify-center rounded-xl bg-cyan-700 px-4 py-3.5 text-sm font-bold text-white transition hover:bg-cyan-800"
                >
                  الانتقال إلى تسجيل الدخول
                </Link>
              </div>
            ) : (
              <>
                <h2 className="text-xl font-bold text-slate-900">
                  تعيين كلمة مرور جديدة
                </h2>

                <p className="mt-3 text-sm leading-7 text-slate-600">
                  اختر كلمة مرور قوية لا تقل عن 8 أحرف، وتحتوي على حروف وأرقام.
                </p>

                <p className="mt-2 text-xs leading-6 text-slate-500">
                  البريد الإلكتروني مطلوب فقط إذا لم يكن مسجلاً سابقًا في حسابك.
                </p>

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
                      <span className="mr-1 text-xs font-normal text-slate-500">
                        (مطلوب عند عدم وجود بريد بالحساب)
                      </span>
                    </label>

                    <input
                      id="email"
                      type="email"
                      value={email}
                      onChange={(event) => setEmail(event.target.value)}
                      placeholder="name@example.com"
                      autoComplete="email"
                      disabled={isLoading}
                      dir="ltr"
                      className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                    />
                  </div>

                  <div>
                    <label
                      htmlFor="password"
                      className="mb-2 block text-sm font-semibold text-slate-700"
                    >
                      كلمة المرور الجديدة
                    </label>

                    <input
                      id="password"
                      type="password"
                      value={password}
                      onChange={(event) => setPassword(event.target.value)}
                      minLength={8}
                      autoComplete="new-password"
                      required
                      disabled={isLoading}
                      className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                      dir="ltr"
                    />
                  </div>

                  <div>
                    <label
                      htmlFor="passwordConfirmation"
                      className="mb-2 block text-sm font-semibold text-slate-700"
                    >
                      تأكيد كلمة المرور
                    </label>

                    <input
                      id="passwordConfirmation"
                      type="password"
                      value={passwordConfirmation}
                      onChange={(event) =>
                        setPasswordConfirmation(event.target.value)
                      }
                      minLength={8}
                      autoComplete="new-password"
                      required
                      disabled={isLoading}
                      className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition focus:border-cyan-600 focus:ring-4 focus:ring-cyan-100 disabled:cursor-not-allowed disabled:bg-slate-100"
                      dir="ltr"
                    />
                  </div>

                  <button
                    type="submit"
                    disabled={isLoading || !token}
                    className="w-full rounded-xl bg-cyan-700 px-4 py-3.5 text-sm font-bold text-white transition hover:bg-cyan-800 focus:outline-none focus:ring-4 focus:ring-cyan-200 disabled:cursor-not-allowed disabled:bg-cyan-400"
                  >
                    {isLoading
                      ? 'جارٍ حفظ كلمة المرور...'
                      : 'حفظ كلمة المرور'}
                  </button>
                </form>
              </>
            )}
          </div>
        </section>
      </div>
    </main>
  );
}