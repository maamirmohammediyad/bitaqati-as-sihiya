"use client";

import { FormEvent, useEffect, useState } from "react";
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
  role: HospitalStaffRole;
  is_active: boolean;
  joined_at: string | null;
};

type CreateStaffResponse = {
  message: string;
  data: StaffMember;
};

const ROLE_OPTIONS: Array<{
  value: HospitalStaffRole;
  label: string;
  code: string;
  description: string;
}> = [
  {
    value: "receptionist",
    label: "موظف استقبال",
    code: "REC",
    description: "يتعامل مع عمليات الاستقبال والتحقق من QR.",
  },
  {
    value: "doctor",
    label: "طبيب",
    code: "DOC",
    description: "يستطيع الاطلاع على ملفات المرضى بعد التحقق من QR.",
  },
  {
    value: "nurse",
    label: "ممرض / ممرضة",
    code: "NUR",
    description: "عضو من الطاقم التمريضي داخل المستشفى.",
  },
  {
    value: "staff",
    label: "موظف",
    code: "STF",
    description: "موظف عام ضمن طاقم المستشفى.",
  },
  {
    value: "admin",
    label: "مسؤول مستشفى",
    code: "ADM",
    description: "يملك صلاحية إدارة الطاقم وسجل عمليات QR.",
  },
];

function getRandomNumber(min: number, max: number): number {
  const range = max - min + 1;

  if (
    typeof window !== "undefined" &&
    typeof window.crypto !== "undefined" &&
    typeof window.crypto.getRandomValues === "function"
  ) {
    const values = new Uint32Array(1);

    window.crypto.getRandomValues(values);

    return min + (values[0] % range);
  }

  return Math.floor(Math.random() * range) + min;
}

function generateEmployeeCode(role: HospitalStaffRole): string {
  const roleOption = ROLE_OPTIONS.find((item) => item.value === role);
  const roleCode = roleOption?.code ?? "STF";
  const randomNumber = getRandomNumber(1000, 9999);

  return `HOS-${roleCode}-${randomNumber}`;
}

function generateTemporaryPassword(): string {
  const upper = "ABCDEFGHJKLMNPQRSTUVWXYZ";
  const lower = "abcdefghijkmnopqrstuvwxyz";
  const digits = "23456789";
  const symbols = "!@#$%";
  const all = `${upper}${lower}${digits}${symbols}`;

  const randomCharacter = (characters: string) =>
    characters[Math.floor(Math.random() * characters.length)];

  const required = [
    randomCharacter(upper),
    randomCharacter(lower),
    randomCharacter(digits),
    randomCharacter(symbols),
  ];

  const rest = Array.from({ length: 8 }, () => randomCharacter(all));

  return [...required, ...rest]
    .sort(() => Math.random() - 0.5)
    .join("");
}

