"use client";

import {
  FormEvent,
  useEffect,
  useMemo,
  useState,
} from "react";
import AdminShell from "@/components/admin/AdminShell";
import { api } from "@/lib/api";
import { getAdminToken } from "@/lib/auth";

type UserProfile = {
  id: string;
  full_name: string | null;
  date_of_birth: string | null;
  blood_group: string | null;
  gender: string | null;
  city: string | null;
  country: string | null;
  is_profile_complete: boolean;
};

type User = {
  id: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  national_id: string | null;
  role: string;
  patient_code?: string | null;
  employee_code?: string | null;
  is_active: boolean;
  is_profile_completed: boolean;
  created_at: string;
  updated_at: string;
  profile: UserProfile | null;
};

type UsersResponse = {
  data: User[];
  meta: {
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
  };
};

type ApiMessageResponse = {
  message: string;
  data?: User;
};

type UserFormValues = {
  name: string;
  email: string;
  phone: string;
  national_id: string;
  role: string;
  patient_code: string;
  employee_code: string;
  password: string;
  is_active: boolean;
};

const roleLabels: Record<string, string> = {
  super_admin: "مدير المنصة",
  health_worker: "موظف صحي",
  patient: "مريض",
  guardian: "ولي أمر",
};

const emptyForm: UserFormValues = {
  name: "",
  email: "",
  phone: "",
  national_id: "",
  role: "patient",
  patient_code: "",
  employee_code: "",
  password: "",
  is_active: true,
};

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const [search, setSearch] = useState("");
  const [role, setRole] = useState("all");
  const [status, setStatus] = useState("all");

  const [page, setPage] = useState(1);
  const [meta, setMeta] = useState({
    current_page: 1,
    last_page: 1,
    per_page: 20,
    total: 0,
  });

  const [modalOpen, setModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [deletingUser, setDeletingUser] = useState<User | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function loadUsers(targetPage = page) {
    const token = getAdminToken();

    if (!token) {
      setLoading(false);
      return;
    }

    setLoading(true);
    setError("");

    try {
      const response = await api<UsersResponse>(
        `/admin/users?page=${targetPage}`,
        { token }
      );

      setUsers(response.data);
      setMeta(response.meta);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "تعذر تحميل قائمة المستخدمين."
      );
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadUsers(page);
  }, [page]);

  const filteredUsers = useMemo(() => {
    const searchValue = search.trim().toLowerCase();

    return users.filter((user) => {
      const matchesSearch =
        !searchValue ||
        [
          user.name,
          user.email,
          user.phone,
          user.national_id,
          user.patient_code,
          user.employee_code,
          user.profile?.full_name,
        ]
          .filter((value): value is string => Boolean(value))
          .some((value) => value.toLowerCase().includes(searchValue));

      const matchesRole = role === "all" || user.role === role;

      const matchesStatus =
        status === "all" ||
        (status === "active" && user.is_active) ||
        (status === "inactive" && !user.is_active);

      return matchesSearch && matchesRole && matchesStatus;
    });
  }, [users, search, role, status]);

  function openCreateModal() {
    setError("");
    setEditingUser(null);
    setModalOpen(true);
  }

  function openEditModal(user: User) {
    setError("");
    setEditingUser(user);
    setModalOpen(true);
  }

  function closeUserModal() {
    if (submitting) {
      return;
    }

    setModalOpen(false);
    setEditingUser(null);
  }

  async function handleUserSaved(message: string) {
    setSuccess(message);
    setModalOpen(false);
    setEditingUser(null);
    await loadUsers(page);
  }

  async function deleteUser() {
    if (!deletingUser || submitting) {
      return;
    }

    const token = getAdminToken();

    if (!token) {
      setError("انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.");
      return;
    }

    setSubmitting(true);
    setError("");
    setSuccess("");

    try {
      const response = await api<ApiMessageResponse>(
        `/admin/users/${deletingUser.id}`,
        {
          method: "DELETE",
          token,
        }
      );

      const fallbackMessage = deletingUser.email
        ? "تم حذف المستخدم وإرسال إشعار إلى بريده الإلكتروني."
        : "تم حذف المستخدم بنجاح.";

      setSuccess(response.message || fallbackMessage);
      setDeletingUser(null);

      if (users.length === 1 && page > 1) {
        setPage((current) => current - 1);
      } else {
        await loadUsers(page);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "تعذر حذف المستخدم.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <AdminShell
      title="إدارة المستخدمين"
      description="استعرض حسابات المرضى والأولياء والموظفين الصحيين ومديري المنصة."
    >
      {error && (
        <Alert
          tone="error"
          message={error}
          onClose={() => setError("")}
        />
      )}

      {success && (
        <Alert
          tone="success"
          message={success}
          onClose={() => setSuccess("")}
        />
      )}

      <section className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
        <div className="flex flex-col gap-5 xl:flex-row xl:items-end xl:justify-between">
          <div className="flex items-end justify-between gap-4 xl:block">
            <div>
              <p className="text-sm text-slate-500">إجمالي المستخدمين</p>

              <p className="mt-1 text-3xl font-bold text-slate-900">
                {loading ? "..." : meta.total.toLocaleString("ar")}
              </p>
            </div>

            <button
              type="button"
              onClick={openCreateModal}
              className="rounded-xl bg-cyan-600 px-4 py-3 text-sm font-bold text-white transition hover:bg-cyan-700"
            >
              + إضافة مستخدم
            </button>
          </div>

          <div className="grid gap-3 sm:grid-cols-3 xl:w-[760px]">
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="ابحث بالاسم أو البريد أو الهاتف أو الرقم الوطني..."
              className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10 sm:col-span-3"
            />

            <select
              value={role}
              onChange={(event) => setRole(event.target.value)}
              className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
            >
              <option value="all">كل الأدوار</option>
              <option value="patient">المرضى</option>
              <option value="guardian">الأولياء</option>
              <option value="health_worker">الموظفون الصحيون</option>
              <option value="super_admin">مديرو المنصة</option>
            </select>

            <select
              value={status}
              onChange={(event) => setStatus(event.target.value)}
              className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-700 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
            >
              <option value="all">كل الحالات</option>
              <option value="active">الحسابات النشطة</option>
              <option value="inactive">الحسابات غير النشطة</option>
            </select>

            <button
              type="button"
              onClick={() => void loadUsers(page)}
              disabled={loading}
              className="rounded-xl bg-slate-950 px-4 py-3 text-sm font-bold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-60"
            >
              تحديث القائمة
            </button>
          </div>
        </div>
      </section>

      <section className="mt-6 overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200">
        <div className="flex flex-col gap-2 border-b border-slate-100 px-5 py-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h3 className="font-bold text-slate-900">قائمة المستخدمين</h3>

            <p className="mt-1 text-xs text-slate-500">
              نتائج الصفحة الحالية: {filteredUsers.length}
            </p>
          </div>

          <p className="text-xs text-slate-500">
            الصفحة {meta.current_page} من {meta.last_page}
          </p>
        </div>

        {loading ? (
          <div className="p-8 text-center text-sm text-slate-500">
            جارٍ تحميل المستخدمين...
          </div>
        ) : filteredUsers.length === 0 ? (
          <div className="p-8 text-center text-sm text-slate-500">
            لا توجد نتائج مطابقة للتصفية الحالية.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-[1240px] w-full text-right">
              <thead className="bg-slate-50 text-xs text-slate-500">
                <tr>
                  <th className="px-5 py-4 font-semibold">المستخدم</th>
                  <th className="px-5 py-4 font-semibold">الدور</th>
                  <th className="px-5 py-4 font-semibold">الاتصال</th>
                  <th className="px-5 py-4 font-semibold">المعرّف</th>
                  <th className="px-5 py-4 font-semibold">الملف الشخصي</th>
                  <th className="px-5 py-4 font-semibold">حالة الحساب</th>
                  <th className="px-5 py-4 font-semibold">تاريخ الإنشاء</th>
                  <th className="px-5 py-4 font-semibold">الإجراءات</th>
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {filteredUsers.map((user) => (
                  <tr key={user.id} className="text-sm text-slate-700">
                    <td className="px-5 py-4">
                      <p className="font-bold text-slate-900">
                        {user.name || user.profile?.full_name || "بدون اسم"}
                      </p>

                      <p className="mt-1 font-mono text-xs text-slate-400">
                        {shortId(user.id)}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <RoleBadge role={user.role} />
                    </td>

                    <td className="px-5 py-4">
                      <p dir="ltr" className="text-right">
                        {user.phone || "—"}
                      </p>

                      <p
                        dir="ltr"
                        className="mt-1 max-w-[220px] truncate text-right text-xs text-slate-400"
                      >
                        {user.email || "—"}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <IdentifierCell user={user} />
                    </td>

                    <td className="px-5 py-4">
                      <ProfileBadge
                        complete={
                          user.is_profile_completed ||
                          user.profile?.is_profile_complete === true
                        }
                      />
                    </td>

                    <td className="px-5 py-4">
                      <AccountStatusBadge active={user.is_active} />
                    </td>

                    <td className="px-5 py-4 text-xs text-slate-500">
                      {formatDate(user.created_at)}
                    </td>

                    <td className="px-5 py-4">
                      <div className="flex items-center gap-2">
                        <button
                          type="button"
                          onClick={() => openEditModal(user)}
                          className="rounded-lg border border-cyan-200 bg-cyan-50 px-3 py-2 text-xs font-bold text-cyan-700 transition hover:bg-cyan-100"
                        >
                          تعديل
                        </button>

                        <button
                          type="button"
                          onClick={() => {
                            setError("");
                            setDeletingUser(user);
                          }}
                          className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-xs font-bold text-red-700 transition hover:bg-red-100"
                        >
                          حذف
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <Pagination
          currentPage={meta.current_page}
          lastPage={meta.last_page}
          loading={loading}
          onPrevious={() => setPage((current) => Math.max(1, current - 1))}
          onNext={() =>
            setPage((current) => Math.min(meta.last_page, current + 1))
          }
        />
      </section>

      <UserFormModal
        open={modalOpen}
        user={editingUser}
        submitting={submitting}
        onClose={closeUserModal}
        onError={setError}
        onSuccess={handleUserSaved}
        setSubmitting={setSubmitting}
      />

      <DeleteUserModal
        user={deletingUser}
        submitting={submitting}
        onClose={() => {
          if (!submitting) {
            setDeletingUser(null);
          }
        }}
        onConfirm={() => void deleteUser()}
      />
    </AdminShell>
  );
}

function Alert({
  tone,
  message,
  onClose,
}: {
  tone: "error" | "success";
  message: string;
  onClose: () => void;
}) {
  const classes =
    tone === "success"
      ? "border-emerald-200 bg-emerald-50 text-emerald-700"
      : "border-red-200 bg-red-50 text-red-700";

  return (
    <div
      className={`mb-6 flex items-center justify-between gap-4 rounded-2xl border px-5 py-4 text-sm ${classes}`}
    >
      <span>{message}</span>

      <button
        type="button"
        onClick={onClose}
        className="font-bold opacity-70 transition hover:opacity-100"
        aria-label="إغلاق"
      >
        ×
      </button>
    </div>
  );
}

function RoleBadge({ role }: { role: string }) {
  const classes: Record<string, string> = {
    patient: "bg-blue-50 text-blue-700",
    guardian: "bg-violet-50 text-violet-700",
    health_worker: "bg-emerald-50 text-emerald-700",
    super_admin: "bg-amber-50 text-amber-700",
  };

  return (
    <span
      className={`inline-flex rounded-full px-2.5 py-1 text-xs font-bold ${
        classes[role] || "bg-slate-100 text-slate-700"
      }`}
    >
      {roleLabels[role] || role}
    </span>
  );
}

function AccountStatusBadge({ active }: { active: boolean }) {
  return active ? (
    <span className="inline-flex rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-700">
      نشط
    </span>
  ) : (
    <span className="inline-flex rounded-full bg-slate-100 px-2.5 py-1 text-xs font-bold text-slate-600">
      غير نشط
    </span>
  );
}

function ProfileBadge({ complete }: { complete: boolean }) {
  return complete ? (
    <span className="inline-flex rounded-full bg-cyan-50 px-2.5 py-1 text-xs font-bold text-cyan-700">
      مكتمل
    </span>
  ) : (
    <span className="inline-flex rounded-full bg-amber-50 px-2.5 py-1 text-xs font-bold text-amber-700">
      غير مكتمل
    </span>
  );
}

function IdentifierCell({ user }: { user: User }) {
  if (user.role === "patient" && user.patient_code) {
    return (
      <div>
        <span className="rounded-lg bg-cyan-50 px-2.5 py-1 font-mono text-xs font-bold text-cyan-700">
          {user.patient_code}
        </span>

        {user.national_id && (
          <p className="mt-2 font-mono text-xs text-slate-400">
            وطني: {user.national_id}
          </p>
        )}
      </div>
    );
  }

  if (user.role === "health_worker" && user.employee_code) {
    return (
      <div>
        <span className="rounded-lg bg-emerald-50 px-2.5 py-1 font-mono text-xs font-bold text-emerald-700">
          {user.employee_code}
        </span>

        {user.national_id && (
          <p className="mt-2 font-mono text-xs text-slate-400">
            وطني: {user.national_id}
          </p>
        )}
      </div>
    );
  }

  return (
    <span className="font-mono text-xs text-slate-500">
      {user.national_id || "—"}
    </span>
  );
}

function Pagination({
  currentPage,
  lastPage,
  loading,
  onPrevious,
  onNext,
}: {
  currentPage: number;
  lastPage: number;
  loading: boolean;
  onPrevious: () => void;
  onNext: () => void;
}) {
  if (lastPage <= 1) {
    return null;
  }

  return (
    <div className="flex items-center justify-between border-t border-slate-100 px-5 py-4">
      <button
        type="button"
        onClick={onPrevious}
        disabled={loading || currentPage <= 1}
        className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
      >
        الصفحة السابقة
      </button>

      <span className="text-sm text-slate-500">
        {currentPage} / {lastPage}
      </span>

      <button
        type="button"
        onClick={onNext}
        disabled={loading || currentPage >= lastPage}
        className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
      >
        الصفحة التالية
      </button>
    </div>
  );
}

function UserFormModal({
  open,
  user,
  submitting,
  onClose,
  onError,
  onSuccess,
  setSubmitting,
}: {
  open: boolean;
  user: User | null;
  submitting: boolean;
  onClose: () => void;
  onError: (message: string) => void;
  onSuccess: (message: string) => Promise<void>;
  setSubmitting: (value: boolean) => void;
}) {
  const isEditing = Boolean(user);
  const [form, setForm] = useState<UserFormValues>(emptyForm);

  useEffect(() => {
    if (!open) {
      return;
    }

    setForm({
      name: user?.name || user?.profile?.full_name || "",
      email: user?.email || "",
      phone: user?.phone || "",
      national_id: user?.national_id || "",
      role: user?.role || "patient",
      patient_code: user?.patient_code || "",
      employee_code: user?.employee_code || "",
      password: "",
      is_active: user?.is_active ?? true,
    });
  }, [open, user]);

  if (!open) {
    return null;
  }

  function updateField<Key extends keyof UserFormValues>(
    key: Key,
    value: UserFormValues[Key]
  ) {
    setForm((current) => ({
      ...current,
      [key]: value,
    }));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const token = getAdminToken();

    if (!token) {
      onError("انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.");
      return;
    }

    if (!form.name.trim()) {
      onError("اسم المستخدم مطلوب.");
      return;
    }

    if (!isEditing && form.password.trim().length < 8) {
      onError("كلمة المرور يجب أن تتكون من 8 أحرف على الأقل.");
      return;
    }

    if (
      (form.role === "patient" || form.role === "guardian") &&
      !form.national_id.trim()
    ) {
      onError("الرقم الوطني مطلوب للمريض وولي الأمر.");
      return;
    }

    if (form.role === "patient" && !form.patient_code.trim()) {
      onError("رمز المريض مطلوب عند إنشاء أو تعديل حساب مريض.");
      return;
    }

    if (form.role === "health_worker" && !form.employee_code.trim()) {
      onError("رمز الموظف مطلوب للموظف الصحي.");
      return;
    }

    setSubmitting(true);
    onError("");

    const payload = {
      name: form.name.trim(),
      email: form.email.trim() || null,
      phone: form.phone.trim() || null,
      national_id:
        form.role === "patient" || form.role === "guardian"
          ? form.national_id.trim()
          : form.national_id.trim() || null,
      role: form.role,
      patient_code:
        form.role === "patient" ? form.patient_code.trim() : null,
      employee_code:
        form.role === "health_worker" ? form.employee_code.trim() : null,
      is_active: form.is_active,
      ...(form.password.trim() ? { password: form.password.trim() } : {}),
    };

    try {
const response = await api<ApiMessageResponse>(
  isEditing ? `/admin/users/${user?.id}` : "/admin/users",
  {
    method: isEditing ? "PUT" : "POST",
    token,
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify(payload),
  }
);

      const fallbackMessage = form.email.trim()
        ? isEditing
          ? "تم تحديث المستخدم وإرسال إشعار إلى بريده الإلكتروني."
          : "تم إنشاء المستخدم وإرسال بيانات الحساب إلى بريده الإلكتروني."
        : isEditing
          ? "تم تحديث المستخدم بنجاح."
          : "تم إنشاء المستخدم بنجاح.";

      await onSuccess(response.message || fallbackMessage);
    } catch (err) {
      onError(
        err instanceof Error ? err.message : "تعذر حفظ بيانات المستخدم."
      );
    } finally {
      setSubmitting(false);
    }
  }

  const showNationalId =
    form.role === "patient" || form.role === "guardian";

  const showPatientCode = form.role === "patient";
  const showEmployeeCode = form.role === "health_worker";

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-slate-950/50 p-4">
      <div
        dir="rtl"
        className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white p-6 shadow-2xl"
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <h3 className="text-lg font-bold text-slate-900">
              {isEditing ? "تعديل المستخدم" : "إضافة مستخدم جديد"}
            </h3>

            <p className="mt-1 text-sm leading-6 text-slate-500">
              {isEditing
                ? "سيُرسل إشعار إلى البريد الإلكتروني بعد حفظ التعديلات، إذا كان البريد موجودًا."
                : "سيُرسل بريد يحتوي على بيانات الحساب عند إدخال بريد إلكتروني صحيح."}
            </p>
          </div>

          <button
            type="button"
            onClick={onClose}
            disabled={submitting}
            className="text-xl text-slate-400 transition hover:text-slate-700 disabled:opacity-50"
            aria-label="إغلاق"
          >
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 grid gap-4 sm:grid-cols-2">
          <TextField
            label="الاسم الكامل"
            value={form.name}
            onChange={(value) => updateField("name", value)}
            placeholder="اسم المستخدم"
            required
          />

          <TextField
            label="البريد الإلكتروني"
            type="email"
            value={form.email}
            onChange={(value) => updateField("email", value)}
            placeholder="name@example.com"
          />

          <TextField
            label="رقم الهاتف"
            value={form.phone}
            onChange={(value) => updateField("phone", value)}
            placeholder="+213..."
          />

          <label className="grid gap-2 text-sm font-bold text-slate-700">
            الدور

            <select
              value={form.role}
              onChange={(event) => updateField("role", event.target.value)}
              className="rounded-xl border border-slate-300 px-4 py-3 font-normal outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
            >
              <option value="patient">مريض</option>
              <option value="guardian">ولي أمر</option>
              <option value="health_worker">موظف صحي</option>
              <option value="super_admin">مدير المنصة</option>
            </select>
          </label>

          {showNationalId && (
            <TextField
              label="الرقم الوطني"
              value={form.national_id}
              onChange={(value) => updateField("national_id", value)}
              placeholder="الرقم الوطني للمستخدم"
              required
            />
          )}

          {showPatientCode && (
            <TextField
              label="رمز المريض"
              value={form.patient_code}
              onChange={(value) => updateField("patient_code", value)}
              placeholder="مثال: PAT-00001"
              required
            />
          )}

          {showEmployeeCode && (
            <TextField
              label="رمز الموظف"
              value={form.employee_code}
              onChange={(value) => updateField("employee_code", value)}
              placeholder="مثال: EMP-00001"
              required
            />
          )}

          <TextField
            label={isEditing ? "كلمة مرور جديدة (اختياري)" : "كلمة المرور"}
            type="password"
            value={form.password}
            onChange={(value) => updateField("password", value)}
            placeholder={
              isEditing
                ? "اتركها فارغة لعدم تغييرها"
                : "8 أحرف على الأقل"
            }
            required={!isEditing}
          />

          <label className="flex items-center gap-3 rounded-xl border border-slate-200 px-4 py-3 text-sm font-bold text-slate-700 sm:col-span-2">
            <input
              type="checkbox"
              checked={form.is_active}
              onChange={(event) =>
                updateField("is_active", event.target.checked)
              }
              className="h-4 w-4 accent-cyan-600"
            />
            الحساب نشط ويمكنه تسجيل الدخول
          </label>

          <div className="mt-2 flex flex-wrap gap-3 sm:col-span-2">
            <button
              type="submit"
              disabled={submitting}
              className="rounded-xl bg-cyan-600 px-5 py-3 text-sm font-bold text-white transition hover:bg-cyan-700 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {submitting
                ? "جارٍ الحفظ..."
                : isEditing
                  ? "حفظ التعديلات"
                  : "إنشاء المستخدم"}
            </button>

            <button
              type="button"
              onClick={onClose}
              disabled={submitting}
              className="rounded-xl border border-slate-300 px-5 py-3 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
            >
              إلغاء
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function TextField({
  label,
  type = "text",
  value,
  onChange,
  placeholder,
  required = false,
}: {
  label: string;
  type?: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  required?: boolean;
}) {
  return (
    <label className="grid gap-2 text-sm font-bold text-slate-700">
      {label}

      <input
        type={type}
        value={value}
        required={required}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        className="rounded-xl border border-slate-300 px-4 py-3 font-normal outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
      />
    </label>
  );
}

function DeleteUserModal({
  user,
  submitting,
  onClose,
  onConfirm,
}: {
  user: User | null;
  submitting: boolean;
  onClose: () => void;
  onConfirm: () => void;
}) {
  if (!user) {
    return null;
  }

  const displayName = user.name || user.profile?.full_name || "هذا المستخدم";

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-slate-950/50 p-4">
      <div
        dir="rtl"
        className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl"
      >
        <h3 className="text-lg font-bold text-slate-900">
          تأكيد حذف المستخدم
        </h3>

        <p className="mt-3 text-sm leading-6 text-slate-600">
          هل تريد حذف حساب <strong>{displayName}</strong>؟
        </p>

        <p className="mt-2 text-sm leading-6 text-red-600">
          الحذف النهائي قد يحذف سجلات مرتبطة بالمستخدم بسبب علاقات قاعدة البيانات.
          يفضّل تعطيل الحساب بدل الحذف عندما تكون له سجلات طبية أو بلاغات طوارئ.
        </p>

        {user.email && (
          <p className="mt-3 text-xs text-slate-500">
            سيُرسل إشعار الحذف إلى: <span dir="ltr">{user.email}</span>
          </p>
        )}

        <div className="mt-6 flex flex-wrap gap-3">
          <button
            type="button"
            onClick={onConfirm}
            disabled={submitting}
            className="rounded-xl bg-red-600 px-5 py-3 text-sm font-bold text-white transition hover:bg-red-700 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting ? "جارٍ الحذف..." : "حذف المستخدم"}
          </button>

          <button
            type="button"
            onClick={onClose}
            disabled={submitting}
            className="rounded-xl border border-slate-300 px-5 py-3 text-sm font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
          >
            إلغاء
          </button>
        </div>
      </div>
    </div>
  );
}

function shortId(id: string) {
  if (id.length <= 12) {
    return id;
  }

  return `${id.slice(0, 8)}…${id.slice(-4)}`;
}

function formatDate(value: string) {
  if (!value) {
    return "—";
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat("ar-DZ", {
    year: "numeric",
    month: "short",
    day: "numeric",
  }).format(date);
}