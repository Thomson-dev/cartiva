# cartiva

A new Flutter project.

## Native splash screen

Android and iOS launch screens are generated from `flutter_native_splash.yaml`.
The background is white in both light and dark mode. Android 12+ currently uses
the launcher icon; earlier Android versions and iOS have a plain background.

To change the color or add a PNG logo, edit the configuration and run:

```sh
flutter pub get
dart run flutter_native_splash:create
```

Android 12+ has separate color and image settings under `android_12`.
Commit the generated Android and iOS files along with the configuration.
Fully stop and rebuild the app to see changes; hot reload does not update native
launch screens. The splash disappears automatically when Flutter draws its first
frame.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# cartiva
