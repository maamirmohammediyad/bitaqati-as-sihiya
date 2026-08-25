"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import AdminShell from "@/components/admin/AdminShell";
import { api } from "@/lib/api";
import { getAdminToken } from "@/lib/auth";

type Hospital = {
  id: string;
  name: string;
  type: string | null;
  license_number: string | null;
  address: string | null;
  city: string | null;
  state: string | null;
  country: string | null;
  postal_code: string | null;
  phone: string | null;
  email: string | null;
  latitude: number | null;
  longitude: number | null;
  is_active: boolean;
  status: string;
  has_admin: boolean;
  active_staff_count: number;
  created_at: string;
};

type HospitalsResponse = {
  data: Hospital[];
  total: number;
  current_page: number;
  last_page: number;
};

type HospitalForm = {
  name: string;
  type: string;
  license_number: string;
  city: string;
  country: string;
  address: string;
  phone: string;
  email: string;
  latitude: string;
  longitude: string;
};

type AdminForm = {
  name: string;
  email: string;
  phone: string;
  password: string;
};

const emptyForm: HospitalForm = {
  name: "",
  type: "hospital",
  license_number: "",
  city: "",
  country: "Algeria",
  address: "",
  phone: "",
  email: "",
  latitude: "",
  longitude: "",
};

const emptyAdminForm: AdminForm = {
  name: "",
  email: "",
  phone: "",
  password: "",
};

