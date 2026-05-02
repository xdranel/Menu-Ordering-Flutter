# Installation Guide

Setup guide for the ChopChop Flutter customer app.

---

## Prerequisites

### Flutter SDK

Install Flutter 3.x:

```bash
# Verify installation
flutter --version
flutter doctor
```

Flutter includes Dart SDK — no separate Dart install is needed.

- **Ubuntu/Debian:** [Install via snap or manual](https://docs.flutter.dev/get-started/install/linux)
- **macOS:** `brew install --cask flutter`
- **Windows:** [Download from flutter.dev](https://docs.flutter.dev/get-started/install/windows)

Run `flutter doctor` and resolve any issues it reports before continuing.

### Android Setup

**Android Studio (recommended):**
Install Android Studio, then from SDK Manager install:
- Android SDK (API 35 or latest stable)
- Android SDK Build-Tools
- Android Emulator

**Command-line only:**
```bash
sdkmanager --install "platform-tools" "build-tools;35.0.0" "platforms;android-35"
```

**Create an emulator (AVD):**
From Android Studio → Device Manager → Create Device → Pixel 7 → API 35.

---

## Installation

### 1. Clone repository

```bash
git clone https://github.com/xdranel/Menu-Ordering-Flutter
cd Menu-Ordering-Flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment

```bash
cp .env.example .env
```

Edit `.env`:

```
# Android emulator — 10.0.2.2 maps to host machine's localhost
API_BASE_URL=http://10.0.2.2:8080

# Physical device — use your machine's LAN IP
# API_BASE_URL=http://192.168.x.x:8080
```

> **Finding your LAN IP:**
> - Linux/macOS: `ip addr show` or `ifconfig`
> - Windows: `ipconfig`

### 4. Start the backend

The Spring Boot backend must be running before you launch the app.

Follow [Menu-Ordering/docs/INSTALLATION.md](https://github.com/xdranel/Menu-Ordering/blob/master/docs/INSTALLATION.md).

**Quick start (if already configured):**
```bash
cd ../Menu-Ordering
mvn spring-boot:run
```

Verify it's running: open `http://localhost:8080/customer/menu` in a browser.

### 5. Run the app

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d emulator-5554

# Or just run (picks the first available device)
flutter run
```

---

## Build

### Debug APK

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Install directly on a connected device:
```bash
flutter install
```

---

## Android Configuration Notes

### Cleartext HTTP (required for local development)

Android 9+ (API 28+) blocks HTTP traffic by default. The `AndroidManifest.xml` in this project already has:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

This allows the app to reach `http://10.0.2.2:8080`. For production, use HTTPS and remove this flag.

### Emulator vs. physical device

| Target | `API_BASE_URL` |
|--------|----------------|
| Android emulator | `http://10.0.2.2:8080` |
| Physical device (USB/WiFi) | `http://192.168.x.x:8080` |
| iOS simulator | `http://localhost:8080` |

The emulator's `10.0.2.2` is a special alias that routes to the host machine's localhost. Using `localhost` inside an emulator reaches the emulator itself, not your machine.

---

## Troubleshooting

**`NetworkException: No internet connection or server unreachable`**
1. Verify the Spring Boot backend is running: `curl http://localhost:8080/customer/api/menus`
2. Check `API_BASE_URL` in `.env` — use `10.0.2.2` for emulator, LAN IP for device
3. Ensure `android:usesCleartextTraffic="true"` is in `AndroidManifest.xml`
4. Confirm the backend allows CORS from the device (default config allows `*`)

**`flutter pub get` fails — dependency conflict**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**`flutter: Error loading assets`**
Verify `.env` exists at the project root (not inside `lib/`). Check `pubspec.yaml` has:
```yaml
flutter:
  assets:
    - .env
```

**`Could not load menu` on first launch**
The backend Flyway migrations must run on first start. Wait for the log line `Started MenuOrderingAppApplication` before launching the app.

**App installs but white screen**
Run `flutter run` (not just install) to see Dart exceptions in the console.

**Hot reload not reflecting `.env` changes**
`.env` is a bundled asset — a full restart (`flutter run`) is needed after changing it.

---

## Development Tips

```bash
# Analyze for lint warnings
flutter analyze

# Run widget tests
flutter test

# Clean build artifacts
flutter clean

# Upgrade all packages
flutter pub upgrade
```

---

See [API.md](API.md) for the backend endpoints used by this app.
