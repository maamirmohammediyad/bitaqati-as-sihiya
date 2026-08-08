# UI/UX Wireframes (Textual)

## Design System

| Element | Specification |
|---------|---------------|
| Primary Color | `#2563EB` (Blue) |
| Success/Health | `#10B981` (Green) |
| Danger | `#DC2626` (Red) |
| Background | `#FFFFFF` + glass effect |
| Card Style | Border radius 16, soft shadow, semi-transparent white background with blur |
| Arabic Font | Cairo (primary), Tajawal (secondary) |
| Latin Font | Inter |
| Navigation | Bottom Navigation Bar (Material 3) |
| Theme | Material 3 with dynamic color support |

---

## Patient Flow

### 1. Onboarding Screen

```
┌──────────────────────────────────────┐
│                                      │
│         [App Logo / Illustration]     │
│                                      │
│          "Bitaqati As-Sihiya"        │
│         Your Health, Your Card       │
│                                      │
│   ┌──────────────────────────────┐   │
│   │       Get Started            │   │  ← Primary button (blue)
│   └──────────────────────────────┘   │
│                                      │
│   ┌──────────────────────────────┐   │
│   │     I Already Have Account   │   │  ← Text button
│   └──────────────────────────────┘   │
│                                      │
│         Page indicators (3 dots)     │
│                                      │
└──────────────────────────────────────┘
```

**Layout:** Full-screen illustration at top, branding text, two CTA buttons at bottom. Page indicator for swipeable feature slides.

### 2. Registration Screen (Patient)

```
┌──────────────────────────────────────┐
│  ← Back         Register            │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  National ID Number          │    │  ← Text field with flag icon
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │  First Name                  │    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │  Last Name                   │    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │  Password                    │    │  ← With visibility toggle
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │  Confirm Password            │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │     Create Account           │    │  ← Primary button
│  └──────────────────────────────┘    │
│                                      │
│  "You can complete your profile      │
│   later"                             │
│                                      │
└──────────────────────────────────────┘
```

### 3. Login Screen

```
┌──────────────────────────────────────┐
│  ← Back         Login               │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  National ID Number          │    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │  Password                    │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │     Sign In                  │    │
│  └──────────────────────────────┘    │
│                                      │
│  Forgot Password?                    │
│                                      │
│  ──────── Or continue with ────────  │
│                                      │
│  [Patient]          [Guardian]        │  ← Role toggle chips
│                                      │
└──────────────────────────────────────┘
```

### 4. Patient Home Dashboard

```
┌──────────────────────────────────────┐
│  Good morning, Ahmed 👋            │
│  ┌──────────────────────────────┐   │
│  │ ┌────┐                       │   │
│  │ │ 🩺 │ Your Health Card      │   │  ← Glass card with avatar & QR
│  │ └────┘ Tap to view           │   │
│  │ Blood Group: A+              │   │
│  └──────────────────────────────┘   │
│                                      │
│  Quick Actions:                      │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
│  │ 📋 │ │ 📁 │ │ 🏥 │ │ 🆘 │  │  ← 4 grid action cards
│  │Record│ │Files│ │Hosp │ │ SOS │  │
│  └─────┘ └─────┘ └─────┘ └─────┘  │
│                                      │
│  Recent Activity:                    │
│  ┌──────────────────────────────┐   │
│  │ 📄 Blood test uploaded 2h ago│   │  ← Timeline list
│  │ 📞 Emergency contact added   │   │
│  │ 💊 Medication list updated   │   │
│  └──────────────────────────────┘   │
│                                      │
│  ─── Bottom Navigation ───           │
│  🏠Home 💳Card 📋Record 📁Files 🏥Hosp
│                                      │
└──────────────────────────────────────┘
```

**Bottom Nav (Patient):**
| Icon | Label |
|------|-------|
| 🏠 | Home |
| 💳 | Health Card |
| 📋 | Medical Record |
| 📁 | Files |
| 🏥 | Hospitals |

**Note:** SOS button is a floating action button (FAB) visible across all screens. Settings gear in top-right corner.

### 5. Health Card Screen

