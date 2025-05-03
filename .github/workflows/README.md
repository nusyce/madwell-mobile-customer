# GitHub Actions Workflows

This directory contains the GitHub Actions workflow configurations for CI/CD pipelines.

## Workflows

### 1. Build Staging App (`build_staging.yml`)

Builds and deploys the staging version of the app for both Android and iOS.

**Triggers:**
- Push to `develop` branch
- Push to `staging` branch
- Manual trigger via workflow_dispatch

**What it does:**
- Sets up environment files
- Builds Android APK and App Bundle with the `staging` flavor
- Deploys Android APK to Firebase App Distribution for testing
- Deploys Android App Bundle to Google Play Store's internal testing track
- Builds iOS app with the `staging` flavor
- Deploys iOS app to TestFlight

### 2. Build & Deploy Production App (`deploy.yml`)

Builds and deploys the production version of the app for both Android and iOS.

**Triggers:**
- Push to `main` branch
- Tags that match `v*` pattern (e.g., v1.0.0)

**What it does:**
- Builds Android APK and App Bundle for production
- Deploys Android App Bundle to Google Play Store's beta track
- Builds iOS app for production
- Deploys iOS app to TestFlight

## Required Secrets

For these workflows to function properly, you need to set up the following secrets in your GitHub repository:

### For Staging:

#### Firebase:
- `FIREBASE_ANDROID_APP_ID`: Firebase Android app ID
- `FIREBASE_SERVICE_ACCOUNT_JSON`: Firebase service account JSON for app distribution

#### Google Play:
- `GOOGLE_PLAY_JSON_KEY`: Google Play service account JSON key
- `STAGING_GOOGLE_SERVICES_JSON`: Contents of the google-services.json file for staging

#### iOS:
- `STAGING_IOS_CERTIFICATE_BASE64`: iOS distribution certificate in base64
- `STAGING_IOS_PROVISION_PROFILE_BASE64`: iOS provisioning profile in base64
- `STAGING_IOS_KEYCHAIN_PASSWORD`: Password for temporary keychain
- `STAGING_MATCH_PASSWORD`: Password for certificate encryption
- `STAGING_APP_STORE_CONNECT_API_KEY`: App Store Connect API key content
- `STAGING_APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID
- `STAGING_APP_STORE_CONNECT_ISSUER_ID`: App Store Connect issuer ID
- `STAGING_GOOGLE_SERVICE_INFO_PLIST`: Contents of the GoogleService-Info.plist file
- `STAGING_IOS_BUNDLE_ID`: Bundle ID for iOS staging app

#### Environment Variables:
- `STAGING_GOOGLE_MAPS_API_KEY`: Google Maps API key
- `STAGING_ADMOB_APP_ID`: AdMob app ID
- `STAGING_FIREBASE_ANDROID_API_KEY`: Firebase Android API key
- `STAGING_FIREBASE_ANDROID_APP_ID`: Firebase Android app ID
- `STAGING_FIREBASE_PROJECT_ID`: Firebase project ID
- `STAGING_FIREBASE_STORAGE_BUCKET`: Firebase storage bucket
- `STAGING_FIREBASE_MESSAGING_SENDER_ID`: Firebase messaging sender ID
- `STAGING_FIREBASE_IOS_API_KEY`: Firebase iOS API key
- `STAGING_FIREBASE_IOS_APP_ID`: Firebase iOS app ID
- `STAGING_FIREBASE_IOS_CLIENT_ID`: Firebase iOS client ID
- `STAGING_API_BASE_URL`: Base URL for API

### For Production:
Similar set of secrets as above, but with production values.

## Manual Workflow Trigger

To manually trigger the staging build workflow:
1. Go to Actions tab in your GitHub repository
2. Select "Build Staging App" workflow
3. Click "Run workflow"
4. Choose the branch to run from
5. Click "Run workflow" button 