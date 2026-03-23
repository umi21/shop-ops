"use client";

import React, { useEffect, useMemo, useState } from "react";
import PageTitle from "@/app/components/ui/PageTitle";
import Card from "@/app/components/ui/Card";
import {
  Activity,
  Bell,
  Building2,
  Clock3,
  KeyRound,
  ShieldCheck,
  User,
} from "lucide-react";

type ProfileDetails = {
  fullName: string;
  email: string;
  phone: string;
  role: string;
  branch: string;
  address: string;
  bio: string;
  timezone: string;
  language: string;
  emailAlerts: boolean;
  smsAlerts: boolean;
  twoFactorEnabled: boolean;
};

type ActivityItem = {
  id: number;
  title: string;
  description: string;
  timestamp: string;
};

type ApiUser = {
  id: string;
  name: string;
  email: string;
  phone: string;
  created_at: string;
  updated_at: string;
};

type ApiError = {
  error?: string;
  details?: string;
};

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080/api/v1";

const ACCESS_TOKEN_KEYS = ["token", "access_token", "authToken"];

const getAccessToken = () => {
  if (typeof window === "undefined") {
    return null;
  }

  for (const key of ACCESS_TOKEN_KEYS) {
    const value = window.localStorage.getItem(key);
    if (value) {
      return value;
    }
  }

  return null;
};

const parseApiError = async (response: Response) => {
  let body: ApiError | null = null;

  try {
    body = (await response.json()) as ApiError;
  } catch {
    body = null;
  }

  return body?.error || body?.details || `Request failed (${response.status})`;
};

const requestWithAuth = async <T,>(
  path: string,
  init: RequestInit = {},
): Promise<T> => {
  const token = getAccessToken();

  if (!token) {
    throw new Error("No auth token found. Please sign in again.");
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
      ...(init.headers ?? {}),
    },
  });

  if (!response.ok) {
    throw new Error(await parseApiError(response));
  }

  return (await response.json()) as T;
};

const defaultProfile: ProfileDetails = {
  fullName: "James Abera",
  email: "james.abera@merkato-mini.com",
  phone: "+251 91 234 5678",
  role: "Manager",
  branch: "Merkato Mini-Market",
  address: "Arada Sub City, Addis Ababa",
  bio: "Oversees daily store operations, inventory planning, and staff coordination.",
  timezone: "Africa/Addis_Ababa",
  language: "English",
  emailAlerts: true,
  smsAlerts: false,
  twoFactorEnabled: true,
};

const recentActivity: ActivityItem[] = [
  {
    id: 1,
    title: "Updated product restock threshold",
    description: "Set low-stock alert for Rice (25kg) to 15 units.",
    timestamp: "Today, 09:14 AM",
  },
  {
    id: 2,
    title: "Approved daily expense",
    description: "Approved transport expense of Br 1,950.00.",
    timestamp: "Yesterday, 05:22 PM",
  },
  {
    id: 3,
    title: "Signed in from dashboard",
    description: "Successful login from in-store terminal.",
    timestamp: "Yesterday, 08:02 AM",
  },
];

const inputClassName =
  "w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-800 outline-none transition focus:border-indigo-300 focus:ring-2 focus:ring-indigo-100";

const mapApiUserToProfile = (user: ApiUser, current: ProfileDetails): ProfileDetails => ({
  ...current,
  fullName: user.name || current.fullName,
  email: user.email || "",
  phone: user.phone || "",
});

