# PrimeStore Flutter App

The Flutter client for the PrimeStore demo e-commerce application.

For repository setup, backend configuration, environment variables, API routes, and test commands, see the [project README](../README.md).

## Run Locally

```bash
flutter pub get
flutter test
flutter run
```

## API Configuration

The default Android emulator API address is configured in `lib/utils/constants/api_constants.dart`:

```dart
http://10.0.2.2:8080
```

Change this value when using a physical device, iOS simulator, web, or hosted backend.

## Supported Areas

- Authentication and email verification
- Shopping catalog, cart, wishlist, and checkout
- Saved addresses and user profile
- Seller profile and product management
- Seller order screens
- Light and dark themes
