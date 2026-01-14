# Energy Monitor - Flutter App

A beautiful Energy Monitor application with login and dashboard screens built with Flutter.

## Features

### 🔐 Login Screen
- Clean, modern interface with beige background
- Yellow circular logo with lightning bolt icon
- Email and password input fields
- Password visibility toggle
- Yellow "Log In" button
- Google sign-in integration
- "Forgot Password?" and "Create account" links

### 📊 Dashboard Screen
- **User Profile**: Welcome message with avatar
- **Current Load**: Real-time power monitoring (3.4 kW)
- **Status Badge**: Normal/Alert indicators
- **Estimated Bill**: Monthly bill preview ($45.20)
- **Metrics Cards**: Voltage, Current, Energy Usage, Power Factor
- **Bottom Navigation**: Home, Stats, Devices, Profile

## Navigation
- Login screen → Dashboard (both buttons)
- Dashboard includes bottom nav for future screens

## How to Run

1. Make sure Flutter is installed on your system
2. Navigate to the project directory:
   ```bash
   cd "c:\Users\ACER\OneDrive\Documents\PROJECT ANTIGRAVITY"
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart          # App entry point
└── login_screen.dart  # Login screen UI
```

## Dependencies

- `google_fonts` - For beautiful Inter font family
- Flutter SDK 3.0.0+

## Design Highlights

- **Color Palette:**
  - Background: `#F5F3ED` (Warm beige)
  - Primary Yellow: `#FFEB3B`
  - Text: Black and gray tones
  
- **Typography:** Inter font family via Google Fonts
- **UI Elements:** Material Design 3 with custom styling
