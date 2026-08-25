"use client";

import { useEffect, useMemo, useState } from "react";
import AdminShell from "@/components/admin/AdminShell";
import { api } from "@/lib/api";
import { getAdminToken } from "@/lib/auth";

type EmergencyUser = {
  id: string;
  name: string;
  email: string | null;
  phone: string | null;
  patient_code: string | null;
  blood_type: string | null;
  allergies: string | null;
};

type EmergencyHospital = {
  id: string;
  name: string;
  city: string | null;
  phone: string | null;
};

type EmergencyEvent = {
  id: string;
  status: string;
  location_name: string | null;
  latitude: number | null;
  longitude: number | null;
  notes: string | null;
  notified_guardians: boolean;
  checked_in_at: string | null;
  resolved_at: string | null;
  created_at: string;
  updated_at: string | null;
  user: EmergencyUser | null;
  hospital: EmergencyHospital | null;
  checked_in_hospital: EmergencyHospital | null;
  resolved_by: {
    id: string;
    name: string;
  } | null;
};

type EmergencyResponse = {
  data: EmergencyEvent[];
  total?: number;
  current_page?: number;
  last_page?: number;
};

type FilterStatus = "all" | "active" | "checked_in" | "resolved";

export default function EmergencyEventsPage() {
  const [events, setEvents] = useState<EmergencyEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState("");

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<FilterStatus>("all");
  const [selectedEvent, setSelectedEvent] = useState<EmergencyEvent | null>(
    null
  );

  async function loadEmergencyEvents(showRefreshState = false) {
    const token = getAdminToken();

    if (!token) {
      setLoading(false);
      setError("انتهت جلسة الدخول. سجّل دخولك مرة أخرى.");
      return;
    }

    if (showRefreshState) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }

    setError("");

    try {
      const response = await api<EmergencyResponse>("/admin/emergency-events", {
        token,
      });

      setEvents(response.data || []);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "تعذر تحميل بلاغات الطوارئ."
      );
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }

  useEffect(() => {
    loadEmergencyEvents();
  }, []);

  const statistics = useMemo(() => {
    const active = events.filter(
      (event) => event.status !== "resolved" && !event.checked_in_hospital
    ).length;

    const checkedIn = events.filter(
      (event) => event.status !== "resolved" && event.checked_in_hospital
    ).length;

    const resolved = events.filter(
      (event) => event.status === "resolved"
    ).length;

    return {
      total: events.length,
      active,
      checkedIn,
      resolved,
    };
  }, [events]);

  const filteredEvents = useMemo(() => {
    const searchValue = search.trim().toLowerCase();

    return events.filter((event) => {
      const currentStatus = getEventStatus(event);

      const matchesStatus =
        statusFilter === "all" || currentStatus.key === statusFilter;

      if (!matchesStatus) {
        return false;
      }

      if (!searchValue) {
        return true;
      }

      const fields = [
        event.id,
        event.user?.name,
        event.user?.phone,
        event.user?.email,
        event.user?.patient_code,
        event.location_name,
        event.checked_in_hospital?.name,
        event.hospital?.name,
      ];

      return fields
        .filter(Boolean)
        .some((field) => field!.toLowerCase().includes(searchValue));
    });
  }, [events, search, statusFilter]);

  return (
    <AdminShell
      title="بلاغات الطوارئ"
      description="متابعة جميع بلاغات الاستغاثة وحالة استلامها وحلها في المؤسسات الصحية."
    >
      {error && (
        <Alert type="error" message={error} onClose={() => setError("")} />
      )}

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="إجمالي البلاغات"
          value={loading ? "..." : statistics.total.toLocaleString("ar")}
          color="slate"
        />

        <StatCard
          label="بلاغات نشطة"
          value={loading ? "..." : statistics.active.toLocaleString("ar")}
          color="red"
        />

        <StatCard
          label="تم استلامها"
          value={loading ? "..." : statistics.checkedIn.toLocaleString("ar")}
          color="amber"
        />

        <StatCard
          label="بلاغات محلولة"
          value={loading ? "..." : statistics.resolved.toLocaleString("ar")}
          color="emerald"
        />
      </section>

      <section className="mt-6 rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
        <div className="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
          <div>
            <h2 className="text-lg font-bold text-slate-900">
              سجل حالات الطوارئ
            </h2>

            <p className="mt-1 text-sm text-slate-500">
              اضغط على “التفاصيل” لمشاهدة موقع البلاغ وبيانات المريض.
            </p>
          </div>

          <div className="flex flex-col gap-3 sm:flex-row">
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="ابحث باسم المريض أو الهاتف أو الموقع..."
              className="min-w-0 rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10 sm:w-80"
            />

            <select
              value={statusFilter}
              onChange={(event) =>
                setStatusFilter(event.target.value as FilterStatus)
              }
              className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm font-medium text-slate-700 outline-none transition focus:border-cyan-500 focus:ring-4 focus:ring-cyan-500/10"
            >
              <option value="all">كل الحالات</option>
              <option value="active">نشطة</option>
              <option value="checked_in">تم الاستلام</option>
              <option value="resolved">تم الحل</option>
            </select>

            <button
              type="button"
              onClick={() => loadEmergencyEvents(true)}
              disabled={refreshing}
              className="rounded-xl bg-cyan-600 px-5 py-3 text-sm font-bold text-white transition hover:bg-cyan-700 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {refreshing ? "جارٍ التحديث..." : "تحديث"}
            </button>
          </div>
        </div>
      </section>

      <section className="mt-6 overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-slate-200">
        <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
          <h3 className="font-bold text-slate-900">قائمة البلاغات</h3>

          <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-bold text-slate-600">
            {loading
              ? "..."
              : `${filteredEvents.length.toLocaleString("ar")} نتيجة`}
          </span>
        </div>

        {loading ? (
          <div className="p-8 text-center text-sm text-slate-500">
            جارٍ تحميل بلاغات الطوارئ...
          </div>
        ) : filteredEvents.length === 0 ? (
          <div className="p-8 text-center text-sm text-slate-500">
            لا توجد بلاغات مطابقة للبحث أو الفلتر المحدد.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-[1120px] w-full text-right">
              <thead className="bg-slate-50 text-xs text-slate-500">
                <tr>
                  <th className="px-5 py-4 font-semibold">المريض</th>
                  <th className="px-5 py-4 font-semibold">التواصل</th>
                  <th className="px-5 py-4 font-semibold">الموقع</th>
                  <th className="px-5 py-4 font-semibold">الحالة</th>
                  <th className="px-5 py-4 font-semibold">المستشفى</th>
                  <th className="px-5 py-4 font-semibold">وقت البلاغ</th>
                  <th className="px-5 py-4 font-semibold">الإجراء</th>
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {filteredEvents.map((event) => {
                  const status = getEventStatus(event);

                  return (
                    <tr key={event.id} className="text-sm text-slate-700">
                      <td className="px-5 py-4">
                        <p className="font-bold text-slate-900">
                          {event.user?.name || "مستخدم غير معروف"}
                        </p>

                        <p className="mt-1 font-mono text-xs text-slate-400">
                          {event.user?.patient_code || event.id.slice(0, 8)}
                        </p>
                      </td>

                      <td className="px-5 py-4">
                        <p dir="ltr" className="text-right">
                          {event.user?.phone || "—"}
                        </p>

                        <p
                          dir="ltr"
                          className="mt-1 max-w-[190px] truncate text-right text-xs text-slate-400"
                        >
                          {event.user?.email || "—"}
                        </p>
                      </td>

                      <td className="px-5 py-4">
                        <p className="max-w-[200px] truncate">
                          {event.location_name || "موقع غير محدد"}
                        </p>

                        {event.latitude !== null &&
                          event.longitude !== null && (
                            <a
                              href={getGoogleMapsUrl(event)}
                              target="_blank"
                              rel="noreferrer"
                              className="mt-1 inline-flex text-xs font-bold text-cyan-700 hover:text-cyan-800 hover:underline"
                            >
                              فتح الخريطة
                            </a>
                          )}
                      </td>

                      <td className="px-5 py-4">
                        <StatusBadge status={status.key} label={status.label} />
                      </td>

                      <td className="px-5 py-4">
                        {event.checked_in_hospital ? (
                          <>
                            <p className="font-semibold text-slate-900">
                              {event.checked_in_hospital.name}
                            </p>

                            <p className="mt-1 text-xs text-slate-400">
                              {event.checked_in_at
                                ? formatDateTime(event.checked_in_at)
                                : "تم الاستلام"}
                            </p>
                          </>
                        ) : (
                          <span className="text-slate-400">لم يتم الاستلام</span>
                        )}
                      </td>

                      <td className="px-5 py-4">
                        <p className="whitespace-nowrap">
                          {formatDateTime(event.created_at)}
                        </p>
                      </td>

                      <td className="px-5 py-4">
                        <button
                          type="button"
                          onClick={() => setSelectedEvent(event)}
                          className="rounded-lg bg-cyan-50 px-3 py-2 text-xs font-bold text-cyan-700 transition hover:bg-cyan-100"
                        >
                          التفاصيل
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {selectedEvent && (
        <EmergencyDetailsModal
          event={selectedEvent}
          onClose={() => setSelectedEvent(null)}
        />
      )}
    </AdminShell>
  );
}

function EmergencyDetailsModal({
  event,
  onClose,
}: {
  event: EmergencyEvent;
  onClose: () => void;
}) {
  const status = getEventStatus(event);
  const mapUrl = getGoogleMapsUrl(event);

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-slate-950/50 p-4">
      <div className="mx-auto my-6 w-full max-w-3xl rounded-2xl bg-white shadow-2xl">
        <div className="flex items-start justify-between gap-4 border-b border-slate-100 p-6">
          <div>
            <div className="flex flex-wrap items-center gap-3">
              <h2 className="text-xl font-bold text-slate-900">
                تفاصيل بلاغ الطوارئ
              </h2>

              <StatusBadge status={status.key} label={status.label} />
            </div>

            <p className="mt-2 font-mono text-xs text-slate-400">
              رقم البلاغ: {event.id}
            </p>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="text-2xl font-bold leading-none text-slate-400 transition hover:text-slate-700"
            aria-label="إغلاق"
          >
            ×
          </button>
        </div>

        <div className="space-y-6 p-6">
          <section>
            <h3 className="mb-3 text-sm font-bold text-slate-900">
              بيانات المريض
            </h3>

            <div className="grid gap-4 rounded-xl bg-slate-50 p-4 sm:grid-cols-2">
              <InfoItem label="الاسم" value={event.user?.name || "—"} />

              <InfoItem
                label="رمز المريض"
                value={event.user?.patient_code || "—"}
                mono
              />

              <InfoItem
                label="رقم الهاتف"
                value={event.user?.phone || "—"}
                dir="ltr"
              />

              <InfoItem
                label="فصيلة الدم"
                value={event.user?.blood_type || "غير متوفرة"}
              />

              <InfoItem
                label="الحساسية"
                value={event.user?.allergies || "لا توجد بيانات"}
              />

              <InfoItem
                label="تم إشعار الأولياء"
                value={event.notified_guardians ? "نعم" : "لا"}
              />
            </div>
          </section>

          <section>
            <h3 className="mb-3 text-sm font-bold text-slate-900">
              موقع الاستغاثة
            </h3>

            <div className="rounded-xl border border-slate-200 p-4">
              <InfoItem
                label="الوصف أو العنوان"
                value={event.location_name || "غير متوفر"}
              />

              <div className="mt-4 grid gap-4 sm:grid-cols-2">
                <InfoItem
                  label="خط العرض"
                  value={
                    event.latitude !== null ? String(event.latitude) : "—"
                  }
                  dir="ltr"
                />

                <InfoItem
                  label="خط الطول"
                  value={
                    event.longitude !== null ? String(event.longitude) : "—"
                  }
                  dir="ltr"
                />
              </div>

              {event.latitude !== null && event.longitude !== null && (
                <a
                  href={mapUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="mt-5 inline-flex rounded-xl bg-cyan-600 px-4 py-3 text-sm font-bold text-white transition hover:bg-cyan-700"
                >
                  فتح الموقع في Google Maps
                </a>
              )}
            </div>
          </section>

          <section>
            <h3 className="mb-3 text-sm font-bold text-slate-900">
              متابعة الحالة
            </h3>

            <div className="grid gap-4 rounded-xl bg-slate-50 p-4 sm:grid-cols-2">
              <InfoItem
                label="وقت إرسال البلاغ"
                value={formatDateTime(event.created_at)}
              />

              <InfoItem
                label="وقت آخر تحديث"
                value={
                  event.updated_at
                    ? formatDateTime(event.updated_at)
                    : "غير متوفر"
                }
              />

              <InfoItem
                label="وقت الاستلام"
                value={
                  event.checked_in_at
                    ? formatDateTime(event.checked_in_at)
                    : "لم يتم الاستلام"
                }
              />

              <InfoItem
                label="وقت الحل"
                value={
                  event.resolved_at
                    ? formatDateTime(event.resolved_at)
                    : "لم يتم الحل بعد"
                }
              />

              <InfoItem
                label="المستشفى المستلم"
                value={event.checked_in_hospital?.name || "—"}
              />

              <InfoItem
                label="تم الحل بواسطة"
                value={event.resolved_by?.name || "—"}
              />
            </div>
          </section>

          {event.notes && (
            <section>
              <h3 className="mb-3 text-sm font-bold text-slate-900">
                ملاحظات البلاغ
              </h3>

              <p className="whitespace-pre-wrap rounded-xl border border-slate-200 p-4 text-sm leading-7 text-slate-700">
                {event.notes}
              </p>
            </section>
          )}
        </div>

        <div className="flex justify-end border-t border-slate-100 p-5">
          <button
            type="button"
            onClick={onClose}
            className="rounded-xl border border-slate-300 px-5 py-3 text-sm font-bold text-slate-700 transition hover:bg-slate-50"
          >
            إغلاق
          </button>
        </div>
      </div>
    </div>
  );
}

function InfoItem({
  label,
  value,
  dir,
  mono = false,
}: {
  label: string;
  value: string;
  dir?: "ltr" | "rtl";
  mono?: boolean;
}) {
  return (
    <div>
      <p className="text-xs font-medium text-slate-500">{label}</p>

      <p
        dir={dir}
        className={`mt-1 break-words text-sm font-bold text-slate-900 ${
          mono ? "font-mono" : ""
        }`}
      >
        {value}
      </p>
    </div>
  );
}

function StatCard({
  label,
  value,
  color,
}: {
  label: string;
  value: string;
  color: "slate" | "red" | "amber" | "emerald";
}) {
  const colors = {
    slate: "border-slate-200 bg-white text-slate-900",
    red: "border-red-100 bg-red-50 text-red-700",
    amber: "border-amber-100 bg-amber-50 text-amber-700",
    emerald: "border-emerald-100 bg-emerald-50 text-emerald-700",
  };

  return (
    <section
      className={`rounded-2xl border p-5 shadow-sm ${colors[color]}`}
    >
      <p className="text-sm font-medium opacity-80">{label}</p>

      <p className="mt-2 text-3xl font-bold">{value}</p>
    </section>
  );
}

function StatusBadge({
  status,
  label,
}: {
  status: FilterStatus;
  label: string;
}) {
  const styles = {
    active: "bg-red-50 text-red-700",
    checked_in: "bg-amber-50 text-amber-700",
    resolved: "bg-emerald-50 text-emerald-700",
    all: "bg-slate-100 text-slate-700",
  };

  return (
    <span
      className={`inline-flex rounded-full px-2.5 py-1 text-xs font-bold ${styles[status]}`}
    >
      {label}
    </span>
  );
}

function Alert({
  type,
  message,
  onClose,
}: {
  type: "error";
  message: string;
  onClose: () => void;
}) {
  return (
    <div className="mb-6 flex items-center justify-between gap-4 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700">
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

function getEventStatus(event: EmergencyEvent): {
  key: FilterStatus;
  label: string;
} {
  if (event.status === "resolved" || event.resolved_at) {
    return {
      key: "resolved",
      label: "تم الحل",
    };
  }

  if (event.checked_in_hospital || event.checked_in_at) {
    return {
      key: "checked_in",
      label: "تم الاستلام",
    };
  }

  return {
    key: "active",
    label: "نشط",
  };
}

function getGoogleMapsUrl(event: EmergencyEvent) {
  if (event.latitude === null || event.longitude === null) {
    return "#";
  }

  return `https://www.google.com/maps?q=${event.latitude},${event.longitude}`;
}

function formatDateTime(value: string) {
  try {
    return new Intl.DateTimeFormat("ar-DZ", {
      dateStyle: "medium",
      timeStyle: "short",
    }).format(new Date(value));
  } catch {
    return value;
  }
}