# Clean Architecture Explanation

## The Core Idea

Clean Architecture is about **separating business logic from framework details** so that:

1. You can change the UI framework without rewriting business rules.
2. You can change the database without rewriting business rules.
3. You can test business logic without setting up a database or HTTP server.

## Dependency Diagram

```
┌──────────────────────────────────────────────┐
│           Flutter Presentation                │
│  (Screens, Widgets, Providers/Blocs)         │
│  ● Depends on: Domain Layer                  │
│  ● Knows nothing about Data Layer            │
└────────────────────┬─────────────────────────┘
                     │ depends on (abstract interfaces)
                     ▼
┌──────────────────────────────────────────────┐
│           Domain Layer (common)               │
│  (Entities, UseCases, Repository interfaces) │
│  ● Pure Dart / Pure PHP classes              │
│  ● No Flutter imports / No Laravel imports   │
│  ● No HTTP, no DB, no framework              │
└────────────────────┬─────────────────────────┘
                     │ implemented by
                     ▼
┌──────────────────────────────────────────────┐
│           Data Layer (Flutter)               │
│  (Repository implementations, DataSources)   │
│  ● Calls Dio (HTTP), Supabase SDK, etc      │
│  ● Maps JSON → Model → Entity               │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│      Laravel HTTP Layer (Controllers)        │
│  ● Thin: validate → call Action → respond   │
│  ● No business logic                         │
└────────────────────┬─────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────┐
│      Laravel Domain Layer (Models/Actions)   │
│  ● Business rules, calculations              │
│  ● Eloquent models with relationships        │
│  ● Encapsulated in Action classes            │
└────────────────────┬─────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────┐
│      Laravel Infrastructure Layer            │
│  ● SupabaseStorageService                    │
│  ● FCMService                                │
│  ● AuditLogService                           │
└──────────────────────────────────────────────┘
```

## How It Works in Practice

### Flutter Example: Login Flow

```
LoginScreen
    │ reads provider
    ▼
AuthNotifier (StateNotifierProvider)
    │ calls usecase
    ▼
LoginUseCase
    │ calls abstract repository interface
    ▼
AuthRepository (abstract interface — in domain layer)
    ▲
    │ implements
    │
AuthRepositoryImpl (in data layer)
    │ calls datasource
    ▼
AuthRemoteDataSource (uses Dio to call API)
    │ returns JSON
    ▼
LoginResponseModel (JSON-serializable, in data layer)
    │ mapped to
    ▼
User (pure Dart entity, in domain layer)
```

**Key rule:** `LoginUseCase` never imports `dio`, `flutter_secure_storage`, or any Flutter/UI package. It only knows about the `AuthRepository` interface and the `User` entity.

### Laravel Example: Trigger SOS

```
EmergencyController::triggerSos()
    │ validates via TriggerSosRequest
    │ calls action
    ▼
TriggerSosAction::execute(patientId, latitude, longitude)
    │ - creates EmergencyEvent record
    │ - calls FCMService to notify guardians
    │ - calls AuditLogService to record action
    │ returns EmergencyEvent
    ▲
    │
EmergencyController
    │ wraps in EmergencyEventResource
    │ returns JSON response
```

**Key rule:** `TriggerSosAction` does NOT return HTTP responses. It returns domain objects or throws exceptions. The controller handles HTTP concerns.

## Why This Is Suitable for a Solo Developer

### 1. **No Over-Engineering**
- We're not using hexagonal architecture with ports and adapters.
- We're not implementing CQRS or event sourcing.
- We're not separating read models from write models.
- Just three clear layers with clear responsibilities.

### 2. **Feature-Based Organization Makes Navigation Easy**
- Need to fix something in the SOS feature? Open `features/emergency/` on both sides.
- All related files are colocated, not scattered across 10 folders.

### 3. **Progressive Abstraction**
- Start with everything in the controller or screen.
- Extract an Action/UseCase when you see logic duplication.
- Extract a Service when you integrate an external system.
- Extract a Repository interface only when you need to test or swap implementations.

### 4. **Testability Where It Matters**
- **Domain layer:** Unit-testable without any framework setup.
- **Data layer:** Testable with mock HTTP responses.
- **Presentation layer:** Widget tests with overridden providers.

### 5. **Framework Replaceability**
- If you switch from Riverpod to BLoC, only `presentation/` changes.
- If you switch from Supabase to AWS S3, only `Services/SupabaseStorageService.php` changes.
- If you switch from PostgreSQL to MySQL, only the migration files change.

## What NOT to Do

- ❌ Don't create "UseCase" for every single operation. Only extract when there's business logic beyond CRUD.
- ❌ Don't create abstract Repository interfaces until you have a second implementation (e.g., mock for testing).
- ❌ Don't create Value Objects for simple strings. Just use strings.
- ❌ Don't create separate "DTO" and "Entity" classes if they're identical. A single model class is fine.
- ❌ Don't implement your own DI container. Laravel's container + Riverpod's ProviderScope are sufficient.

## What TO Do

- ✅ Start with fat controllers/screens.
- ✅ Extract Actions/UseCases when you see logic that could be reused or tested independently.
- ✅ Extract Services when you integrate external systems.
- ✅ Write tests for Actions and UseCases first.
- ✅ Keep the dependency rule: outer layers depend on inner layers, never the reverse.
