Bitaqati As-Sihiya — Backend API

Overview

Bitaqati As-Sihiya (DZ-Health TECH) is a digital healthcare system that provides services for patients, guardians, and healthcare facilities.

This directory contains the Laravel backend of the system. It provides the API used by the mobile application and the web dashboard and handles authentication, user access, healthcare-related data, hospital operations, and other core system services.

---

Main Responsibilities

The backend provides services for:

- Patient and guardian registration.
- User authentication and logout.
- User profile management.
- Password reset and account recovery.
- Account verification documents.
- Patient medical information.
- Patient medications and hospital medications.
- Hospital management and hospital staff.
- Hospital patient management.
- Medical records.
- Emergency-related services.
- Patient QR code functionality.
- Hospital patient QR functionality.
- Notifications.
- Audit logging.
- File and document storage.

These capabilities are implemented through the API routes and the corresponding controllers and services in the application.

---

User Roles

The system supports healthcare-related users with different responsibilities and access levels.

Patient

Patients can register and authenticate through the API and access the healthcare services and information available to their account.

Guardian

Guardians can register and authenticate and access the services associated with their role.

Healthcare Staff

Healthcare staff operate within healthcare facilities and include:

- Hospital Administrator
- Doctor
- Receptionist
- Nurse

The backend provides hospital, staff, patient, medical-file, medication, and dashboard-related API endpoints to support healthcare facility operations.

---

API

The backend provides HTTP API endpoints consumed by the system's client applications.

The API includes public endpoints such as:

- Patient registration
- Guardian registration
- Login
- Password reset
- Account recovery

Authenticated endpoints are protected using Laravel Sanctum.

The API also provides endpoints related to:

- Authentication and profiles
- Patients
- Hospitals
- Hospital staff
- Medical files and records
- Medications
- Emergency services
- QR-based services
- Account verification

---

Architecture

The backend is organized into several application layers and components.

Controllers

Controllers handle incoming API requests and coordinate the corresponding application operations.

The project includes controllers for authentication, patients, hospitals, medical profiles, medications, emergency services, QR functionality, hospital dashboards, and other system operations.

Domain

The "app/Domain" directory contains:

- Actions
- Enums
- Models

This structure is used to organize domain-related logic and application entities.

Services

The backend includes dedicated services for specific operations, including:

- "AuditLogService"
- "FCMService"
- "SupabaseStorageService"

These services isolate reusable functionality related to audit logging, Firebase Cloud Messaging, and Supabase storage.

---

Authentication

Authentication is implemented using Laravel Sanctum.

Authenticated API routes use the "auth:sanctum" middleware to protect access to private operations.

The backend also provides functionality for:

- Login
- Logout
- Password reset
- Password update
- Account recovery
- Profile management

---

Technologies

The backend is built with:

- PHP 8.2+
- Laravel 12
- Laravel Sanctum
- Geocoder PHP
- Google Maps Geocoder Provider
- Guzzle HTTP Factory

Development and testing tools include:

- PHPUnit
- Laravel Pint
- Laravel Sail
- Faker
- Mockery

These dependencies are defined in the project's "composer.json".

---

External Services

The backend contains dedicated services for:

- Firebase Cloud Messaging (FCM) for notifications.
- Supabase Storage for storage-related operations.
- Google Maps Geocoding through the configured geocoder packages.

The corresponding service implementations are located in "app/Services".

---

Testing

The project includes a Laravel testing setup using PHPUnit.

The backend also defines a Composer test script that runs the Laravel test suite:

composer test

---

Project Structure

backend-temp/
├── app/
│   ├── Domain/
│   │   ├── Actions/
│   │   ├── Enums/
│   │   └── Models/
│   ├── Http/
│   │   └── Controllers/
│   └── Services/
├── bootstrap/
├── config/
├── database/
├── public/
├── resources/
├── routes/
├── storage/
├── tests/
├── artisan
├── composer.json
└── phpunit.xml

---

Setup

Make sure PHP 8.2+, Composer, and the required project dependencies are installed.

Install PHP dependencies:

composer install

Create the environment file:

cp .env.example .env

Generate the Laravel application key:

php artisan key:generate

Configure the required environment variables in ".env", then run the database migrations:

php artisan migrate

The project also provides Composer scripts for setup, development, and testing.

---

Development

The project defines a development script that starts the Laravel server, queue listener, log viewer, and Vite development process together:

composer run dev

---

Project Goal

The backend serves as the central API layer of Bitaqati As-Sihiya, connecting the mobile application and web dashboard with the system's healthcare data and services.

Its main purpose is to provide a structured backend for authentication, role-based access, patient and hospital operations, medical information, emergency services, QR functionality, notifications, and related healthcare operations.