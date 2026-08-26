Bitaqati As-Sihiya — Web Dashboard

Overview

Bitaqati As-Sihiya (DZ-Health TECH) is a digital healthcare platform designed to organize healthcare information and services and connect patients, guardians, and healthcare facilities through a unified system.

This directory contains the Web Dashboard, which provides management interfaces for both the Platform Owner and Hospital Administrators.

The dashboard communicates with the Laravel backend through APIs and provides access to functionality according to the authenticated user's role and permissions.

---

Dashboard Roles

The Web Dashboard provides two main administrative levels:

- Platform Owner
- Hospital Administrator

Each level has its own responsibilities and access to different parts of the platform.

---

1. Platform Owner Dashboard

The Platform Owner is responsible for managing and monitoring the platform at the system level.

The Platform Owner dashboard provides access to platform-wide operations, including:

Dashboard

Provides an overview of the platform and its main administrative information.

Users

Provides access to user management across the platform.

Hospitals

Provides functionality for managing and monitoring registered hospitals.

Emergencies

Provides access to emergency-related information across the platform.

Verification Requests

Provides access to verification requests that require platform-level review.

Account Recovery Requests

Provides access to account recovery requests submitted through the platform.

The Platform Owner dashboard is organized under the "/admin" application area.

---

2. Hospital Administrator Dashboard

The Hospital Administrator is responsible for managing the operations and users of a specific hospital.

The Hospital Administrator dashboard provides access to hospital-level functionality, including:

Dashboard

Provides an overview of the hospital and its activities.

Patients

Provides access to patient-related information and hospital patient management.

Staff

Provides functionality for managing the hospital's staff.

Emergencies

Provides access to emergency-related information associated with the hospital.

Password Settings

Allows the authenticated hospital administrator to manage their password.

The Hospital Administrator dashboard is organized under the "/hospital" application area.

---

Access Control

The dashboard separates platform-level and hospital-level functionality according to the authenticated user's role.

Platform Owner

Has access to platform-wide management functionality.

Hospital Administrator

Has access to functionality related to their hospital.

This separation helps prevent users from accessing administrative operations outside the scope of their responsibilities.

---

Authentication

The dashboard includes authentication and account management functionality, including:

- Login
- Forgot Password
- Reset Password
- Account Recovery
- Account Recovery Completion

Authenticated API requests use a Bearer access token when communicating with the backend.

---

Backend Integration

The Web Dashboard communicates with the Laravel backend through HTTP API requests.

The API client:

- Uses "NEXT_PUBLIC_API_URL" as the backend API base URL.
- Uses the browser "fetch" API for HTTP requests.
- Supports authenticated requests using a Bearer token.
- Processes JSON responses.
- Handles API and HTTP errors.

The backend acts as the central API layer connecting the dashboard with the platform's data and services.

---

Application Structure

The dashboard uses the Next.js App Router structure.

dashboard-web/
├── public/
├── src/
│   ├── app/
│   │   ├── admin/
│   │   │   ├── account-recovery-requests/
│   │   │   ├── dashboard/
│   │   │   ├── emergencies/
│   │   │   ├── hospitals/
│   │   │   ├── login/
│   │   │   ├── users/
│   │   │   └── verification-requests/
│   │   │
│   │   ├── hospital/
│   │   │   ├── dashboard/
│   │   │   ├── emergencies/
│   │   │   ├── patients/
│   │   │   ├── settings/
│   │   │   │   └── password/
│   │   │   └── staff/
│   │   │
│   │   ├── account-recovery/
│   │   ├── forgot-password/
│   │   ├── reset-password/
│   │   ├── terms/
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   │
│   ├── components/
│   │   └── admin/
│   │       └── AdminShell.tsx
│   │
│   └── lib/
│       ├── api.ts
│       └── auth.ts
│
├── package.json
├── next.config.ts
├── tsconfig.json
└── eslint.config.mjs

---

Technologies

The Web Dashboard is built using:

- Next.js 16
- React 19
- TypeScript
- Tailwind CSS 4
- ESLint

These technologies are defined in the project's "package.json".

---

Development

Requirements

Make sure the following are installed:

- Node.js
- npm

Installation

Install the project dependencies:

npm install

Environment Configuration

Configure the backend API URL using the following environment variable:

NEXT_PUBLIC_API_URL=your_backend_api_url

Run the Development Server

npm run dev

Build for Production

npm run build

Start the Production Server

npm run start

Lint

npm run lint

---

Integration with the Bitaqati As-Sihiya Platform

The Web Dashboard is one of the main components of the Bitaqati As-Sihiya platform.

                         Bitaqati As-Sihiya
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
        Flutter Mobile    Web Dashboard    Laravel Backend
                                │               │
                                └───────┬───────┘
                                        │
                                        ▼
                                    Database

The Web Dashboard provides administrative interfaces, while the Laravel backend handles the central business logic, authentication, authorization, and data operations.

---

Project Goal

The goal of the Web Dashboard is to provide appropriate management interfaces for the different administrative levels of the Bitaqati As-Sihiya platform.

The Platform Owner manages the platform at the system level, while the Hospital Administrator manages the operations and resources of their hospital.

This separation provides a clearer and more controlled management structure for the healthcare platform.