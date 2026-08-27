# Bitaqati As-Sihiya — Mobile Application

The Bitaqati As-Sihiya mobile application is the mobile component of the
Bitaqati As-Sihiya digital healthcare platform.

It is built with Flutter and communicates with the Laravel backend API to provide
healthcare-related services for patients, guardians, and healthcare staff.

---

## Overview

Bitaqati As-Sihiya aims to provide a unified digital platform that connects
patients and their guardians with healthcare institutions and healthcare staff.

The mobile application provides users with access to their relevant healthcare
information and platform services, while healthcare staff can interact with
patient and emergency-related information according to their assigned role.

---

## User Roles

The mobile application supports the following user categories.

### Patient

Patients can use the application to access and manage the healthcare-related
information and services available to their account.

### Guardian

Guardians can use the application in relation to the patients associated with
their account.

### Healthcare Staff

Healthcare staff are associated with hospitals and include the following roles:

- Doctor
- Nurse
- Receptionist
- Staff
The available functionality depends on the user's assigned role and permissions.

---

## Main Features

The mobile application includes functionality related to:

- User authentication
- Account verification
- Account recovery
- Patient profiles
- Guardian relationships
- Medical information
- Medical files
- Patient medications
- Emergency-related functionality
- QR code functionality
- Push notifications

The application communicates with the backend API for data management and
server-side operations.

---

## Firebase

The mobile application integrates with Firebase for Firebase-dependent
functionality, including Firebase Cloud Messaging (FCM).

### Android Configuration

Android requires the Firebase configuration file:

```text
android/app/google-services.json

iOS Configuration

iOS requires the Firebase configuration file:

ios/Runner/GoogleService-Info.plist

These configuration files are environment/project-specific and are intentionally not included in the public repository.

Firebase-dependent features require valid Firebase configuration.


---

Backend API

The mobile application communicates with the Bitaqati As-Sihiya Laravel backend through HTTP API requests.

The backend is responsible for server-side operations, authentication, authorization, data management, and communication with the PostgreSQL database.

The backend project is located at:

../backend-temp/


---

Technology Stack

Flutter

Dart

Firebase

Firebase Cloud Messaging (FCM)

Laravel Backend API

PostgreSQL



---

Requirements

Before running the application, make sure the following are installed:

Flutter SDK

Dart SDK

Android Studio or another supported Android development environment

Xcode for iOS development on macOS

A configured Firebase project for Firebase-dependent functionality

A running instance of the Bitaqati As-Sihiya backend API



---

Installation

From the mobile application directory:

cd mobile

Install Flutter dependencies:

flutter pub get

Check the project for analysis issues:

flutter analyze

Run the available tests:

flutter test

Run the application:

flutter run


---

Firebase Setup

Firebase configuration must be completed locally before using Firebase-dependent features.

Android

Place the Firebase configuration file provided by the Firebase project at:

android/app/google-services.json

iOS

Add the Firebase configuration file provided by the Firebase project to:

ios/Runner/GoogleService-Info.plist

Do not commit private or project-specific credentials to the repository.


---

Backend Connection

The mobile application requires a running Bitaqati As-Sihiya backend API.

For local development, the mobile application should be configured to communicate with the locally running Laravel backend.

When deploying the application to another environment, the API endpoint must be updated accordingly.


---

Testing

The Flutter project can be checked using:

flutter analyze

and:

flutter test

These commands help identify static analysis issues and verify the available automated tests.


---

Project Structure

The mobile application is organized as a Flutter project:

mobile/
├── android/
├── ios/
├── lib/
├── test/
├── assets/
├── pubspec.yaml
└── README.md

The main application source code is located under:

lib/


---

Security

The following information must not be committed to the repository:

Private API credentials

Database passwords

Firebase private credentials

Private keys

Production environment files

Real patient medical information

Real medical documents


Only fictional demonstration data should be used for project evaluation.


---

Project Status

The Bitaqati As-Sihiya mobile application is part of the complete Bitaqati As-Sihiya platform and is intended for project demonstration, evaluation, and prototype use.

The platform consists of:

Flutter Mobile Application

Laravel Backend API

PostgreSQL Database

Web Dashboard


Additional security, infrastructure, monitoring, and compliance work would be required before using the platform in a production healthcare environment with real patient data.