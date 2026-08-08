# Database Schema & ER Diagram

## Entity Relationship Diagram (Mermaid)

```mermaid
erDiagram
    users {
        uuid id PK
        string national_id UK
        string first_name
        string last_name
        string email UK "nullable"
        string phone UK "nullable"
        string password_hash
        enum role "patient | guardian | admin"
        string patient_code UK "nullable, for patients only"
        boolean is_profile_complete
        timestamp email_verified_at "nullable"
        timestamp phone_verified_at "nullable"
        timestamps
        soft_deletes
    }

    patient_profiles {
        uuid id PK
        uuid user_id FK UK
        date date_of_birth "nullable"
        enum gender "male | female | nullable"
        decimal height "nullable, cm"
        decimal weight "nullable, kg"
        string blood_group "nullable, A+ | A- | B+ | B- | AB+ | AB- | O+ | O-"
        text chronic_diseases "nullable, encrypted"
        text allergies "nullable, encrypted"
        text current_medications "nullable, encrypted"
        text previous_surgeries "nullable, encrypted"
        string avatar_url "nullable"
        string emergency_phone "nullable"
        timestamps
    }

    guardian_patient {
        uuid id PK
        uuid guardian_id FK
        uuid patient_id FK
        enum relationship "father | mother | husband | wife | son | daughter | brother | sister | other"
        boolean has_location_consent
        timestamp consented_at "nullable"
        timestamps
    }

    emergency_contacts {
        uuid id PK
        uuid patient_id FK
        string name
        string phone
        enum relationship "father | mother | husband | wife | son | daughter | brother | sister | other"
        timestamps
    }

    medical_files {
        uuid id PK
        uuid patient_id FK
        uuid uploaded_by FK "users.id"
        enum file_type "analysis | xray | prescription | pdf | other"
        string original_name
        string storage_path "Supabase Storage path"
        string mime_type
        bigint file_size "bytes"
        timestamps
        soft_deletes
    }

    emergency_events {
        uuid id PK
        uuid patient_id FK
        uuid triggered_by FK "users.id"
        decimal latitude
        decimal longitude
        text location_link "Google Maps URL"
        text message
        jsonb notified_guardians "array of guardian user IDs"
        timestamp resolved_at "nullable"
        timestamps
    }

    device_tokens {
        uuid id PK
        uuid user_id FK
        string fcm_token
        string device_type "android | ios"
        boolean is_active
        timestamps
    }

    audit_logs {
        uuid id PK
        uuid user_id FK "nullable"
        uuid patient_id FK "nullable"
        string action "e.g., profile.updated, file.uploaded, emergency.triggered"
        string entity_type "nullable"
        uuid entity_id "nullable"
        jsonb old_values "nullable"
        jsonb new_values "nullable"
        string ip_address "nullable"
        string user_agent "nullable"
        timestamps
    }

    hospitals {
        uuid id PK
        string name
        string address
        decimal latitude
        decimal longitude
        string phone "nullable"
        string website "nullable"
        string google_place_id UK
        timestamps
    }

    patient_qr_tokens {
        uuid id PK
        uuid patient_id FK
        string token UK "UUID used in QR"
        boolean is_active
        timestamp expires_at "nullable, null = never"
        timestamps
    }

    password_resets {
        string email
        string token
        timestamp created_at
    }

    personal_access_tokens {
        uuid id PK
        string tokenable_type
        uuid tokenable_id
        string name
        string token "hash"
        text abilities "nullable"
        timestamp last_used_at "nullable"
        timestamps
    }

    %% Relationships
    users ||--o| patient_profiles : has
    users ||--o{ guardian_patient : "is guardian"
    users ||--o{ guardian_patient : "is patient"
    users ||--o{ medical_files : uploads
    users ||--o{ emergency_events : triggers
    users ||--o{ device_tokens : owns
    users ||--o{ audit_logs : performs
    patient_profiles ||--o{ emergency_contacts : has
    patient_profiles ||--o{ medical_files : has
    patient_profiles ||--o{ emergency_events : has
    patient_profiles ||--o{ patient_qr_tokens : has
    patient_profiles ||--o{ audit_logs : "audited on"
    guardian_patient ||--|| emergency_events : "notifies"
```