```
┌──────────────────────────────────────┐
│  ←          My Health Card          ⚙️│
│                                      │
│  ┌──────────────────────────────┐    │
│  │  ┌──────────────────────┐   │    │
│  │  │   [QR Code]          │   │    │  ← Large QR code in center
│  │  │                      │   │    │
│  │  └──────────────────────┘   │    │
│  │                              │    │
│  │  ┌──────────────────────┐   │    │
│  │  │  [Avatar Photo]      │   │    │
│  │  └──────────────────────┘   │    │
│  │  Ahmed Al-Saud               │    │
│  │  Patient Code: HLT-A8F7...   │    │
│  │                              │    │
│  │  🩸 Blood Type: A+          │    │
│  │  ⚕️ Chronic: Diabetes T2    │    │
│  │  ⚠️ Allergies: Penicillin   │    │
│  │  📞 Emergency: +96650...    │    │
│  │                              │    │
│  │  Emergency Contacts:         │    │
│  │  ┌──────────────────────┐   │    │
│  │  │ Khalid Ahmed (Father) │   │    │
│  │  │ +966501234567         │   │    │
│  │  └──────────────────────┘   │    │
│  │                              │    │
│  └──────────────────────────────┘    │
│                                      │
│  [Share Card]    [Regenerate QR]     │
│                                      │
└──────────────────────────────────────┘
```

**Design:** Digital card styled like a modern bank card — white glass with gradient accent border, drop shadow, rounded corners. QR code takes up left portion. Personal info on the right.

### 6. Medical Record Screen

