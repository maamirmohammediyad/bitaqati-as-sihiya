<?php

declare(strict_types=1);

return [

    /*
    |--------------------------------------------------------------------------
    | Patient Code Prefix
    |--------------------------------------------------------------------------
    |
    | Prefix used when auto-generating unique patient codes.
    |
    */

    'patient_code_prefix' => 'BQS',

    /*
    |--------------------------------------------------------------------------
    | Patient Code Length
    |--------------------------------------------------------------------------
    |
    | Total length of the generated patient code including the prefix.
    |
    */

    'patient_code_length' => 10,

    /*
    |--------------------------------------------------------------------------
    | Profile Completion
    |--------------------------------------------------------------------------
    |
    | Fields required for a patient profile to be considered complete.
    |
    */

    'required_profile_fields' => [
        'full_name',
        'date_of_birth',
        'blood_group',
        'phone',
        'address',
    ],

    /*
    |--------------------------------------------------------------------------
    | SMS / QR Token Expiry
    |--------------------------------------------------------------------------
    |
    | How long (in minutes) a QR login token remains valid.
    |
    */

    'qr_token_expiry_minutes' => 5,

    /*
    |--------------------------------------------------------------------------
    | Emergency SOS Auto-Resolution
    |--------------------------------------------------------------------------
    |
    | After this many minutes an unresolved SOS event is auto-resolved.
    |
    */

    'sos_auto_resolve_minutes' => 120,

    /*
    |--------------------------------------------------------------------------
    | Supabase Storage Buckets
    |--------------------------------------------------------------------------
    |
    | Default bucket names used for medical file storage.
    |
    */

    'supabase_buckets' => [
        'medical_files' => 'medical-files',
        'avatars' => 'avatars',
    ],

    /*
    |--------------------------------------------------------------------------
    | Encryption Cipher
    |--------------------------------------------------------------------------
    |
    | Cipher method used by EncryptedMedicalData cast.
    |
    */

    'encryption_cipher' => 'aes-256-cbc',
];