## Table Descriptions

### `users`
The central user table. Uses UUID primary keys for security (no sequential IDs). Supports three roles via an enum column. Patients get an auto-generated `patient_code` (UUID format) used by guardians to link accounts.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK, default: uuid_generate_v4() | |
| national_id | varchar(50) | UNIQUE, NOT NULL | Encrypted at rest |
| first_name | varchar(100) | NOT NULL | |
| last_name | varchar(100) | NOT NULL | |
| email | varchar(255) | UNIQUE, nullable | Optional for patients |
| phone | varchar(20) | UNIQUE, nullable | |
| password | varchar(255) | NOT NULL | bcrypt hash |
| role | varchar(20) | NOT NULL, CHECK IN ('patient','guardian','admin') | |
| patient_code | uuid | UNIQUE, nullable, default: gen_random_uuid() | Only for patients |
| is_profile_complete | boolean | default: false | |
| email_verified_at | timestamp | nullable | |
| phone_verified_at | timestamp | nullable | |
| created_at | timestamp | | |
| updated_at | timestamp | | |
| deleted_at | timestamp | nullable, soft deletes | |

### `patient_profiles`
One-to-one with users (role=patient). Stores medical data encrypted at rest. Separated from users table to keep auth data separate from sensitive health data.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| user_id | uuid | FK -> users.id, UNIQUE | |
| date_of_birth | date | nullable | |
| gender | varchar(10) | nullable, CHECK IN ('male','female') | |
| height | decimal(5,1) | nullable | cm |
| weight | decimal(5,1) | nullable | kg |
| blood_group | varchar(5) | nullable | A+, A-, B+, B-, AB+, AB-, O+, O- |
| chronic_diseases | text | nullable | Encrypted (Laravel cast) |
| allergies | text | nullable | Encrypted |
| current_medications | text | nullable | Encrypted |
| previous_surgeries | text | nullable | Encrypted |
| avatar_url | text | nullable | Supabase Storage URL |
| emergency_phone | varchar(20) | nullable | |
| created_at | timestamp | | |
| updated_at | timestamp | | |

### `guardian_patient`
Many-to-many pivot between guardians and patients. Stores relationship type and location consent tracking.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| guardian_id | uuid | FK -> users.id | |
| patient_id | uuid | FK -> users.id | |
| relationship | varchar(20) | NOT NULL | father, mother, husband, wife, son, daughter, brother, sister, other |
| has_location_consent | boolean | default: false | Explicit patient consent for location tracking |
| consented_at | timestamp | nullable | |
| created_at | timestamp | | |
| updated_at | timestamp | | |

**Unique constraint:** (guardian_id, patient_id)

### `emergency_contacts`
Emergency contacts for a patient — used in the digital health card and SOS system.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| patient_id | uuid | FK -> users.id | |
| name | varchar(200) | NOT NULL | |
| phone | varchar(20) | NOT NULL | |
| relationship | varchar(20) | NOT NULL | Same enum as guardian_patient |
| created_at | timestamp | | |
| updated_at | timestamp | | |

### `medical_files`
Metadata for files stored in Supabase Storage. Supports soft deletes for audit purposes.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| patient_id | uuid | FK -> users.id | |
| uploaded_by | uuid | FK -> users.id | Who uploaded this file |
| file_type | varchar(20) | NOT NULL | analysis, xray, prescription, pdf, other |
| original_name | varchar(500) | NOT NULL | Original filename |
| storage_path | text | NOT NULL | Path in Supabase Storage bucket |
| mime_type | varchar(100) | NOT NULL | |
| file_size | bigint | NOT NULL | In bytes |
| created_at | timestamp | | |
| updated_at | timestamp | | |
| deleted_at | timestamp | nullable | |

