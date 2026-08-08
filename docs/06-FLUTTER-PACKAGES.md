# Recommended Flutter Packages

```yaml
# pubspec.yaml
name: bitaqati_as_sihiya
description: Bitaqati As-Sihiya - Digital Health Record Platform

environment:
  sdk: ">=3.2.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Networking
  dio: ^5.4.3+1
  retrofit: ^4.1.0            # Optional: type-safe API client generation

  # JSON Serialization
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.1  # Immutable data classes + sealed unions

  # Local Storage
  shared_preferences: ^2.3.2
  flutter_secure_storage: ^9.2.2  # Encrypted token storage

  # Navigation
  go_router: ^14.2.0

  # Firebase
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^17.2.1+2

  # Maps & Location
  google_maps_flutter: ^2.9.0
  geolocator: ^13.0.1
  geocoding: ^3.0.0           # Address <-> coordinates

  # QR
  qr_flutter: ^4.1.0

  # File Handling
  image_picker: ^1.1.2
  file_picker: ^8.1.0
  open_file: ^3.5.4
  path_provider: ^2.1.3

  # UI
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1      # SVG icons/illustrations
  cached_network_image: ^3.4.0
  shimmer: ^3.0.0              # Loading skeletons
  flutter_animate: ^4.5.0      # Simple animations

  # Utilities
  connectivity_plus: ^6.0.5
  url_launcher: ^6.3.0
  permission_handler: ^11.3.1
  package_info_plus: ^8.0.2
  device_info_plus: ^11.1.0

  # Logging
  talker_flutter: ^4.3.0       # Structured logging

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.9
  json_serializable: ^6.8.0
  freezed: ^2.5.2
  riverpod_generator: ^2.4.0
  retrofit_generator: ^8.1.1   # If using retrofit

  # Linting
  flutter_lints: ^4.0.0
  custom_lint: ^0.6.4

  # Testing
  mocktail: ^1.0.3
  mockito: ^5.4.4

flutter:
  uses-material-design: true

  assets:
    - assets/fonts/
    - assets/images/
    - assets/images/onboarding/
    - assets/images/illustrations/
    - assets/l10n/

  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo/Cairo-Light.ttf
          weight: 300
        - asset: assets/fonts/Cairo/Cairo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Cairo/Cairo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Cairo/Cairo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Cairo/Cairo-Bold.ttf
          weight: 700

    - family: Inter
      fonts:
        - asset: assets/fonts/Inter/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter/Inter-Bold.ttf
          weight: 700
```

## Why Each Package

| Package | Purpose |
|---------|---------|
| **flutter_riverpod** | State management — provides, caching, auto-dispose |
| **dio** | HTTP client with interceptors, retry, timeouts |
| **json_annotation + freezed** | Immutable models, sealed union states, JSON serialization |
| **flutter_secure_storage** | Stores JWT tokens in encrypted Keystore (Android) / Keychain (iOS) |
| **go_router** | Declarative routing with deep linking, redirect guards, nested navigation |
| **google_maps_flutter + geolocator** | Map display and GPS coordinate retrieval |
| **qr_flutter** | Render QR codes for health card |
| **image_picker + file_picker** | Camera/gallery file selection and generic file selection |
| **google_fonts** | Cairo (Arabic) and Inter (Latin) typography |
| **cached_network_image** | Efficient avatar and illustration loading with caching |
| **shimmer** | Loading skeleton placeholders |
| **connectivity_plus** | Monitor network state for offline handling |
| **url_launcher** | Open phone dialer, maps, web URLs |
| **permission_handler** | Manage camera, storage, location permissions |
| **firebase_messaging** | FCM push notifications |
| **talker_flutter** | Structured logging during development |
