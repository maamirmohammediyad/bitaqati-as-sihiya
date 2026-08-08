# REST API Endpoints

## 1. Authentication

### `POST /api/auth/register/patient`
Register a new patient account.

**Request:**
```json
{
  "national_id": "1234567890",
  "first_name": "Ahmed",
  "last_name": "Al-Saud",
  "password": "secureP@ss123",
  "password_confirmation": "secureP@ss123"
}
```

**Response (201):**
```json
{
  "data": {
    "id": "uuid",
    "first_name": "Ahmed",
    "last_name": "Al-Saud",
    "role": "patient",
    "patient_code": "HLT-A8F7-K29M-Q4A2",
    "is_profile_complete": false,
    "token": "jwt_token_string",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### `POST /api/auth/register/guardian`
Register a new guardian account (optional: link to patient via patient_code).

**Request:**
```json
{
  "national_id": "0987654321",
  "first_name": "Fatima",
  "last_name": "Al-Saud",
  "password": "secureP@ss123",
  "password_confirmation": "secureP@ss123",
  "patient_code": "HLT-A8F7-K29M-Q4A2",
  "relationship": "mother"
}
```

**Response (201):**
```json
{
  "data": {
    "id": "uuid",
    "first_name": "Fatima",
    "last_name": "Al-Saud",
    "role": "guardian",
    "linked_patients": [
      {
        "id": "uuid",
        "first_name": "Ahmed",
        "relationship": "mother",
        "has_location_consent": false
      }
    ],
    "token": "jwt_token_string",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### `POST /api/auth/login`
Login with national_id + password.

**Request:**
```json
{
  "national_id": "1234567890",
  "password": "secureP@ss123"
}
```

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "first_name": "Ahmed",
    "role": "patient",
    "patient_code": "HLT-A8F7-K29M-Q4A2",
    "is_profile_complete": true,
    "token": "jwt_token_string",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### `POST /api/auth/logout`
Revoke current token. Requires auth.

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

### `POST /api/auth/refresh`
Refresh the JWT token.

**Response (200):** Same as login response (new token).

### `POST /api/auth/forgot-password`
Send password reset link to email.

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "message": "Password reset link sent"
}
```

### `POST /api/auth/reset-password`
Reset password with token.

**Request:**
```json
{
  "email": "user@example.com",
  "token": "reset_token",
  "password": "newP@ss123",
  "password_confirmation": "newP@ss123"
}
```

**Response (200):**
```json
{
  "message": "Password reset successfully"
}
```

### `GET /api/auth/me`
Get authenticated user profile. Requires auth.

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "first_name": "Ahmed",
    "last_name": "Al-Saud",
    "national_id": "***67890",
    "email": null,
    "phone": null,
    "role": "patient",
    "patient_code": "HLT-A8F7-K29M-Q4A2",
    "is_profile_complete": true,
    "created_at": "2026-01-15T10:00:00Z"
  }
}
```

### `POST /api/device-tokens`
Register FCM device token. Requires auth.

**Request:**
```json
{
  "fcm_token": "fcm_device_token_string",
  "device_type": "android"
}
```

**Response (200):**
```json
{
  "message": "Device token registered"
}
```

### `DELETE /api/device-tokens/{token}`
Remove FCM device token. Requires auth.

**Response (200):**
```json
{
  "message": "Device token removed"
}
```

---

## 2. Patient Profile

### `GET /api/patient/profile`
Get patient profile. Requires auth (patient role).

**Response (200):**
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "first_name": "Ahmed",
      "last_name": "Al-Saud",
      "patient_code": "HLT-A8F7-K29M-Q4A2"
    },
    "profile": {
      "date_of_birth": "1990-05-15",
      "gender": "male",
      "height": 175.0,
      "weight": 72.0,
      "blood_group": "A+",
      "chronic_diseases": "encrypted_value",
      "allergies": "encrypted_value",
      "current_medications": "encrypted_value",
      "previous_surgeries": "encrypted_value",
      "avatar_url": "https://supabase.storage/avatars/uuid.jpg",
      "emergency_phone": "+966501234567"
    }
  }
}
```

### `POST /api/patient/profile/complete`
Complete profile after registration. Requires auth (patient role).

**Request:**
```json
{
  "date_of_birth": "1990-05-15",
  "gender": "male",
  "height": 175.0,
  "weight": 72.0,
  "blood_group": "A+",
  "chronic_diseases": "Diabetes Type 2",
  "allergies": "Penicillin, Peanuts",
  "current_medications": "Metformin 500mg",
  "previous_surgeries": "Appendectomy 2010",
  "emergency_phone": "+966501234567"
}
```

**Response (200):**
```json
{
  "data": { /* full profile */ },
  "message": "Profile completed successfully"
}
```

### `PUT /api/patient/profile`
Update patient profile. Requires auth (patient or guardian role).

**Request:** Same as complete profile (partial update allowed).

**Response (200):**
```json
{
  "data": { /* updated profile */ },
  "message": "Profile updated successfully"
}
```

### `POST /api/patient/avatar`
Upload profile avatar. Requires auth.

**Request:** `multipart/form-data` with `avatar` file.

**Response (200):**
```json
{
  "data": {
    "avatar_url": "https://supabase.storage/avatars/uuid.jpg"
  }
}
```

---

## 3. Guardian Management

### `POST /api/guardian/link`
Link guardian to a patient via PatientCode. Requires auth (guardian role).

**Request:**
```json
{
  "patient_code": "HLT-A8F7-K29M-Q4A2",
  "relationship": "mother"
}
```

**Response (200):**
```json
{
  "data": {
    "patient_id": "uuid",
    "patient_name": "Ahmed Al-Saud",
    "relationship": "mother",
    "has_location_consent": false
  },
  "message": "Linked to patient successfully"
}
```

### `GET /api/guardian/patients`
Get all patients linked to the guardian. Requires auth (guardian role).

**Response (200):**
```json
{
  "data": [
    {
      "patient_id": "uuid",
      "first_name": "Ahmed",
      "last_name": "Al-Saud",
      "patient_code": "HLT-A8F7-K29M-Q4A2",
      "relationship": "mother",
      "has_location_consent": true,
      "emergency_mode_active": false
    }
  ]
}
```

### `GET /api/guardian/patients/{patient}`
Get full patient details for a linked patient. Requires auth (guardian role).

**Response (200):**
```json
{
  "data": {
    "patient": { /* user info */ },
    "profile": { /* profile info including decrypted medical data */ },
    "emergency_contacts": [ /* array */ ]
  }
}
```

---

## 4. Medical Files

All endpoints prefixed with `/api/patients/{patient}/files`.
Requires auth + `can:manage,patient` gate.

### `GET /api/patients/{patient}/files`
List all medical files for a patient.

**Query params:** `?file_type=analysis&page=1&per_page=20`

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "file_type": "analysis",
      "original_name": "blood_test_2026.pdf",
      "mime_type": "application/pdf",
      "file_size": 245760,
      "uploaded_by": {
        "id": "uuid",
        "name": "Fatima Al-Saud"
      },
      "created_at": "2026-06-15T10:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 5,
    "last_page": 1
  }
}
```

