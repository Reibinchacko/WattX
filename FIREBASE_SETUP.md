# Firebase Setup Guide for WattX

Follow these steps to configure your Firebase backend for the WattX Smart Meter System.

## 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and follow the setup wizard.
3. Enable **Google Analytics** if desired.

## 2. Register Your App
1. Inside your Firebase project, click the **Android icon** to add an app.
2. Provide your package name (found in `android/app/build.gradle` - e.g., `com.example.wattx`).
3. Download the `google-services.json` file and place it in the `android/app/` directory of your project.

## 3. Enable Authentication
1. Navigate to **Authentication** > **Get Started**.
2. Enable **Email/Password** sign-in method.
3. (Optional) Enable **Google** sign-in if you plan to use it.

## 4. Set Up Realtime Database
1. Navigate to **Realtime Database** > **Create Database**.
2. Choose a location (e.g., `us-central1`).
3. Start in **Locked Mode**.
4. Once created, go to the **Rules** tab and paste the contents of `firebase-rules.json`.
5. Click **Publish**.

## 5. Import Seed Data
1. Go to the **Data** tab in the Realtime Database.
2. Click the three dots (options) in the top right.
3. Select **Import JSON**.
4. Browse and select the `firebase-seed.json` file.
5. Click **Import**.

## 6. Update Flutter Project
1. Ensure you have the [Firebase CLI](https://firebase.google.com/docs/cli) installed.
2. Run `flutterfire configure` to update your configurations (requires `flutterfire_cli`).
3. Run `flutter pub get` to ensure all dependencies are resolved.

Your backend is now ready!
