# Madwell Mobile Customer App

## Environment Setup

This project supports multiple environments:
- Development (dev)
- Staging (staging)
- Production (prod)

Each environment has its own configuration, package name, and app icon.

## Environment Configuration

### Setup

1. Copy the environment example files to the project root:

```bash
# For development
cp .env_examples/env.dev .env.dev

# For staging 
cp .env_examples/env.staging .env.staging

# For production
cp .env_examples/env.prod .env.prod
```

2. Update the values in each `.env` file with the appropriate API keys and settings.

### Running the App

To run the app in a specific environment:

```bash
# Development
flutter run --dart-define=ENV=dev --flavor dev

# Staging
flutter run --dart-define=ENV=staging --flavor staging

# Production
flutter run --dart-define=ENV=prod --flavor prod
```

### Building the App

To build the app for a specific environment:

```bash
# Development APK
flutter build apk --dart-define=ENV=dev --flavor dev

# Staging APK
flutter build apk --dart-define=ENV=staging --flavor staging

# Production APK
flutter build apk --dart-define=ENV=prod --flavor prod

# Development App Bundle
flutter build appbundle --dart-define=ENV=dev --flavor dev

# Staging App Bundle
flutter build appbundle --dart-define=ENV=staging --flavor staging

# Production App Bundle
flutter build appbundle --dart-define=ENV=prod --flavor prod
```

### Testing your setup

You can run the environment test script to verify your setup:

```bash
./test_environment.sh
```

This script will help you run the app with the correct environment configuration.

### App Icons

The app uses different icons for each environment. To generate them:

```bash
# Generate icons for development
flutter pub run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml

# Generate icons for staging
flutter pub run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml

# Generate icons for production
flutter pub run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
```

Make sure to place the appropriate icon files in the following locations:
- `assets/images/branding/app_icon_dev.png`
- `assets/images/branding/app_icon_foreground_dev.png`
- `assets/images/branding/app_icon_staging.png`
- `assets/images/branding/app_icon_foreground_staging.png`
- `assets/images/branding/app_icon.png`
- `assets/images/branding/app_icon_foreground.png`

## Firebase Configuration

Firebase configuration is managed through environment-specific settings.

To change Firebase projects for each environment, update the configuration in the appropriate files:
- `lib/config/dev_config.dart` (Development)
- `lib/config/staging_config.dart` (Staging)
- `lib/config/prod_config.dart` (Production)

## Key Files

The environment configuration is managed by the following files:

- `lib/config/environment_config.dart`: Main configuration class
- `lib/config/dev_config.dart`: Development environment settings
- `lib/config/staging_config.dart`: Staging environment settings
- `lib/config/prod_config.dart`: Production environment settings
- `lib/config/env_reader.dart`: Environment file reader
- `lib/config/firebase_options_helper.dart`: Firebase options helper
- `lib/utils/environment_checker.dart`: Utility to check environment setup

## API Keys and Security

The environment setup securely manages:
1. Firebase API keys
2. Google Maps API keys
3. AdMob App IDs
4. Package/Bundle IDs
5. API base URLs

For maximum security:
- Keep `.env` files out of version control (add to `.gitignore`)
- Use different API keys for each environment
- Restrict API keys in the respective services (Google Cloud Console, Firebase Console)
- Follow best practices for mobile API key security

### Table of contents
[System
requirements] (#system-requirements)
[Figma design guidelines for better UI accuracy] (#figma-design-guideline-for-better-accuracy)
[Check the UI of the entire appl (#app-navigations)
[Application structurel (#project-structure)
[How to format your code?] (#how-you-can-do-code-formatting)
[How you can improve code readability?] (#how-you-can-improve-the-readability-of-code)
[Libraries and tools used] (#libraries-and-tools-used)
[Support] (#support)
### System requirements

### Figma design guidelines for better UI accuracy
Read our guidelines to increase the accuracy of design-to-code conversion by optimizing Figma designs.

### Check the UI of the entire app
Check the UI of all the app screens from a single place by setting up the 'initialRoute' to AppNavigation in the AppRoutes.dart file.
### Application structure
After successful build, your application structure should look like this:

After successful build, your application structure should look like this:
.
├─ android/ -- Android specific files
├─ assets/ -- Images, fonts, etc.
│  ├─ animations/ -- Lottie Animations
│  ├─ images/ -- Images
│  ├─ countryCodes/ -- country codes JSOn file
│  ├─ languages/ -- Localization files
│  ├─ fonts/ -- Fonts
│  ├─ mapThemes/ -- Map Themes
├─ ios/ -- iOS specific files
├─ lib/ -- Dart files
│  ├─ app/ -- App-level code (e.g. routes, theme, localization, assets naming, imports in single file)
│  ├─ cubits/ -- State management (used to manage the UI states according to server data)
│  ├─ data/ -- Data access
│  │  ├─ repository/ -- Module wise API and general method files. For example, UserRepository.dart
│  │  ├─ model/ -- to parse the JSON response from the server
│  ├─ ui/ -- UI components
│  │  ├─ screens/ -- Main screens
│  │  ├─ widgets/ -- Common widgets which are used in multiple screens
│  ├─ utils/ -- Utility files (e.g. constants, extensions, stripe services, notifications, etc.)
│  ├─ main.dart -- Dart entry point
│  ├─ firebase_options.dart -- Firebase configuration





### How to format your code?
- if your code is not formatted then run following command in your terminal to format code
  dart Tormat
### How you can improve code readability?
Resolve the errors and warnings that are shown in the application.
### Libraries and tools used
- BLoC - State management https://bloclibrary.dev
  cached_network_image -
  For storing
  internet image into cache
  https://pub.dev/packages/cached_network_image
### Support
If you have any problems or questions, go to our Discord channel, where we will help you as quickly as