export default function HospitalsPage() {
  const [hospitals, setHospitals] = useState<Hospital[]>([]);
  const [total, setTotal] = useState(0);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [assigningAdmin, setAssigningAdmin] = useState(false);

  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const [search, setSearch] = useState("");
  const [showForm, setShowForm] = useState(false);

  const [form, setForm] = useState<HospitalForm>(emptyForm);
  const [editingHospital, setEditingHospital] = useState<Hospital | null>(
    null
  );

  const [deletingId, setDeletingId] = useState<string | null>(null);

  const [adminHospital, setAdminHospital] = useState<Hospital | null>(null);
  const [adminForm, setAdminForm] = useState<AdminForm>(emptyAdminForm);

  async function loadHospitals() {
    const token = getAdminToken();

    if (!token) {
      setLoading(false);
      setError("انتهت جلسة الدخول. سجّل دخولك مرة أخرى.");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const response = await api<HospitalsResponse>("/admin/hospitals", {
        token,
      });

      setHospitals(response.data);
      setTotal(response.total);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تحميل قائمة المستشفيات."
      );
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadHospitals();
  }, []);

  const filteredHospitals = useMemo(() => {
    const value = search.trim().toLowerCase();

    if (!value) {
      return hospitals;
    }

    return hospitals.filter((hospital) =>
      [
        hospital.name,
        hospital.city,
        hospital.country,
        hospital.license_number,
        hospital.email,
        hospital.phone,
      ]
        .filter(Boolean)
        .some((item) => item!.toLowerCase().includes(value))
    );
  }, [hospitals, search]);

  function updateForm(field: keyof HospitalForm, value: string) {
    setForm((current) => ({
      ...current,
      [field]: value,
    }));
  }

  function openCreateForm() {
    setError("");
    setSuccess("");

    if (showForm) {
      setShowForm(false);
      setEditingHospital(null);
      setForm(emptyForm);
      return;
    }

    setEditingHospital(null);
    setForm(emptyForm);
    setShowForm(true);
  }

  function openEdit(hospital: Hospital) {
    setError("");
    setSuccess("");

    setEditingHospital(hospital);
    setShowForm(true);

    setForm({
      name: hospital.name || "",
      type: hospital.type || "hospital",
      license_number: hospital.license_number || "",
      city: hospital.city || "",
      country: hospital.country || "Algeria",
      address: hospital.address || "",
      phone: hospital.phone || "",
      email: hospital.email || "",
      latitude: hospital.latitude?.toString() || "",
      longitude: hospital.longitude?.toString() || "",
    });
  }

  function closeHospitalForm() {
    setShowForm(false);
    setEditingHospital(null);
    setForm(emptyForm);
  }

  function openAdminModal(hospital: Hospital) {
    setError("");
    setSuccess("");

    setAdminHospital(hospital);
    setAdminForm(emptyAdminForm);
  }

  function closeAdminModal() {
    if (assigningAdmin) {
      return;
    }

    setAdminHospital(null);
    setAdminForm(emptyAdminForm);
  }

  async function submitHospital(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const token = getAdminToken();

    if (!token) {
      setError("انتهت جلسة الدخول. سجّل دخولك مرة أخرى.");
      return;
    }

    setSaving(true);
    setError("");
    setSuccess("");

    try {
      const payload = {
        name: form.name,
        type: form.type,
        license_number: form.license_number || null,
        city: form.city || null,
        country: form.country || null,
        address: form.address || null,
        phone: form.phone || null,
        email: form.email || null,
        latitude: form.latitude ? Number(form.latitude) : null,
        longitude: form.longitude ? Number(form.longitude) : null,
      };

      const isEditing = Boolean(editingHospital);

      await api<{ message: string }>(
        isEditing
          ? `/admin/hospitals/${editingHospital!.id}`
          : "/admin/hospitals",
        {
          method: isEditing ? "PUT" : "POST",
          token,
          body: JSON.stringify({
            ...payload,
            ...(isEditing
              ? {
                  is_active: editingHospital!.is_active,
                  status: editingHospital!.status,
                }
              : {}),
          }),
        }
      );

      setSuccess(
        isEditing
          ? "تم تعديل بيانات المؤسسة الصحية بنجاح."
          : "تمت إضافة المؤسسة الصحية بنجاح."
      );

      closeHospitalForm();
      await loadHospitals();
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر حفظ بيانات المؤسسة الصحية."
      );
    } finally {
      setSaving(false);
    }
  }

  async function submitHospitalAdmin(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!adminHospital) {
      return;
    }

    const token = getAdminToken();

    if (!token) {
      setError("انتهت جلسة الدخول. سجّل دخولك مرة أخرى.");
      return;
    }

    setAssigningAdmin(true);
    setError("");
    setSuccess("");

    try {
      const result = await api<{ message: string }>(
        `/admin/hospitals/${adminHospital.id}/admins`,
        {
          method: "POST",
          token,
          body: JSON.stringify(adminForm),
        }
      );

      setSuccess(result.message);
      setAdminHospital(null);
      setAdminForm(emptyAdminForm);

      await loadHospitals();
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر إضافة مدير المستشفى."
      );
    } finally {
      setAssigningAdmin(false);
    }
  }

  async function deleteHospital(hospital: Hospital) {
    const confirmed = window.confirm(
      `هل أنت متأكد من حذف "${hospital.name}"؟ لا يمكن التراجع عن هذا الإجراء.`
    );

    if (!confirmed) {
      return;
    }

    const token = getAdminToken();

    if (!token) {
      setError("انتهت جلسة الدخول. سجّل دخولك مرة أخرى.");
      return;
    }

    setDeletingId(hospital.id);
    setError("");
    setSuccess("");

    try {
      await api<{ message: string }>(`/admin/hospitals/${hospital.id}`, {
        method: "DELETE",
        token,
      });

      setSuccess("تم حذف المؤسسة الصحية بنجاح.");
      await loadHospitals();
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر حذف المؤسسة الصحية."
      );
    } finally {
      setDeletingId(null);
    }
  }

  return (
    <AdminShell
      title="إدارة المستشفيات"
      description="إضافة المؤسسات الصحية، تعديل بياناتها، وربط مديري المستشفيات بها."
    >
      {error && (
        <Alert type="error" message={error} onClose={() => setError("")} />
      )}

      {success && (
        <Alert
          type="success"
          message={success}
          onClose={() => setSuccess("")}
        />
      )}

      <section className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-sm text-slate-500">إجمالي المؤسسات الصحية</p>
            <p className="mt-1 text-3xl font-bold text-slate-900">
              {loading ? "..." : total.toLocaleString("ar")}
            </p>
          </div>

          <div className="flex flex-col gap-3 sm:flex-row">
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="ابحث بالاسم أو المدينة أو الترخيص..."
              className="min-w-0 rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10 sm:w-80"
            />

            <button
              type="button"
              onClick={openCreateForm}
              className="rounded-xl bg-cyan-600 px-5 py-3 text-sm font-bold text-white transition hover:bg-cyan-700"
            >
              {showForm ? "إغلاق النموذج" : "+ إضافة مستشفى"}
            </button>
          </div>
        </div>
      </section>

      {showForm && (
        <section className="mt-6 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="mb-6">
            <h3 className="text-lg font-bold text-slate-900">
              {editingHospital ? "تعديل مؤسسة صحية" : "إضافة مؤسسة صحية"}
            </h3>

            <p className="mt-1 text-sm text-slate-500">
              الحقول التي عليها نجمة مطلوبة. يمكنك استكمال بيانات الموقع لاحقًا.
            </p>
          </div>

          <form onSubmit={submitHospital} className="grid gap-5 md:grid-cols-2">
            <Field
              label="اسم المؤسسة"
              required
              value={form.name}
              onChange={(value) => updateForm("name", value)}
              placeholder="مثال: مستشفى الشفاء"
            />

            <SelectField
              label="نوع المؤسسة"
              value={form.type}
              onChange={(value) => updateForm("type", value)}
              options={[
                { value: "hospital", label: "مستشفى" },
                { value: "clinic", label: "عيادة" },
                { value: "medical_center", label: "مركز طبي" },
              ]}
            />

            <Field
              label="رقم الترخيص"
              value={form.license_number}
              onChange={(value) => updateForm("license_number", value)}
              placeholder="HSP-2026-001"
            />

            <Field
              label="المدينة"
              value={form.city}
              onChange={(value) => updateForm("city", value)}
              placeholder="الجزائر"
            />

            <Field
              label="الدولة"
              value={form.country}
              onChange={(value) => updateForm("country", value)}
              placeholder="Algeria"
            />

            <Field
              label="رقم الهاتف"
              value={form.phone}
              onChange={(value) => updateForm("phone", value)}
              placeholder="0550 000 000"
              dir="ltr"
            />

            <Field
              label="البريد الإلكتروني"
              type="email"
              value={form.email}
              onChange={(value) => updateForm("email", value)}
              placeholder="info@hospital.dz"
              dir="ltr"
            />

            <Field
              label="العنوان"
              value={form.address}
              onChange={(value) => updateForm("address", value)}
              placeholder="العنوان التفصيلي"
            />

            <Field
              label="خط العرض Latitude"
              type="number"
              value={form.latitude}
              onChange={(value) => updateForm("latitude", value)}
              placeholder="36.7538"
              dir="ltr"
            />

            <Field
              label="خط الطول Longitude"
              type="number"
              value={form.longitude}
              onChange={(value) => updateForm("longitude", value)}
              placeholder="3.0588"
              dir="ltr"
            />

            <div className="flex items-end gap-3 md:col-span-2">
              <button
                type="submit"
                disabled={saving}
                className="rounded-xl bg-slate-950 px-6 py-3.5 text-sm font-bold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-60"
              >
                {saving
                  ? "جارٍ الحفظ..."
                  : editingHospital
                    ? "حفظ التعديلات"
                    : "حفظ المؤسسة الصحية"}
              </button>

              <button
                type="button"
                disabled={saving}
                onClick={closeHospitalForm}
                className="rounded-xl px-5 py-3.5 text-sm font-bold text-slate-600 transition hover:bg-slate-100 disabled:opacity-60"
              >
                إلغاء
              </button>
            </div>
          </form>
        </section>
      )}

      <section className="mt-6 overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200">
        <div className="border-b border-slate-100 px-5 py-4">
          <h3 className="font-bold text-slate-900">قائمة المستشفيات</h3>
        </div>

        {loading ? (
          <div className="p-8 text-center text-sm text-slate-500">
            جارٍ تحميل المستشفيات...
          </div>
        ) : filteredHospitals.length === 0 ? (
          <div className="p-8 text-center text-sm text-slate-500">
            لا توجد نتائج مطابقة للبحث.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-[1000px] w-full text-right">
              <thead className="bg-slate-50 text-xs text-slate-500">
                <tr>
                  <th className="px-5 py-4 font-semibold">المؤسسة</th>
                  <th className="px-5 py-4 font-semibold">الموقع</th>
                  <th className="px-5 py-4 font-semibold">الترخيص</th>
                  <th className="px-5 py-4 font-semibold">
                    الموظفون النشطون
                  </th>
                  <th className="px-5 py-4 font-semibold">الحالة</th>
                  <th className="px-5 py-4 font-semibold">بيانات الاتصال</th>
                  <th className="px-5 py-4 font-semibold">الإجراءات</th>
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {filteredHospitals.map((hospital) => (
                  <tr key={hospital.id} className="text-sm text-slate-700">
                    <td className="px-5 py-4">
                      <p className="font-bold text-slate-900">
                        {hospital.name}
                      </p>

                      <p className="mt-1 text-xs text-slate-400">
                        {hospital.type === "clinic"
                          ? "عيادة"
                          : hospital.type === "medical_center"
                            ? "مركز طبي"
                            : "مستشفى"}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <p>{hospital.city || "غير محدد"}</p>

                      <p className="mt-1 text-xs text-slate-400">
                        {hospital.country || "—"}
                      </p>
                    </td>

                    <td className="px-5 py-4 font-mono text-xs">
                      {hospital.license_number || "—"}
                    </td>

                    <td className="px-5 py-4">
                      <span className="inline-flex min-w-8 justify-center rounded-full bg-cyan-50 px-2.5 py-1 text-xs font-bold text-cyan-700">
                        {hospital.active_staff_count}
                      </span>
                    </td>

                    <td className="px-5 py-4">
                      <StatusBadge
                        active={hospital.is_active}
                        status={hospital.status}
                      />
                    </td>

                    <td className="px-5 py-4">
                      <p dir="ltr" className="text-right">
                        {hospital.phone || "—"}
                      </p>

                      <p
                        dir="ltr"
                        className="mt-1 max-w-[190px] truncate text-right text-xs text-slate-400"
                      >
                        {hospital.email || "—"}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <div className="flex items-center gap-2">
                        {!hospital.has_admin ? (
  <button
    type="button"
    onClick={() => openAdminModal(hospital)}
    className="rounded-lg bg-emerald-50 px-3 py-2 text-xs font-bold text-emerald-700 transition hover:bg-emerald-100"
  >
    إضافة مدير
  </button>
) : (
  <span className="inline-flex rounded-lg bg-slate-100 px-3 py-2 text-xs font-bold text-slate-600">
    يوجد مدير
  </span>
)}

                        <button
                          type="button"
                          onClick={() => openEdit(hospital)}
                          className="rounded-lg bg-cyan-50 px-3 py-2 text-xs font-bold text-cyan-700 transition hover:bg-cyan-100"
                        >
                          تعديل
                        </button>

                        <button
                          type="button"
                          onClick={() => deleteHospital(hospital)}
                          disabled={deletingId === hospital.id}
                          className="rounded-lg bg-red-50 px-3 py-2 text-xs font-bold text-red-700 transition hover:bg-red-100 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                          {deletingId === hospital.id
                            ? "جارٍ الحذف..."
                            : "حذف"}
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {adminHospital && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 p-4">
          <form
            onSubmit={submitHospitalAdmin}
            className="w-full max-w-lg rounded-2xl bg-white p-6 shadow-2xl"
          >
            <div className="mb-6 flex items-start justify-between gap-4">
              <div>
                <h2 className="text-xl font-bold text-slate-900">
                  إضافة مدير مستشفى
                </h2>

                <p className="mt-1 text-sm text-slate-500">
                  المستشفى: {adminHospital.name}
                </p>
              </div>

              <button
                type="button"
                onClick={closeAdminModal}
                disabled={assigningAdmin}
                className="text-xl font-bold text-slate-400 transition hover:text-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
                aria-label="إغلاق"
              >
                ×
              </button>
            </div>

            <div className="space-y-4">
              <label className="block">
                <span className="mb-1.5 block text-sm font-bold text-slate-700">
                  الاسم الكامل
                </span>

                <input
                  required
                  value={adminForm.name}
                  onChange={(event) =>
                    setAdminForm((current) => ({
                      ...current,
                      name: event.target.value,
                    }))
                  }
                  className="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-700 placeholder:text-slate-500 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
                  placeholder="مثال: أحمد بن محمد"
                />
              </label>

              <label className="block">
                <span className="mb-1.5 block text-sm font-bold text-slate-700">
                  البريد الإلكتروني
                </span>

                <input
                  required
                  type="email"
                  dir="ltr"
                  value={adminForm.email}
                  onChange={(event) =>
                    setAdminForm((current) => ({
                      ...current,
                      email: event.target.value,
                    }))
                  }
                  className="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-700 placeholder:text-slate-500 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
                  placeholder="owner@hospital.com"
                />
              </label>

              <label className="block">
                <span className="mb-1.5 block text-sm font-bold text-slate-700">
                  رقم الهاتف — اختياري
                </span>

                <input
                  dir="ltr"
                  value={adminForm.phone}
                  onChange={(event) =>
                    setAdminForm((current) => ({
                      ...current,
                      phone: event.target.value,
                    }))
                  }
                  className="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-700 placeholder:text-slate-500 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
                  placeholder="0550000000"
                />
              </label>

              <label className="block">
                <span className="mb-1.5 block text-sm font-bold text-slate-700">
                  كلمة مرور مؤقتة
                </span>

                <input
                  required
                  type="password"
                  minLength={8}
                  value={adminForm.password}
                  onChange={(event) =>
                    setAdminForm((current) => ({
                      ...current,
                      password: event.target.value,
                    }))
                  }
                  className="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-700 placeholder:text-slate-500 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
                  placeholder="8 أحرف على الأقل"
                />

                <p className="mt-1.5 text-xs text-slate-500">
                  إذا كان البريد مسجلًا مسبقًا، سيُربط الحساب بالمستشفى كمدير.
                  وإذا لم يكن مسجلًا، سيُنشأ حساب جديد.
                </p>
              </label>
            </div>

            <div className="mt-7 flex gap-3">
              <button
                type="submit"
                disabled={assigningAdmin}
                className="flex-1 rounded-xl bg-emerald-600 px-4 py-3 font-bold text-white transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-60"
              >
                {assigningAdmin ? "جارٍ الحفظ..." : "إنشاء وربط المدير"}
              </button>

              <button
                type="button"
                onClick={closeAdminModal}
                disabled={assigningAdmin}
                className="rounded-xl border border-slate-300 px-4 py-3 font-bold text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
              >
                إلغاء
              </button>
            </div>
          </form>
        </div>
      )}
    </AdminShell>
  );
}

function Alert({
  type,
  message,
  onClose,
}: {
  type: "error" | "success";
  message: string;
  onClose: () => void;
}) {
  const className =
    type === "error"
      ? "border-red-200 bg-red-50 text-red-700"
      : "border-emerald-200 bg-emerald-50 text-emerald-700";

  return (
    <div
      className={`mb-6 flex items-center justify-between gap-4 rounded-2xl border px-5 py-4 text-sm ${className}`}
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

function Field({
  label,
  required = false,
  type = "text",
  value,
  placeholder,
  dir,
  onChange,
}: {
  label: string;
  required?: boolean;
  type?: string;
  value: string;
  placeholder?: string;
  dir?: "ltr" | "rtl";
  onChange: (value: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm font-semibold text-slate-700">
        {label} {required && <span className="text-red-600">*</span>}
      </span>

      <input
        type={type}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        required={required}
        dir={dir}
        step={type === "number" ? "any" : undefined}
        className="w-full rounded-xl border border-slate-300 px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
      />
    </label>
  );
}

function SelectField({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: string;
  options: { value: string; label: string }[];
  onChange: (value: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm font-semibold text-slate-700">
        {label}
      </span>

      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
      >
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </label>
  );
}

function StatusBadge({
  active,
  status,
}: {
  active: boolean;
  status: string;
}) {
  if (!active) {
    return (
      <span className="inline-flex rounded-full bg-slate-100 px-2.5 py-1 text-xs font-bold text-slate-600">
        غير نشط
      </span>
    );
  }

  if (status === "approved") {
    return (
      <span className="inline-flex rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-700">
        معتمد ونشط
      </span>
    );
  }

  return (
    <span className="inline-flex rounded-full bg-amber-50 px-2.5 py-1 text-xs font-bold text-amber-700">
      {status}
    </span>
  );
}