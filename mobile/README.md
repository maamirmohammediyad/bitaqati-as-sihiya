Bitaqati As-Sihiya — Mobile Application

Overview

Bitaqati As-Sihiya (Digital Health Card) is a Flutter mobile application that provides healthcare-related services for patients, guardians, and healthcare staff.

The application is part of the Bitaqati As-Sihiya platform and communicates with the backend to provide authenticated healthcare services and access to information according to the user's role and permissions.

---

Main Purpose

The mobile application aims to provide a unified digital interface for accessing healthcare-related services and information.

It brings together different user roles and healthcare functions in one application while organizing access according to the responsibilities of each user.

---

Supported User Roles

The application includes dedicated features for the following roles:

Patient

The patient is one of the main users of the application and has access to patient-related healthcare services and information.

The mobile application includes a dedicated Patient feature module for patient-related functionality.

Guardian

The application provides a dedicated Guardian module for guardian-related services and access.

Healthcare Staff

Healthcare staff are supported through dedicated hospital and staff-related modules.

The healthcare staff roles include:

- Hospital Administrator
- Doctor
- Receptionist
- Nurse

The application contains dedicated functionality for hospital dashboards and hospital staff.

---

Main Features

The mobile application is organized into feature modules that cover the main areas of the system.

Authentication

The application provides authentication-related functionality through a dedicated "auth" feature.

Patient Services

Patient-related functionality is organized under the "patient" feature.

Guardian Services

Guardian-related functionality is organized under the "guardian" feature.

Hospital Services

The application includes hospital-related functionality and hospital information through dedicated hospital features.

Hospital Staff

Healthcare staff functionality is organized under the "hospital_staff" feature.

Hospital Dashboard

A dedicated "hospital_dashboard" feature provides functionality related to the hospital dashboard.

Medical Files

The application includes a dedicated "medical_files" feature for healthcare-related medical file functionality.

Emergency

Emergency-related functionality is provided through a dedicated "emergency" feature.

QR Code

The application includes QR-code functionality using QR generation and scanning capabilities.

Location and Maps

The application supports location-related functionality and map integration.

Files and Documents

The application includes functionality for selecting, opening, sharing, and handling files.

Notifications

The application includes Firebase messaging and local notification capabilities.

---

Application Architecture

The Flutter project is organized into common components, core functionality, and feature-specific modules.

mobile/
├── lib/
│   ├── common/
│   │   └── widgets/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── emergency/
│   │   ├── guardian/
│   │   ├── hospital_dashboard/
│   │   ├── hospital_staff/
│   │   ├── hospitals/
│   │   ├── medical_files/
│   │   ├── patient/
│   │   └── settings/
│   └── main.dart
├── assets/
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
└── test/

This organization separates shared components, core application functionality, and individual features, making the application easier to maintain and extend.

---

Technologies

The mobile application is built using Flutter and Dart.

State Management

- Flutter Riverpod
- Riverpod Generator

Navigation

- GoRouter

API Communication

- Dio
- HTTP

Authentication and Storage

- Firebase Authentication
- Flutter Secure Storage
- Shared Preferences

Notifications

- Firebase Cloud Messaging
- Flutter Local Notifications

Location and Maps

- Geolocator
- Google Maps Flutter

QR Code

- QR Flutter
- Mobile Scanner

File Handling

- File Picker
- File Selector
- Open File
- Path Provider
- Share Plus

UI and Assets

- Flutter ScreenUtil
- Flutter SVG
- Cached Network Image
- Shimmer
- Flutter Animate
- Lottie

The dependencies above are defined in the application's "pubspec.yaml".

---

Backend Integration

The mobile application communicates with the Bitaqati As-Sihiya backend to access the services provided by the system.

The backend is responsible for processing requests and managing the application's data and authentication, while the Flutter application provides the user interface and client-side functionality.

---

Development Requirements

The project uses Flutter with a Dart SDK constraint of:

>=3.12.0 <4.0.0

The application version currently defined in "pubspec.yaml" is:

1.0.0+1

---

Project Goal

The goal of the Bitaqati As-Sihiya mobile application is to provide a unified and organized digital healthcare experience for patients, guardians, and healthcare staff.

By bringing healthcare-related services into a single mobile application and organizing functionality according to user roles, the application contributes to easier access to healthcare information and services.

---

Part of the Bitaqati As-Sihiya Platform

The mobile application is one component of the complete Bitaqati As-Sihiya system, working together with the backend and web dashboard to provide an integrated healthcare platform.