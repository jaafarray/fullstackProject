# Mobile + Backend (Single server on 8000) - Run Guide

This repo contains:
- Django backend: `auth_server/` (auth + media endpoints)
- Flutter app: `flutter_app/`

Both backend services are consolidated into one Django project running on port 8000.

---

## 1) Run the Django backend on 8000

Windows PowerShell:
```powershell
cd C:\Users\Madad\PycharmProjects\backend\auth_server
..\venv\Scripts\python.exe manage.py migrate
..\venv\Scripts\python.exe manage.py runserver 8000
```

Quick check:
- Open http://127.0.0.1:8000/api/auth/token/ in a browser → should show 405 Method Not Allowed (GET is not allowed, POST is).

---

## 2) Run the Flutter app on Android over USB (adb reverse)

Enable USB debugging on your phone and connect via USB.

Reverse port 8000 so the phone can reach your PC’s localhost:
```powershell
& "$Env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
& "$Env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
& "$Env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse --list
```
Expected: a line mapping `tcp:8000` to `tcp:8000`.

Run Flutter:
```powershell
cd C:\Users\Madad\PycharmProjects\backend\flutter_app
flutter pub get
flutter run -d android
```

Notes:
- The app uses base URL `http://127.0.0.1:8000` (works with adb reverse).
- AndroidManifest enables cleartext: `android:usesCleartextTraffic="true"`.

---

## 3) Alternative: Run over Wi‑Fi (no adb)

If you don’t want to use USB/adb reverse:
1) Find your PC LAN IP (e.g. 192.168.1.10).
2) In `flutter_app/lib/services/api_client.dart`, set:
   ```dart
   static const String baseUrl = 'http://YOUR_PC_IP:8000';
   ```
3) Start Django accessible to LAN:
   ```powershell
   ..\venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
   ```
4) Allow TCP 8000 in Windows Firewall.
5) Run the Flutter app on the phone (same Wi‑Fi).

---

## 4) Postman collection (port 8000)

Import `postman_collection.json`
- Variables:
  - `AUTH_BASE = http://127.0.0.1:8000`
  - `STORAGE_BASE = http://127.0.0.1:8000`

Calls:
1) Register: POST `/api/auth/register/`
2) Login: POST `/api/auth/token/` (copy `access` to `ACCESS_TOKEN`)
3) Upload Image: POST `/api/media/upload/image/` (form-data key `file`)
4) Upload Audio: POST `/api/media/upload/audio/` (form-data key `file`)
5) List Media: GET `/api/media/`

---

## 5) Common issues

- 404 at `/api/auth/token/` in a browser is expected for GET. Use POST for login.
- If the Flutter app can’t reach the backend on USB, re-run adb reverse.
- If audio doesn’t play: verify the URL opens in the phone’s browser while adb reverse is active; rebuild after Manifest changes; we use `just_audio` with proper session setup.