### `emergency_events`
Records every SOS activation. Stores GPS coordinates and notified guardians.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| patient_id | uuid | FK -> users.id | |
| triggered_by | uuid | FK -> users.id | Patient or guardian |
| latitude | decimal(10,7) | NOT NULL | |
| longitude | decimal(10,7) | NOT NULL | |
| location_link | text | nullable | Pre-generated Google Maps link |
| message | text | nullable | |
| notified_guardians | jsonb | default: '[]' | Array of user IDs |
| resolved_at | timestamp | nullable | When emergency was deactivated |
| created_at | timestamp | | |
| updated_at | timestamp | | |

### `device_tokens`
FCM device tokens for push notifications.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| user_id | uuid | FK -> users.id | |
| fcm_token | text | NOT NULL | |
| device_type | varchar(10) | NOT NULL | android or ios |
| is_active | boolean | default: true | |
| created_at | timestamp | | |
| updated_at | timestamp | | |

**Unique constraint:** (user_id, fcm_token)

### `audit_logs`
Immutable audit trail for all critical actions. Designed for append-only access pattern.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| user_id | uuid | FK -> users.id, nullable | Who performed the action |
| patient_id | uuid | FK -> users.id, nullable | Which patient was affected |
| action | varchar(100) | NOT NULL | Dot-notation: `profile.updated`, `file.uploaded` |
| entity_type | varchar(100) | nullable | e.g., `patient_profile`, `medical_file` |
| entity_id | uuid | nullable | |
| old_values | jsonb | nullable | Previous state |
| new_values | jsonb | nullable | New state |
| ip_address | varchar(45) | nullable | |
| user_agent | text | nullable | |
| created_at | timestamp | | |

### `hospitals`
Pre-seeded or dynamically added hospitals for the hospital finder feature.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| name | varchar(300) | NOT NULL | |
| address | text | NOT NULL | |
| latitude | decimal(10,7) | NOT NULL | |
| longitude | decimal(10,7) | NOT NULL | |
| phone | varchar(20) | nullable | |
| website | varchar(500) | nullable | |
| google_place_id | varchar(500) | UNIQUE | For deduplication |
| created_at | timestamp | | |
| updated_at | timestamp | | |

### `patient_qr_tokens`
Secure tokens for the digital health card QR code. The QR code contains only the token; scanning resolves to a public emergency endpoint.

| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| id | uuid | PK | |
| patient_id | uuid | FK -> users.id | |
| token | uuid | UNIQUE, default: gen_random_uuid() | Embedded in QR |
| is_active | boolean | default: true | Can be revoked |
| expires_at | timestamp | nullable | null = never expires |
| created_at | timestamp | | |
| updated_at | timestamp | | |

## Indexes

```sql
-- Performance indexes
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_patient_code ON users(patient_code) WHERE patient_code IS NOT NULL;
CREATE INDEX idx_guardian_patient_guardian ON guardian_patient(guardian_id);
CREATE INDEX idx_guardian_patient_patient ON guardian_patient(patient_id);
CREATE INDEX idx_medical_files_patient ON medical_files(patient_id);
CREATE INDEX idx_emergency_events_patient ON emergency_events(patient_id);
CREATE INDEX idx_emergency_events_created ON emergency_events(created_at DESC);
CREATE INDEX idx_audit_logs_patient ON audit_logs(patient_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX idx_device_tokens_user ON device_tokens(user_id);
CREATE INDEX idx_hospitals_location ON hospitals(latitude, longitude);
CREATE INDEX idx_patient_qr_tokens_token ON patient_qr_tokens(token);
```

## Encryption Strategy

Sensitive columns (`chronic_diseases`, `allergies`, `current_medications`, `previous_surgeries`, `national_id`) use Laravel's built-in encryption at the application layer. Data is encrypted before being stored in PostgreSQL and decrypted on read. The database never sees plaintext of these fields.