### `POST /api/patients/{patient}/files`
Upload a medical file.

**Request:** `multipart/form-data`
- `file`: The file
- `file_type`: `analysis|xray|prescription|pdf|other`

**Response (201):**
```json
{
  "data": {
    "id": "uuid",
    "file_type": "xray",
    "original_name": "chest_xray.jpg",
    "mime_type": "image/jpeg",
    "file_size": 1024000,
    "created_at": "2026-06-15T10:00:00Z"
  },
  "message": "File uploaded successfully"
}
```

### `GET /api/patients/{patient}/files/{file}`
Get file details.

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "file_type": "pdf",
    "original_name": "prescription.pdf",
    "mime_type": "application/pdf",
    "file_size": 51200,
    "download_url": "https://supabase.storage/files/uuid.pdf?token=signed",
    "uploaded_by": { "id": "uuid", "name": "..." },
    "created_at": "2026-06-15T10:00:00Z"
  }
}
```

### `DELETE /api/patients/{patient}/files/{file}`
Soft-delete a medical file. Also removes from Supabase Storage.

**Response (200):**
```json
{
  "message": "File deleted successfully"
}
```

### `GET /api/patients/{patient}/files/{file}/download`
Get a signed download URL for the file.

**Response (200):**
```json
{
  "data": {
    "download_url": "https://supabase.storage/files/uuid.pdf?token=signed&expires=3600"
  }
}
```

---

## 5. Emergency Contacts

### `GET /api/patients/{patient}/emergency-contacts`
List all emergency contacts for a patient.

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Khalid Ahmed",
      "phone": "+966501234567",
      "relationship": "father",
      "created_at": "2026-01-15T10:00:00Z"
    }
  ]
}
```

### `POST /api/patients/{patient}/emergency-contacts`
Create a new emergency contact.

**Request:**
```json
{
  "name": "Khalid Ahmed",
  "phone": "+966501234567",
  "relationship": "father"
}
```

**Response (201):** Full contact resource.

### `PUT /api/patients/{patient}/emergency-contacts/{contact}`
Update an emergency contact.

**Response (200):** Updated contact resource.

### `DELETE /api/patients/{patient}/emergency-contacts/{contact}`
Delete an emergency contact.

**Response (200):**
```json
{
  "message": "Contact deleted successfully"
}
```

---

## 6. Emergency / SOS

### `POST /api/emergency/sos`
Trigger SOS emergency. Requires auth (patient or guardian role).

**Request:**
```json
{
  "patient_id": "uuid",
  "latitude": 24.7136,
  "longitude": 46.6753
}
```

