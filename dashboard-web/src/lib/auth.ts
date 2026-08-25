export type DashboardUser = {
  id: string;
  name: string;
  email: string | null;
  role: string;
};

const TOKEN_KEY = "bitaqati_dashboard_token";
const USER_KEY = "bitaqati_dashboard_user";

/*
  مفاتيح النسخة القديمة؛ نحذفها أيضًا حتى لا تبقى جلسة قديمة في المتصفح.
*/
const LEGACY_TOKEN_KEY = "bitaqati_admin_token";
const LEGACY_USER_KEY = "bitaqati_admin_user";

export function saveDashboardSession(token: string, user: DashboardUser) {
  if (typeof window === "undefined") {
    return;
  }

  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function getDashboardToken(): string | null {
  if (typeof window === "undefined") {
    return null;
  }

  return localStorage.getItem(TOKEN_KEY);
}

export function getDashboardUser(): DashboardUser | null {
  if (typeof window === "undefined") {
    return null;
  }

  const savedUser = localStorage.getItem(USER_KEY);

  if (!savedUser) {
    return null;
  }

  try {
    return JSON.parse(savedUser) as DashboardUser;
  } catch {
    localStorage.removeItem(USER_KEY);
    return null;
  }
}

export function clearDashboardSession() {
  if (typeof window === "undefined") {
    return;
  }

  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);

  localStorage.removeItem(LEGACY_TOKEN_KEY);
  localStorage.removeItem(LEGACY_USER_KEY);
}

export function isSuperAdmin(user: DashboardUser | null): boolean {
  return user?.role === "super_admin";
}

export function isHospitalAdmin(user: DashboardUser | null): boolean {
  return user?.role === "health_worker";
}

/*
  توافق مؤقت مع الصفحات الحالية التي تستعمل أسماء Admin.
*/
export type AdminUser = DashboardUser;
export const saveAdminSession = saveDashboardSession;
export const getAdminToken = getDashboardToken;
export const getAdminUser = getDashboardUser;
export const clearAdminSession = clearDashboardSession;