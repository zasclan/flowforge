# TaskFlow — Flutter Task Management App

A simple, clean task management app built with Flutter

---

## Features
UI & Navigation
- Splash screen with animation 
- Login screen with email and password fields
- Form validation (email format + password length)
- Navigation from Login → Home using `Navigator.push`

### State & Storage
- Counter screen using `setState` (increase, decrease, reset)
- Counter value persists across restarts via `SharedPreferences`
- To-do style task list with `SharedPreferences` persistence

### Final App
- Full task management: add, delete, mark complete
- Filter tasks: All / Active / Completed
- Progress bar showing completion percentage
- Custom `AppBar` with action buttons (add task, counter, logout)
- Swipe-to-delete on task cards

---

##  Structure

```
lib/
├── main.dart
├── models/
│   └── task.dart
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── home_screen.dart
    └── counter_screen.dart
```

---

## Setup Instructions

### Prerequisites
- Flutter SDK (3.x or newer): https://flutter.dev/docs/get-started/install
- Android Studio or VS Code with Flutter extension
- Android Emulator or physical device

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/task_app.git
   cd task_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```
   Or press **F5** in VS Code with an emulator running.

4. **Build APK** (optional)
   ```bash
   flutter build apk
   ```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `shared_preferences` | ^2.2.3 | Local persistent storage |
| `cupertino_icons` | ^1.0.8 | Icons |

---

## Login Credentials (Demo)
Any valid email format + password (6+ characters) will work.

Example:
- Email: `test@example.com`
- Password: `123456`