export default function NewHospitalStaffPage() {
  const router = useRouter();

const [name, setName] = useState("");
const [email, setEmail] = useState("");
const [phone, setPhone] = useState("");
const [role, setRole] = useState<HospitalStaffRole>("receptionist");
const [employeeCode, setEmployeeCode] = useState("");
const [password, setPassword] = useState(generateTemporaryPassword);
const [showPassword, setShowPassword] = useState(false);

const [submitting, setSubmitting] = useState(false);
const [error, setError] = useState("");

useEffect(() => {
  setEmployeeCode(generateEmployeeCode("receptionist"));
}, []);
  const selectedRole = ROLE_OPTIONS.find((item) => item.value === role);

  function handleRoleChange(nextRole: HospitalStaffRole) {
    setRole(nextRole);
    setEmployeeCode(generateEmployeeCode(nextRole));
  }

  function regenerateEmployeeCode() {
    setEmployeeCode(generateEmployeeCode(role));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

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

    setSubmitting(true);
    setError("");

    try {
        console.log({
  password,
  password_confirmation: password,
  isSame: password === password,
});
      const response = await api<CreateStaffResponse>("/hospital/staff", {
        method: "POST",
        token,
       body: JSON.stringify({
  name: name.trim(),
  email: email.trim().toLowerCase(),
  phone: phone.trim() || null,
  employee_code: employeeCode.trim().toUpperCase(),
  role,
  password,
  password_confirmation: password,
}),
      });

      router.replace(
        `/hospital/staff?created=${encodeURIComponent(
          response.data.name || "الموظف"
        )}`
      );
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : "تعذر إضافة موظف المستشفى.";

      setError(message);

      if (
        message.includes("Unauthenticated") ||
        message.includes("غير مصادق") ||
        message.includes("Unauthorized")
      ) {
        clearDashboardSession();
        window.location.replace("/admin/login");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main dir="rtl" className="min-h-screen bg-slate-100 text-right">
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-4xl items-center justify-between gap-4 px-4 py-4 sm:px-6">
          <div>
            <p className="text-xs font-bold tracking-wide text-cyan-700">
              BITAQATI AS-SIHIYA
            </p>

            <h1 className="mt-1 text-lg font-bold text-slate-900">
              إضافة موظف جديد
            </h1>
          </div>

          <button
            type="button"
            onClick={() => router.push("/hospital/staff")}
            disabled={submitting}
            className="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
          >
            العودة للموظفين
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-4xl px-4 py-8 sm:px-6">
        <section className="rounded-3xl bg-slate-900 p-7 text-white shadow-xl sm:p-9">
          <p className="text-sm font-semibold text-cyan-300">
            حساب موظف جديد
          </p>

          <h2 className="mt-3 text-2xl font-bold sm:text-3xl">
            إضافة عضو إلى طاقم المستشفى
          </h2>

          <p className="mt-3 max-w-3xl text-sm leading-7 text-slate-300">
            أدخل بيانات الموظف وحدد دوره. يتم إنشاء كود موظف تلقائيًا حسب
            الوظيفة.
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

        <form
          onSubmit={handleSubmit}
          className="mt-7 rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200 sm:p-7"
        >
          <div className="border-b border-slate-100 pb-5">
            <h2 className="text-lg font-bold text-slate-900">
              بيانات الموظف
            </h2>

            <p className="mt-1 text-sm text-slate-500">
              الحقول التي تحمل علامة * مطلوبة.
            </p>
          </div>

          <div className="mt-6 grid gap-5 sm:grid-cols-2">
            <label className="block">
              <span className="text-sm font-bold text-slate-700">
                الاسم الكامل *
              </span>

              <input
                type="text"
                value={name}
                onChange={(event) => setName(event.target.value)}
                required
                autoComplete="name"
                placeholder="مثال: أحمد محمد"
                className="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-2 focus:ring-cyan-100"
              />
            </label>

            <label className="block">
              <span className="text-sm font-bold text-slate-700">
                البريد الإلكتروني *
              </span>

              <input
                type="email"
                dir="ltr"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
                autoComplete="email"
                placeholder="employee@hospital.com"
                className="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-2 focus:ring-cyan-100"
              />
            </label>

            <label className="block">
              <span className="text-sm font-bold text-slate-700">
                رقم الهاتف
              </span>

              <input
                type="tel"
                dir="ltr"
                value={phone}
                onChange={(event) => setPhone(event.target.value)}
                autoComplete="tel"
                placeholder="مثال: 0658479258"
                className="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-2 focus:ring-cyan-100"
              />
            </label>

            <div>
              <label className="block">
                <span className="text-sm font-bold text-slate-700">
                  كود الموظف *
                </span>

                <div className="mt-2 flex gap-2">
                  <input
                    type="text"
                    dir="ltr"
                    value={employeeCode}
                    readOnly
                    className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-left text-sm font-bold tracking-wide text-slate-700 outline-none"
                  />

                  <button
                    type="button"
                    onClick={regenerateEmployeeCode}
                    className="shrink-0 rounded-xl border border-cyan-200 px-4 py-3 text-sm font-bold text-cyan-700 transition hover:bg-cyan-50"
                  >
                    توليد جديد
                  </button>
                </div>
              </label>

              <p className="mt-2 text-xs leading-5 text-slate-500">
                يُنشأ تلقائيًا: HOS + رمز الوظيفة + رقم عشوائي.
              </p>
            </div>
          </div>

          <div className="mt-6 rounded-2xl border border-slate-200 bg-slate-50 p-5">
            <label className="block">
              <span className="text-sm font-bold text-slate-700">
                دور الموظف *
              </span>

              <select
                value={role}
                onChange={(event) =>
                  handleRoleChange(
                    event.target.value as HospitalStaffRole
                  )
                }
                className="mt-2 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-900 outline-none transition focus:border-cyan-500 focus:ring-2 focus:ring-cyan-100"
              >
                {ROLE_OPTIONS.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </label>

            {selectedRole && (
              <p className="mt-3 text-sm leading-6 text-slate-500">
                <span className="font-bold text-slate-700">
                  {selectedRole.label}:
                </span>{" "}
                {selectedRole.description}
              </p>
            )}
          </div>

          <div className="mt-6 rounded-2xl border border-amber-200 bg-amber-50 p-5">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
              <div className="flex-1">
                <label className="block">
                  <span className="text-sm font-bold text-amber-900">
                    كلمة المرور المؤقتة *
                  </span>

                  <div className="mt-2 flex gap-2">
                    <input
                      type={showPassword ? "text" : "password"}
                      dir="ltr"
                      value={password}
                      onChange={(event) => setPassword(event.target.value)}
                      required
                      minLength={8}
                      autoComplete="new-password"
                      className="w-full rounded-xl border border-amber-200 bg-white px-4 py-3 text-left text-sm text-slate-900 outline-none transition focus:border-amber-500 focus:ring-2 focus:ring-amber-100"
                    />

                    <button
                      type="button"
                      onClick={() => setShowPassword((value) => !value)}
                      className="shrink-0 rounded-xl border border-amber-200 bg-white px-4 py-3 text-sm font-bold text-amber-800 transition hover:bg-amber-100"
                    >
                      {showPassword ? "إخفاء" : "إظهار"}
                    </button>
                  </div>
                </label>
              </div>

              <button
                type="button"
                onClick={() => setPassword(generateTemporaryPassword())}
                className="rounded-xl border border-amber-300 px-4 py-3 text-sm font-bold text-amber-800 transition hover:bg-amber-100"
              >
                إنشاء كلمة جديدة
              </button>
            </div>

            <p className="mt-3 text-sm leading-6 text-amber-800">
              انسخ كلمة المرور وأرسلها للموظف بطريقة آمنة. لا تظهر كلمة المرور
              مرة أخرى بعد حفظ الحساب.
            </p>
          </div>

          <div className="mt-7 flex flex-col-reverse gap-3 border-t border-slate-100 pt-6 sm:flex-row sm:justify-end">
            <button
              type="button"
              disabled={submitting}
              onClick={() => router.push("/hospital/staff")}
              className="rounded-xl border border-slate-200 px-5 py-3 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
            >
              إلغاء
            </button>

            <button
              type="submit"
              disabled={submitting}
              className="rounded-xl bg-cyan-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-cyan-800 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {submitting ? "جارٍ إضافة الموظف..." : "إضافة الموظف"}
            </button>
          </div>
        </form>
      </main>
    </main>
  );
}