```
┌──────────────────────────────────────┐
│  ←        Medical Record           ⚙️ │
│                                      │
│  [Edit] button (top right)           │
│                                      │
│  ┌── Personal Information ───────┐   │
│  │ 📅 DOB: May 15, 1990          │   │
│  │ ⚧ Gender: Male               │   │
│  │ 📏 Height: 175 cm            │   │
│  │ ⚖️ Weight: 72 kg             │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌── Medical Information ────────┐   │
│  │ 🩸 Blood Group: A+            │   │
│  │ 💊 Chronic Diseases:          │   │
│  │    • Diabetes Type 2          │   │
│  │ ⚠️ Allergies:                 │   │
│  │    • Penicillin               │   │
│  │    • Peanuts                  │   │
│  │ 💊 Current Medications:       │   │
│  │    • Metformin 500mg          │   │
│  │ 🏥 Previous Surgeries:        │   │
│  │    • Appendectomy (2010)      │   │
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

**Guardian version:** Has a "patient selector" dropdown at the top to switch between linked patients. Edit buttons are present (with audit-logged changes).

### 7. Medical Files Screen

```
┌──────────────────────────────────────┐
│  ←        Medical Files            ⚙️ │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ + Upload New File            │    │  ← FAB or sticky header button
│  └──────────────────────────────┘    │
│                                      │
│  Filter chips: [All] [Analysis] [X-Ray] [Prescription] [PDF]
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 📄 blood_test_june2026.pdf  │    │  ← File card
│  │    Analysis • 240 KB        │    │
│  │    Uploaded: Jun 15, 2026   │    │
│  │    [Download] [Delete]      │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 🖼️ chest_xray_front.jpg     │    │  ← Image thumbnail
│  │    X-Ray • 1 MB             │    │
│  │    Uploaded: Jun 10, 2026   │    │
│  │    [Preview] [Delete]       │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 📋 prescription_may2026.pdf │    │
│  │    Prescription • 50 KB     │    │
│  │    Uploaded: May 20, 2026   │    │
│  │    [Download] [Delete]      │    │
│  └──────────────────────────────┘    │
│                                      │
└──────────────────────────────────────┘
```

**Upload flow:** Bottom sheet with file type selector + file picker. Shows progress indicator during upload. After upload, file appears in the list.

### 8. Hospitals Screen

```
┌──────────────────────────────────────┐
│  ←        Nearby Hospitals         ⚙️ │
│                                      │
│  [Google Map taking 40% of screen]   │
│  ┌──────────────────────────────┐    │
│  │ 🗺️ Map showing pins of      │    │
│  │    nearby hospitals          │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 🏥 King Faisal Hospital      │    │  ← Hospital card
│  │    📍 2.5 km away            │    │
│  │    📞 +966114644444          │    │
│  │    [Call] [Navigate]         │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 🏥 Saudi German Hospital     │    │
│  │    📍 5.8 km away            │    │
│  │    📞 +966118200200          │    │
│  │    [Call] [Navigate]         │    │
│  └──────────────────────────────┘    │
│                                      │
└──────────────────────────────────────┘
```

**Behavior:** Requests GPS permission on first load. Shows loading skeleton while determining location. Map pins are color-coded: green for available, red for full (future feature).

### 9. SOS Emergency Screen

```
┌──────────────────────────────────────┐
│                                      │
│            ⚠️ EMERGENCY ⚠️          │
│                                      │
│      ┌──────────────────────┐        │
│      │                      │        │
│      │       🆘             │        │
│      │    TAP TO SEND       │        │
│      │    EMERGENCY ALERT   │        │
│      │                      │        │
│      │   (Big red pulsating │        │
│      │    circle button)    │        │
│      │                      │        │
│      └──────────────────────┘        │
│                                      │
│  Your current location will be       │
│  sent to your guardians.             │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ Current Location: Riyadh     │    │  ← GPS status indicator
│  │ 📍 24.7136, 46.6753         │    │
│  └──────────────────────────────┘    │
│                                      │
│  Guardians notified: 2               │
│                                      │
└──────────────────────────────────────┘
```

**Emergency Mode State (after SOS triggered):**
- Screen turns red/dark with pulsing banner
- "Emergency Active — Guardians Notified" status bar
- "Resolve Emergency" button appears to deactivate
- App-wide banner on all screens
- Custom notification sound playing

### 10. Settings Screen

```
┌──────────────────────────────────────┐
│  ←             Settings             │
│                                      │
│  ┌── Account ─────────────────────┐  │
│  │ 👤 Profile Information         │  │
│  │ 🔑 Change Password            │  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌── Preferences ────────────────┐  │
│  │ 🌐 Language [English / العربية]│  │  ← Toggle between languages
│  │ 🌙 Dark Mode [On/Off]         │  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌── Notifications ──────────────┐  │
│  │ 🔔 Push Notifications [On/Off]│  │
│  │ 📧 Email Notifications [On/Off]│  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌── Privacy ────────────────────┐  │
│  │ 📱 Manage Device Tokens       │  │
│  │ 🗑️ Delete Account            │  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌── About ──────────────────────┐  │
│  │ ℹ️ Version 1.0.0              │  │
│  │ 📄 Terms of Service           │  │
│  │ 🔒 Privacy Policy             │  │
│  └───────────────────────────────┘  │
│                                      │
│  [Log Out]                           │
│                                      │
└──────────────────────────────────────┘
```

---

## Guardian Flow

### Guardian Home Dashboard

```
┌──────────────────────────────────────┐
│  Good morning, Fatima 👋            │
│                                      │
│  ┌── My Linked Patients ──────────┐  │
│  │ ┌──────────────────────────┐   │  │
│  │ │ 👤 Ahmed Al-Saud          │   │  │  ← Patient card with status
│  │ │    🟢 Profile: Complete   │   │  │
│  │ │    📍 Location: Available │   │  │
│  │ │    [View Details →]       │   │  │
│  │ └──────────────────────────┘   │  │
│  │ ┌──────────────────────────┐   │  │
│  │ │ 👤 Sara Al-Saud           │   │  │  ← Multiple patients
│  │ │    🟡 Profile: Incomplete │   │  │
│  │ │    📍 Location: No consent│   │  │
│  │ │    [View Details →]       │   │  │
│  │ └──────────────────────────┘   │  │
│  │                                │  │
│  │ [+ Link New Patient]           │  │
│  └────────────────────────────────┘  │
│                                      │
│  Recent Emergency Alerts:            │
│  ┌──────────────────────────────┐    │
│  │ ⚠️ Ahmed — Jun 15, 10:00 AM │    │  ← Red alert card
│  │    Resolved at 10:05 AM     │    │
│  └──────────────────────────────┘    │
│                                      │
│  ─── Bottom Navigation ───           │
│  🏠Home 💳Card 📋Record 📁Files 📍Loc
│                                      │
└──────────────────────────────────────┘
```

**Bottom Nav (Guardian):**
| Icon | Label |
|------|-------|
| 🏠 | Home |
| 💳 | Patient Card |
| 📋 | Medical Record |
| 📁 | Files |
| 📍 | Location |
| 🔔 | Notifications (with badge) |
| 🆘 | Emergency History |

### Guardian: Link Patient Screen

```
┌──────────────────────────────────────┐
│  ←      Link to a Patient           │
│                                      │
│  "Enter the patient's unique code    │
│   to link their profile to your      │
│   account."                          │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  Patient Code                │    │
│  │  HLT-A8F7-K29M-Q4A2         │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  Relationship to Patient     │    │  ← Dropdown
│  │  Mother ▼                    │    │
│  └──────────────────────────────┘    │
│  Options: Father, Mother, Husband,   │
│  Wife, Son, Daughter, Brother,       │
│  Sister, Other                       │
│                                      │
│  ┌──────────────────────────────┐    │
│  │     Link to Patient          │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ No code? Ask the patient to  │    │
│  │ share their code from their  │    │
│  │ Health Card settings.        │    │
│  └──────────────────────────────┘    │
│                                      │
└──────────────────────────────────────┘
```

### Guardian: Patient Location Screen

```
┌──────────────────────────────────────┐
│  ←    Ahmed's Location             │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 🗺️ [Full Screen Map]        │    │
│  │                              │    │
│  │    📍 Patient's current      │    │
│  │       position pin           │    │
│  │                              │    │
│  │    🏠 Patient's home address │    │
│  └──────────────────────────────┘    │
│                                      │
│  Last updated: 2 minutes ago         │
│                                      │
│  [Direction to Patient]              │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ ⚠️ Location consent was      │    │  ← If no consent
│  │    not granted by patient.   │    │
│  │    Request consent from      │    │
│  │    patient settings.         │    │
│  └──────────────────────────────┘    │
│                                      │
└──────────────────────────────────────┘
```

---

## Admin Web Dashboard (Laravel Blade / Vue)

### Main Layout

```
┌──────────────────────────────────────────────┐
│ 🏥 Bitaqati Admin  [Search]  🔔  👤 Admin   │  ← Top navbar
├──────────┬───────────────────────────────────┤
│          │                                   │
│ Sidebar  │  Main Content Area                │
│          │                                   │
│ 📊       │  ┌── Dashboard Stats ──────────┐  │
│   Dashboard│  │ Users: 1,234              │  │
│ 👥       │  │ Patients: 890              │  │
│   Users  │  │ Guardians: 340             │  │
│ 🏥       │  │ Files: 4,567               │  │
│   Patients│  │ Emergencies: 23 (today)   │  │
│ 👤       │  └────────────────────────────┘  │
│   Guardians│                                   │
│ 📁       │  ┌── Recent Activity ──────────┐  │
│   Files  │  │ [Timeline of recent actions] │  │
│ 🆘       │  └────────────────────────────┘  │
│   Emergencies│                               │
│ 📋       │                                   │
│   Audit Logs│                                │
│ ⚙️       │                                   │
│   Settings│                                   │
│          │                                   │
└──────────┴───────────────────────────────────┘
```

**Pages:**
1. **Dashboard** — Stats cards, recent activity feed, charts (registrations/day, emergencies/week)
2. **Users** — DataTable with search, filter by role, pagination, export
3. **Patients** — Patient list with profile completion status, linked guardians count
4. **Guardians** — Guardian list with linked patients, relationship, consent status
5. **Medical Files** — All files across all patients, with preview and delete
6. **Emergencies** — Emergency events list with status, location map, timeline
7. **Audit Logs** — Full audit trail, searchable by action, user, date range
8. **Settings** — App settings, admin user management, rate limiting config