**Response (201):**
```json
{
  "data": {
    "event_id": "uuid",
    "patient_name": "Ahmed Al-Saud",
    "location_link": "https://maps.google.com/?q=24.7136,46.6753",
    "blood_group": "A+",
    "chronic_diseases": "Diabetes Type 2",
    "allergies": "Penicillin",
    "message": "EMERGENCY: Ahmed Al-Saud needs immediate help!",
    "notified_guardians": 2,
    "emergency_mode": true
  },
  "message": "Emergency alert sent to guardians"
}
```

### `POST /api/emergency/sos/{event}/resolve`
Resolve an active emergency. Requires auth.

**Request:**
```json
{
  "notes": "False alarm — patient is safe"
}
```

**Response (200):**
```json
{
  "data": {
    "id": "uuid",
    "resolved_at": "2026-06-15T10:05:00Z",
    "notes": "False alarm — patient is safe"
  },
  "message": "Emergency resolved"
}
```

### `GET /api/emergency/history`
Get emergency history for the authenticated patient or guardian.

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "patient_name": "Ahmed Al-Saud",
      "triggered_by": "Self",
      "latitude": 24.7136,
      "longitude": 46.6753,
      "location_link": "https://maps.google.com/?q=24.7136,46.6753",
      "status": "resolved",
      "resolved_at": "2026-06-15T10:05:00Z",
      "created_at": "2026-06-15T10:00:00Z"
    }
  ]
}
```

### `GET /api/emergency/history/{patient}`
Get emergency history for a specific patient (guardian access).

---

## 7. Health Card

### `GET /api/health-card`
Get the digital health card for the authenticated patient. Requires auth.

**Response (200):**
```json
{
  "data": {
    "full_name": "Ahmed Al-Saud",
    "patient_code": "HLT-A8F7-K29M-Q4A2",
    "avatar_url": "https://...",
    "blood_group": "A+",
    "chronic_diseases": "Diabetes Type 2",
    "allergies": "Penicillin",
    "emergency_phone": "+966501234567",
    "emergency_contacts": [
      {
        "name": "Khalid Ahmed",
        "phone": "+966501234567",
        "relationship": "father"
      }
    ],
    "qr_token": "uuid-qr-token",
    "qr_data": "https://api.bitaqati.com/health-card/qr/uuid-qr-token"
  }
}
```

### `GET /api/health-card/qr/{token}`
Public endpoint — no auth required. Scanned from QR code.

**Response (200):**
```json
{
  "data": {
    "full_name": "Ahmed Al-Saud",
    "blood_group": "A+",
    "allergies": "Penicillin",
    "emergency_phone": "+966501234567",
    "emergency_contacts": [
      {
        "name": "Khalid Ahmed",
        "phone": "+966501234567",
        "relationship": "father"
      }
    ]
  }
}
```

**Note:** This endpoint exposes ONLY emergency-necessary information. No full medical history, no national ID, no medications.

### `POST /api/health-card/regenerate-qr`
Generate a new QR token (invalidates the old one). Requires auth.

---

## 8. Hospitals

### `GET /api/hospitals/nearby`
Find nearby hospitals. Requires auth.

**Query params:**
```
?latitude=24.7136&longitude=46.6753&radius=10&limit=20
```

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "King Faisal Specialist Hospital",
      "address": "Riyadh, Saudi Arabia",
      "distance_km": 2.5,
      "phone": "+966114644444",
      "website": "https://kfshrc.edu.sa",
      "latitude": 24.7200,
      "longitude": 46.6800,
      "google_maps_link": "https://maps.google.com/?daddr=24.7200,46.6800"
    }
  ]
}
```

### `GET /api/hospitals/{hospital}`
Get hospital details.

---

## 9. Admin Endpoints

All admin endpoints require `role:admin` middleware.

### `GET /api/admin/users`
List all users with optional role filter. Paginated.

**Query params:** `?role=patient&search=ahmed&page=1&per_page=20`

### `GET /api/admin/users/{user}`
Get user details with profile and relationships.

### `PUT /api/admin/users/{user}`
Update user (deactivate, change role, etc.).

### `DELETE /api/admin/users/{user}`
Soft-delete a user.

### `GET /api/admin/patients`
List all patients with profile data.

### `GET /api/admin/patients/{patient}`
Detailed patient view with all relations.

### `GET /api/admin/guardians`
List all guardians.

### `GET /api/admin/guardians/{guardian}`
Guardian with linked patients.

### `GET /api/admin/files`
List all medical files across all patients. Paginated.

### `DELETE /api/admin/files/{file}`
Force-delete a medical file.

### `GET /api/admin/emergencies`
List all emergency events. Paginated, ordered by date desc.

### `GET /api/admin/emergencies/{event}`
Emergency event details.

### `GET /api/admin/audit-logs`
List audit logs. Paginated.

**Query params:** `?action=profile.updated&user_id=uuid&patient_id=uuid&from=2026-01-01&to=2026-06-30&page=1&per_page=50`
