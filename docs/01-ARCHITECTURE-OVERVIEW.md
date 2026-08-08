# Bitaqati As-Sihiya — Architecture Overview

## 1. High-Level System Context

```
┌──────────────────────────────────────────────────────────┐
│                  Mobile Apps (Flutter)                    │
│  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ Patient │  │ Guardian │  │ (Admin)  │  │  (Auth)  │ │
│  └────┬────┘  └─────┬────┘  └────┬─────┘  └────┬─────┘ │
│       │              │            │              │        │
└───────┼──────────────┼────────────┼──────────────┼────────┘
        │              │            │              │
        ▼              ▼            ▼              ▼
┌──────────────────────────────────────────────────────────┐
│              HTTPS / JSON REST API (Laravel)              │
│  ┌──────────────────────────────────────────────────────┐ │
│  │       Feature Modules (Auth, Patient, Guardian,      │ │
│  │       MedicalFiles, Emergency, Hospitals, Admin)     │ │
│  └──────────────────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────────────────┐ │
│  │       Infrastructure Services                        │ │
│  │  Supabase Storage  │  FCM Service  │  Geocoding      │ │
│  └──────────────────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────────────────┐ │
│  │       PostgreSQL Database                            │ │
│  └──────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

## 2. Technology Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| Mobile | Flutter 3.x, Dart 3.x | Cross-platform from single codebase |
| State Management | Riverpod 2.x | Compile-safe, testable, no BuildContext dependency |
| Backend | Laravel 11.x (API only) | Rapid development, clean syntax, rich ecosystem |
| Database | PostgreSQL 16 | ACID compliance, JSON support, rocky extension |
| Auth | JWT (via Laravel Sanctum or tymon/jwt-auth) | Stateless, mobile-friendly |
| Storage | Supabase Storage (S3-compatible) | Scalable file storage |
| Push | Firebase Cloud Messaging | Cross-platform push notifications |
| Maps | Google Maps API + geolocator | Hospital finder, SOS location |
| QR | qr_flutter | Health card QR generation |

## 3. Clean Architecture Layers

### Flutter (Mobile) — 3-Layer Clean Architecture

```
┌──────────────────────────────────────┐
│       Presentation Layer              │  UI, Widgets, Pages, Providers
│  (screens, widgets, providers)       │  Depends on Domain only
├──────────────────────────────────────┤
│       Domain Layer                    │  Business logic, entities, use cases
│  (entities, usecases, repos)         │  Framework-independent
├──────────────────────────────────────┤
│       Data Layer                      │  API calls, local storage, DTOs
│  (repositories, datasources,        │  Implements Domain interfaces
│   models)                            │
└──────────────────────────────────────┘
```

**Dependency Rule:** Presentation → Domain ← Data
(Domain has NO dependencies on other layers)

### Laravel (Backend) — Modular Structure

```
┌──────────────────────────────────────┐
│       HTTP Layer                      │  Controllers, Requests, Resources
│  (Controllers, FormRequests,         │  Handles HTTP concerns only
│   Resources, Routes)                 │
├──────────────────────────────────────┤
│       Domain Layer                    │  Business rules, models, actions
│  (Models, Actions/Services,          │  Framework-agnostic business logic
│   Enums, Domain Events)              │
├──────────────────────────────────────┤
│       Infrastructure Layer            │  External services, storage, push
│  (SupabaseService, FCMService,       │  Framework-specific implementations
│   Queue jobs, Notifications)         │
└──────────────────────────────────────┘
```

## 4. Why This Architecture Suits a Solo Developer

1. **Simple, not abstract:** No hexagonal architecture, no CQRS, no event sourcing. Just clear separation of concerns.

2. **Feature-based organization:** Easy to find and modify code for a specific feature without traversing deep folder hierarchies.

3. **Progressive complexity:** Start with flat structure, extract services only when needed. No premature abstraction.

4. **Testability:** Domain logic is isolated from framework concerns, making unit tests straightforward.

5. **Extensibility:** Adding a new feature means adding a new feature folder in both frontend and backend without touching existing code.

6. **Framework familiarity:** Laravel's conventions are well-known. Flutter's folder structure mirrors the backend's feature-based approach.
