# Bitaqati As-Sihiya — Web Dashboard

## Overview

Bitaqati As-Sihiya (DZ-Health TECH) is a digital healthcare platform designed
to organize healthcare information and services and connect patients, guardians,
healthcare staff, and healthcare facilities through a unified system.

This directory contains the Web Dashboard, which provides administrative
interfaces for the **Platform Owner** and **Hospital Administrators**.

The dashboard communicates with the Laravel backend through HTTP API requests
and provides functionality according to the authenticated user's role and
permissions.

---

## Dashboard Roles

The Web Dashboard provides two main administrative levels:

- Platform Owner
- Hospital Administrator

Each administrative level has its own responsibilities and access scope.

---

## 1. Platform Owner Dashboard

The Platform Owner manages the platform at the system level.

The Platform Owner dashboard includes the following areas:

### Dashboard

Provides an overview of the platform and its main administrative information.

### Users

Provides access to user management across the platform.

### Hospitals

Provides functionality for managing and monitoring registered hospitals.

### Emergencies

Provides access to emergency-related information across the platform.

### Verification Requests

Provides access to verification requests that require platform-level review.

### Account Recovery Requests

Provides access to account recovery requests submitted through the platform.

The Platform Owner dashboard is organized under the:

```text
/admin

application area.


---

2. Hospital Administrator Dashboard

The Hospital Administrator manages the operations and users of a specific hospital.

The Hospital Administrator dashboard includes the following areas:

Dashboard

Provides an overview of the hospital and its activities.

Patients

Provides access to patient-related information and hospital patient management.

Staff

Provides functionality for managing the hospital's staff.

Emergencies

Provides access to emergency-related information associated with the hospital.

Password Settings

Allows the authenticated Hospital Administrator to manage their password.

The Hospital Administrator dashboard is organized under the:

/hospital

application area.


---

Access Control

The dashboard separates platform-level and hospital-level functionality based on the authenticated user's role.

Platform Owner

Has access to platform-wide administrative functionality.

Hospital Administrator

Has access to functionality related to their assigned hospital.

This separation helps ensure that administrative operations remain within the scope of the user's responsibilities.


---

Authentication

The dashboard provides authentication and account-management functionality, including:

Login

Forgot Password

Reset Password

Account Recovery

Account Recovery Completion


Authenticated requests to the backend use a Bearer access token.


---

Backend Integration

The Web Dashboard communicates with the Laravel backend through HTTP API requests.

The API client:

Uses NEXT_PUBLIC_API_URL as the backend API base URL.

Uses the browser fetch API for HTTP requests.

Supports authenticated requests using a Bearer token.

Processes JSON responses.

Handles API and HTTP errors.


The Laravel backend acts as the central API layer responsible for the application's server-side operations, authentication, authorization, and data management.


---

Application Structure

The dashboard uses the Next.js App Router.

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

Next.js 16

React 19

TypeScript

Tailwind CSS 4

ESLint


The project's dependencies and versions are defined in package.json.


---

Development

Requirements

Make sure the following are installed:

Node.js

npm


Installation

Install the project dependencies:

npm install

Environment Configuration

Configure the Laravel backend API URL using:

NEXT_PUBLIC_API_URL=your_backend_api_url

Replace your_backend_api_url with the URL of the running Laravel backend.

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
                                  PostgreSQL

The Web Dashboard provides administrative interfaces, while the Laravel backend provides the central API layer for authentication, authorization, business logic, and data operations.


---

Administrative Structure

The platform follows a hierarchical administrative structure:

Bitaqati As-Sihiya
│
├── Platform Owner
│   └── Platform-level administration
│
└── Hospital
    └── Hospital Administrator
        └── Hospital-level administration

This structure separates platform-wide management from hospital-level management.


---

Project Goal

The goal of the Web Dashboard is to provide appropriate management interfaces for the different administrative levels of the Bitaqati As-Sihiya platform.

The Platform Owner manages the platform at the system level, while the Hospital Administrator manages the operations and resources of their assigned hospital.

This separation provides a clearer and more controlled administrative structure for the healthcare platform.


---

Security Notes

Sensitive configuration must not be committed to the repository.

Do not expose:

Database passwords

API secrets

Private keys

Production environment files

Real patient information

Real medical records


Environment-specific configuration should be provided locally.


---

Project Status

The Web Dashboard is an integral component of the Bitaqati As-Sihiya platform and is currently intended for:

Project demonstration

Evaluation

Prototype use


Additional infrastructure, security, monitoring, and deployment work would be required before operating the platform as a production healthcare system with real patient data.