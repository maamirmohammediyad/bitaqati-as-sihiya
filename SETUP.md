# Bitaqati As-Sihiya — Setup Guide

This document explains how to prepare and run the Bitaqati As-Sihiya project locally.

## Project Components

- `backend-temp/` — Laravel backend and API
- `mobile/` — Flutter mobile application
- `dashboard-web/` — Next.js web dashboard

The backend uses PostgreSQL.

---

## 1. Prerequisites

Install:

- PHP
- Composer
- PostgreSQL
- Node.js and npm
- Flutter SDK
- Android/iOS development tools as required for mobile testing

Verify the installations:

```bash
php --version
composer --version
psql --version
node --version
npm --version
flutter --version
```

---

## 2. PostgreSQL

Create a PostgreSQL database named:

```text
bitaqati
```

The local backend configuration should use:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=bitaqati
DB_USERNAME=postgres
DB_PASSWORD=your_postgresql_password
```

Replace `your_postgresql_password` with the local PostgreSQL password.

Do not commit a real database password.

---

## 3. Backend Setup

Open a terminal in:

```text
backend-temp/
```

Install dependencies:

```bash
composer install
```

Create the environment file.

Linux/macOS:

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Generate the Laravel application key:

```bash
php artisan key:generate
```

Configure PostgreSQL in `.env`, then run:

```bash
php artisan migrate
```

Start the backend:

```bash
php artisan serve
```

The server normally runs at:

```text
http://127.0.0.1:8000
```

Use the address displayed by Laravel if it differs.

---

## 4. Firebase / FCM

The Flutter application includes Firebase services, including Firebase Cloud Messaging (FCM).

Firebase configuration must be provided through the appropriate platform configuration files and project settings when required.

The backend also contains configuration related to FCM notifications.

Do not publish private Firebase credentials, server keys, or other secrets.

If Firebase-dependent functionality is demonstrated, configure the required Firebase project locally.

---

## 5. Mobile Setup

Open:

```text
mobile/
```

Install dependencies:

```bash
flutter pub get
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run the application:

```bash
flutter run
```

The mobile application must be configured to use the running Laravel backend.

### Android Emulator

When the backend runs on the development computer, an Android emulator commonly accesses the host machine through:

```text
10.0.2.2
```

Therefore, configure the mobile API base URL appropriately instead of assuming that `localhost` refers to the host computer.

---

## 6. Web Dashboard Setup

Open:

```text
dashboard-web/
```

Install dependencies:

```bash
npm install
```

Configure the backend API URL:

```env
NEXT_PUBLIC_API_URL=http://127.0.0.1:8000
```

Use the actual backend URL when necessary.

Start development:

```bash
npm run dev
```

Build:

```bash
npm run build
```

Start the production build:

```bash
npm run start
```

Lint:

```bash
npm run lint
```

---

## 7. Running the Complete Project

Use separate terminals.

### Terminal 1 — Backend

```bash
cd backend-temp
php artisan serve
```

### Terminal 2 — Web Dashboard

```bash
cd dashboard-web
npm run dev
```

### Terminal 3 — Mobile

```bash
cd mobile
flutter run
```

Make sure all components point to the same backend environment.

---

## 8. Database Development

To recreate the local database from migrations:

```bash
php artisan migrate:fresh
```

**Warning:** this deletes the existing database tables and their data. Use it only with a disposable development database.

---

## 9. Environment and Security

Real environment files and secrets must remain local.

Never commit or submit:

- Database passwords
- Application secrets
- API keys
- Private Firebase credentials
- FCM server credentials
- Production secrets
- Real patient information
- Real medical records

The repository `.gitignore` excludes local environment and dependency files.

---

## 10. Verification Before Evaluation

### Backend

```bash
composer install
php artisan migrate
php artisan serve
```

### Mobile

```bash
flutter pub get
flutter analyze
flutter test
```

### Dashboard

```bash
npm install
npm run lint
npm run build
```

Also perform a manual test of the main application flows and available roles.

---

## 11. Main User Roles

The platform includes:

### Patient

Uses the mobile application to access healthcare-related information and services.

### Guardian

Can access and manage information related to connected patients according to the implemented permissions.

### Healthcare Staff

The implemented healthcare staff roles include:

- Hospital Administrator
- Doctor
- Receptionist
- Nurse

### Platform Owner

Manages platform-level operations through the Web Dashboard.

---

## 12. Evaluation Note

Bitaqati As-Sihiya is presented as a functional healthcare platform prototype for demonstration and evaluation.

A production deployment involving real patient data would require additional production infrastructure, security hardening, monitoring, backups, privacy/compliance procedures, and deployment-specific configuration.