export default function ProfilePage() {
  const [savedProfile, setSavedProfile] = useState<ProfileDetails>(defaultProfile);
  const [draftProfile, setDraftProfile] = useState<ProfileDetails>(defaultProfile);
  const [isLoadingProfile, setIsLoadingProfile] = useState(true);
  const [isSavingProfile, setIsSavingProfile] = useState(false);
  const [profileError, setProfileError] = useState<string | null>(null);
  const [profileSuccess, setProfileSuccess] = useState<string | null>(null);

  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [isSavingPassword, setIsSavingPassword] = useState(false);
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [passwordSuccess, setPasswordSuccess] = useState<string | null>(null);

  const [isEditing, setIsEditing] = useState(false);

  const activeProfile = isEditing ? draftProfile : savedProfile;

  const initials = useMemo(() => {
    const tokens = activeProfile.fullName.trim().split(" ").filter(Boolean);
    if (tokens.length === 0) return "NA";
    return tokens
      .slice(0, 2)
      .map((part) => part[0]?.toUpperCase() ?? "")
      .join("");
  }, [activeProfile.fullName]);

  const handleFieldChange = <K extends keyof ProfileDetails>(
    key: K,
    value: ProfileDetails[K],
  ) => {
    setDraftProfile((prev) => ({ ...prev, [key]: value }));
  };

  const handleStartEdit = () => {
    setProfileError(null);
    setProfileSuccess(null);
    setDraftProfile(savedProfile);
    setIsEditing(true);
  };

  const handleCancel = () => {
    setProfileError(null);
    setProfileSuccess(null);
    setDraftProfile(savedProfile);
    setIsEditing(false);
  };

  const fetchProfile = async () => {
    setIsLoadingProfile(true);
    setProfileError(null);

    try {
      const user = await requestWithAuth<ApiUser>("/users/me", {
        method: "GET",
      });

      const mapped = mapApiUserToProfile(user, defaultProfile);
      setSavedProfile(mapped);
      setDraftProfile(mapped);
    } catch (error) {
      setProfileError(error instanceof Error ? error.message : "Failed to load profile");
    } finally {
      setIsLoadingProfile(false);
    }
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  const handleSave = async () => {
    setIsSavingProfile(true);
    setProfileError(null);
    setProfileSuccess(null);

    try {
      let nextProfile = { ...savedProfile };

      const nameChanged = draftProfile.fullName.trim() !== savedProfile.fullName.trim();
      const emailChanged = draftProfile.email.trim() !== savedProfile.email.trim();
      const phoneChanged = draftProfile.phone.trim() !== savedProfile.phone.trim();

      if (nameChanged || emailChanged) {
        const updatedUser = await requestWithAuth<ApiUser>("/users/me", {
          method: "PATCH",
          body: JSON.stringify({
            name: draftProfile.fullName.trim(),
            email: draftProfile.email.trim(),
          }),
        });

        nextProfile = mapApiUserToProfile(updatedUser, nextProfile);
      }

      if (phoneChanged) {
        const updatedPhoneResponse = await requestWithAuth<Partial<ApiUser>>("/users/me/phone", {
          method: "PUT",
          body: JSON.stringify({
            phone: draftProfile.phone.trim(),
          }),
        });

        if (updatedPhoneResponse.phone || updatedPhoneResponse.name || updatedPhoneResponse.email) {
          nextProfile = mapApiUserToProfile(updatedPhoneResponse as ApiUser, {
            ...nextProfile,
            phone: draftProfile.phone.trim(),
          });
        } else {
          nextProfile = {
            ...nextProfile,
            phone: draftProfile.phone.trim(),
          };
        }
      }

      if (!nameChanged && !emailChanged && !phoneChanged) {
        setProfileSuccess("No changes to save.");
        setIsEditing(false);
        return;
      }

      setSavedProfile(nextProfile);
      setDraftProfile(nextProfile);
      setIsEditing(false);
      setProfileSuccess("Profile updated successfully.");
    } catch (error) {
      setProfileError(error instanceof Error ? error.message : "Failed to update profile");
    } finally {
      setIsSavingProfile(false);
    }
  };

  const handleResetDefaults = () => {
    setProfileSuccess(null);
    setProfileError(null);
    fetchProfile();
    setIsEditing(false);
  };

  const handleChangePassword = async () => {
    setPasswordError(null);
    setPasswordSuccess(null);

    if (!currentPassword || !newPassword || !confirmPassword) {
      setPasswordError("Please fill all password fields.");
      return;
    }

    if (newPassword !== confirmPassword) {
      setPasswordError("New password and confirmation do not match.");
      return;
    }

    setIsSavingPassword(true);

    try {
      await requestWithAuth<unknown>("/users/me/password", {
        method: "PUT",
        body: JSON.stringify({
          current_password: currentPassword,
          new_password: newPassword,
          confirm_password: confirmPassword,
        }),
      });

      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
      setPasswordSuccess("Password updated successfully.");
    } catch (error) {
      setPasswordError(error instanceof Error ? error.message : "Failed to update password");
    } finally {
      setIsSavingPassword(false);
    }
  };

  return (
    <div className="flex flex-col space-y-4">
      <PageTitle
        title="Profile"
        subtitle="Manage personal information, preferences, and security settings"
      />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <Card
          title="Role"
          value={savedProfile.role}
          icon={ShieldCheck}
          iconWrapperClass="bg-indigo-50 text-indigo-600"
          trend=""
          trendDirection="up"
          description="Current access level"
        />
        <Card
          title="Branch"
          value={savedProfile.branch}
          icon={Building2}
          iconWrapperClass="bg-emerald-50 text-emerald-600"
          trend=""
          trendDirection="up"
          description="Assigned store"
        />
        <Card
          title="Security"
          value={savedProfile.twoFactorEnabled ? "2FA On" : "2FA Off"}
          icon={KeyRound}
          iconWrapperClass="bg-amber-50 text-amber-600"
          trend=""
          trendDirection="up"
          description="Two-factor authentication"
        />
      </div>

      <div className="rounded-xl border border-slate-200 bg-white shadow-sm">
        <div className="flex flex-col gap-4 border-b border-slate-100 p-4 sm:p-6 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex items-center gap-4">
            <div className="h-16 w-16 rounded-full border border-indigo-200 bg-indigo-100 text-lg font-bold text-indigo-700 flex items-center justify-center">
              {initials}
            </div>
            <div className="min-w-0">
              <h2 className="text-lg font-semibold text-slate-900 break-words">{activeProfile.fullName}</h2>
              <p className="text-sm text-slate-500">{activeProfile.role}</p>
            </div>
          </div>

          <div className="flex w-full flex-col gap-2 sm:w-auto sm:flex-row sm:flex-wrap sm:items-center">
            {isEditing ? (
              <>
                <button
                  type="button"
                  onClick={handleCancel}
                  className="w-full rounded-lg border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 transition hover:bg-slate-50 sm:w-auto"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleSave}
                  disabled={isSavingProfile}
                  className="w-full rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-indigo-700 sm:w-auto"
                >
                  {isSavingProfile ? "Saving..." : "Save changes"}
                </button>
              </>
            ) : (
              <button
                type="button"
                onClick={handleStartEdit}
                className="w-full rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-indigo-700 sm:w-auto"
              >
                Edit profile
              </button>
            )}
            <button
              type="button"
              onClick={handleResetDefaults}
              disabled={isLoadingProfile}
              className="w-full rounded-lg border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 transition hover:bg-slate-50 sm:w-auto"
            >
              Reload profile
            </button>
          </div>
        </div>

        <div className="grid gap-6 p-4 sm:p-6 lg:grid-cols-2">
          <section className="space-y-4">
            {isLoadingProfile && (
              <p className="rounded-lg border border-blue-100 bg-blue-50 px-3 py-2 text-sm text-blue-700">
                Loading profile...
              </p>
            )}
            {profileError && (
              <p className="rounded-lg border border-rose-100 bg-rose-50 px-3 py-2 text-sm text-rose-700">
                {profileError}
              </p>
            )}
            {profileSuccess && (
              <p className="rounded-lg border border-emerald-100 bg-emerald-50 px-3 py-2 text-sm text-emerald-700">
                {profileSuccess}
              </p>
            )}

            <h3 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
              Personal Details
            </h3>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Full Name</span>
              {isEditing ? (
                <input
                  value={draftProfile.fullName}
                  onChange={(event) => handleFieldChange("fullName", event.target.value)}
                  className={inputClassName}
                />
              ) : (
                <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {savedProfile.fullName}
                </p>
              )}
            </label>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Email</span>
              {isEditing ? (
                <input
                  type="email"
                  value={draftProfile.email}
                  onChange={(event) => handleFieldChange("email", event.target.value)}
                  className={inputClassName}
                />
              ) : (
                <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {savedProfile.email}
                </p>
              )}
            </label>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Phone</span>
              {isEditing ? (
                <input
                  value={draftProfile.phone}
                  onChange={(event) => handleFieldChange("phone", event.target.value)}
                  className={inputClassName}
                />
              ) : (
                <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {savedProfile.phone}
                </p>
              )}
            </label>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Bio</span>
              {isEditing ? (
                <textarea
                  value={draftProfile.bio}
                  onChange={(event) => handleFieldChange("bio", event.target.value)}
                  className={`${inputClassName} min-h-24`}
                />
              ) : (
                <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {savedProfile.bio}
                </p>
              )}
            </label>
          </section>

          <section className="space-y-4">
            <h3 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
              Work and Preferences
            </h3>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Role</span>
              {isEditing ? (
                <input
                  value={draftProfile.role}
                  onChange={(event) => handleFieldChange("role", event.target.value)}
                  className={inputClassName}
                />
              ) : (
                <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {savedProfile.role}
                </p>
              )}
            </label>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Branch</span>
              {isEditing ? (
                <input
                  value={draftProfile.branch}
                  onChange={(event) => handleFieldChange("branch", event.target.value)}
                  className={inputClassName}
                />
              ) : (
                <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {savedProfile.branch}
                </p>
              )}
            </label>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Address</span>
              {isEditing ? (
                <input
                  value={draftProfile.address}
                  onChange={(event) => handleFieldChange("address", event.target.value)}
                  className={inputClassName}
                />
              ) : (
                <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {savedProfile.address}
                </p>
              )}
            </label>

            <div className="grid gap-3 sm:grid-cols-2">
              <label className="block space-y-1">
                <span className="text-xs font-medium text-slate-500">Timezone</span>
                {isEditing ? (
                  <input
                    value={draftProfile.timezone}
                    onChange={(event) => handleFieldChange("timezone", event.target.value)}
                    className={inputClassName}
                  />
                ) : (
                  <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                    {savedProfile.timezone}
                  </p>
                )}
              </label>

              <label className="block space-y-1">
                <span className="text-xs font-medium text-slate-500">Language</span>
                {isEditing ? (
                  <input
                    value={draftProfile.language}
                    onChange={(event) => handleFieldChange("language", event.target.value)}
                    className={inputClassName}
                  />
                ) : (
                  <p className="rounded-lg border border-slate-100 bg-slate-50 px-3 py-2 text-sm text-slate-700">
                    {savedProfile.language}
                  </p>
                )}
              </label>
            </div>
          </section>
        </div>
      </div>

        <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm sm:p-6">
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-slate-50 p-3">
            <User className="h-4 w-4 text-indigo-500" />
            <div>
              <p className="text-[11px] uppercase tracking-wide text-slate-500">Profile Status</p>
              <p className="text-sm font-medium text-slate-700">Active</p>
            </div>
          </div>
          <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-slate-50 p-3">
            <Clock3 className="h-4 w-4 text-indigo-500" />
            <div>
              <p className="text-[11px] uppercase tracking-wide text-slate-500">Local Timezone</p>
              <p className="text-sm font-medium text-slate-700">{savedProfile.timezone}</p>
            </div>
          </div>
          <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-slate-50 p-3">
            <Bell className="h-4 w-4 text-indigo-500" />
            <div>
              <p className="text-[11px] uppercase tracking-wide text-slate-500">Alerts</p>
              <p className="text-sm font-medium text-slate-700">
                {savedProfile.emailAlerts || savedProfile.smsAlerts ? "Enabled" : "Disabled"}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-3 rounded-lg border border-slate-100 bg-slate-50 p-3">
            <Activity className="h-4 w-4 text-indigo-500" />
            <div>
              <p className="text-[11px] uppercase tracking-wide text-slate-500">Sessions</p>
              <p className="text-sm font-medium text-slate-700">1 Active Device</p>
            </div>
          </div>
        </div>
      </div>

      <div className="flex flex-col w-full">
        <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm sm:p-6">
          <h3 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
            Security
          </h3>

          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            <label className="block space-y-1 sm:col-span-2">
              <span className="text-xs font-medium text-slate-500">Current Password</span>
              <input
                type="password"
                value={currentPassword}
                onChange={(event) => setCurrentPassword(event.target.value)}
                className={inputClassName}
                placeholder="Enter current password"
              />
            </label>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">New Password</span>
              <input
                type="password"
                value={newPassword}
                onChange={(event) => setNewPassword(event.target.value)}
                className={inputClassName}
                placeholder="Enter new password"
              />
            </label>

            <label className="block space-y-1">
              <span className="text-xs font-medium text-slate-500">Confirm Password</span>
              <input
                type="password"
                value={confirmPassword}
                onChange={(event) => setConfirmPassword(event.target.value)}
                className={inputClassName}
                placeholder="Confirm new password"
              />
            </label>
          </div>

          {passwordError && (
            <p className="mt-3 rounded-lg border border-rose-100 bg-rose-50 px-3 py-2 text-sm text-rose-700">
              {passwordError}
            </p>
          )}

          {passwordSuccess && (
            <p className="mt-3 rounded-lg border border-emerald-100 bg-emerald-50 px-3 py-2 text-sm text-emerald-700">
              {passwordSuccess}
            </p>
          )}

          <div className="mt-4 flex justify-end">
            <button
              type="button"
              onClick={handleChangePassword}
              disabled={isSavingPassword}
              className="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-indigo-700 disabled:cursor-not-allowed disabled:opacity-70"
            >
              {isSavingPassword ? "Updating..." : "Update password"}
            </button>
          </div>
        </div>


        <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm sm:p-6">
          <h3 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
            Recent Activity
          </h3>

          <div className="mt-4 space-y-3">
            {recentActivity.map((item) => (
              <div key={item.id} className="rounded-lg border border-slate-100 bg-slate-50 p-3">
                <p className="text-sm font-medium text-slate-700">{item.title}</p>
                <p className="mt-1 text-xs text-slate-500">{item.description}</p>
                <p className="mt-2 text-[11px] text-slate-400">{item.timestamp}</p>
              </div>
            ))}
          </div>
        </div>
      </div>


    
    </div>
  );
}
