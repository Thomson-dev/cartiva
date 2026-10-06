# Cartiva

Cartiva is a Flutter shopping application focused on discovering and managing fashion products. The app includes onboarding, Supabase-backed authentication, product browsing, category filtering, search, saved products, a shopping cart, email OTP verification, and notifications.

## Features

### Authentication

- Two-second splash screen shown when the app starts.
- Onboarding screen for new or signed-out users.
- Email and password sign up.
- Sign-in with form validation.
- Password visibility toggle.
- Disabled authentication actions while requests are in progress.
- User-friendly authentication error messages.
- Email confirmation and OTP verification after registration when required.
- Session-aware navigation to the main shopping experience.

### Shopping experience

- Product discovery home screen.
- Product cards with network images, prices, discounts, and categories.
- Category filtering for available product categories.
- Pull-to-refresh for the product list.
- Product detail screen.
- Product size selection before adding an item to the cart.
- Saved products using the heart action.
- Search by product name.
- Recent searches stored locally, with support for removing individual searches or clearing all searches.
- Shopping cart with quantity controls, item removal, subtotal, shipping fee, VAT, and total calculations.
- Notifications screen with loading, empty, error, refresh, read, read-all, and delete states.

### Navigation

The authenticated area uses a bottom navigation bar with these sections:

1. Home
2. Search
3. Saved Items
4. Cart
5. Account

## Technology

- Flutter and Dart
- Material UI widgets
- Riverpod for application state management
- Supabase Flutter for authentication and backend data access
- Shared Preferences for recent search persistence
- `flutter_native_splash` for native launch screen generation
- General Sans font family bundled in the project

## Requirements

Install the following before running the project:

- Flutter SDK compatible with Dart SDK `^3.13.4`
- Android Studio and an Android SDK for Android development, or Xcode for iOS development
- A connected device, emulator, or simulator
- A Supabase project with authentication enabled

Check the local Flutter installation with:

```sh
flutter doctor
```

## Getting started

Clone the repository and enter the project directory:

```sh
git clone <repository-url>
cd cartiva
```

Install Dart and Flutter dependencies:

```sh
flutter pub get
```

List available devices:

```sh
flutter devices
```

Run the application:

```sh
flutter run
```

Run on a specific device with its device identifier:

```sh
flutter run -d <device-id>
```

## Supabase configuration

Supabase is initialized in `lib/main.dart`. The authentication repositories use the Supabase client for:

- Email/password registration
- Email/password sign-in
- Email OTP verification
- Signup OTP resend
- Notification reads, updates, and deletes

For a production deployment, move the Supabase URL and publishable key out of the Dart source and provide them through a build-time configuration mechanism such as `--dart-define`, a generated configuration file, or a secure CI environment.

The backend should provide the following data used by the current application:

- Supabase Auth for user accounts and sessions
- A `notifications` table containing at least the fields expected by `NotificationModel`
- Row-level security policies that allow authenticated users to read and update only their own notifications

Product data is currently defined locally in `lib/features/home/data/product_data.dart`, while product images are loaded from remote URLs.

## Project structure

```text
lib/
	main.dart                         Application entry point and Supabase setup
	core/                             Shared app configuration and colors
	features/
		auth/                            Sign-in, sign-up, OTP, and auth providers
		account/                         Account screen
		cart/                            Cart screen and cart state
		home/                            Product discovery and product details
		home_main/                       Authenticated bottom-navigation shell
		notifications/                   Notifications UI, models, and repository
		onboarding/                     Splash and onboarding screens
		search/                          Product search and recent searches
test/                                Widget and provider tests
assets/                             Bundled images and fonts
android/, ios/, linux/, macos/      Desktop and mobile platform runners
web/, windows/                      Web and Windows platform runners
```

## Validation and testing

Run all tests:

```sh
flutter test
```

Run focused authentication tests:

```sh
flutter test test/sign_in_test.dart
flutter test test/sign_up_test.dart
flutter test test/otp_verification_test.dart
```

Run the onboarding test:

```sh
flutter test test/widget_test.dart
```

Run static analysis:

```sh
flutter analyze
```

Format Dart code:

```sh
dart format lib test
```

## Native splash screen

Native launch screen settings are stored in `flutter_native_splash.yaml`. The current configuration enables Android and iOS splash generation with a white background.

Regenerate the native splash files after changing the configuration:

```sh
flutter pub get
dart run flutter_native_splash:create
```

Native splash changes require a full stop and rebuild. Hot reload does not update the platform launch screen.

## Current limitations

- Checkout is represented by a `Checkout is coming soon` message; payment processing and order creation are not implemented yet.
- Google and Facebook buttons are present in the sign-in UI, but their OAuth actions are placeholders.
- Product data is local and limited to the sample catalog currently defined in the repository.
- Product images depend on remote Unsplash URLs and require network access.
- Notification actions currently update notification state, but notification-type deep links are placeholders.
- The account screen and some commerce workflows may still be under active development.

## Development notes

- The app uses `ProviderScope` at the root so Riverpod providers are available throughout the application.
- Authentication form buttons remain disabled until the entered values pass local validation.
- Passwords must contain at least six characters.
- Email validation requires a valid address containing `@` and a domain suffix.
- OTP verification accepts a six-to-ten-digit code.
- Cart items are grouped by product and selected size; adding the same product-size combination increases its quantity.

## License

No license has been specified for this project yet.
