# TaskFlow — Flutter Task Management App

A complete task management app built with Flutter, progressing from basic UI to full-stack cloud integration.

---

## 📱 Overview

This project demonstrates my Flutter development journey from Week 1 to Cycle 2, showcasing fundamental to advanced concepts.

| Version | Focus | Status |
|---------|-------|--------|
| **Cycle 2** | API, Firebase, Provider | ✅ Current |
| **Week 1-3** | Basic UI, Local Storage | ✅ Legacy |

---

## 🚀 Cycle 2 Features (Current)

### Week 4: API Integration & Networking
- Fetch and display posts from JSONPlaceholder API
- User profile screen with API data
- Loading indicators and error handling
- Network request retry logic

### Week 5: Firebase Authentication & Database
- Email/Password authentication
- User registration and login
- Cloud Firestore for task storage
- Real-time task synchronization across devices

### Week 6: Provider State Management
- Refactored from setState to Provider
- Centralized state management
- Real-time UI updates
- Performance optimizations

---

## 📋 Week 1-3 Features (Legacy)

### UI & Navigation
- Splash screen with animation
- Login screen with email and password fields
- Form validation (email format + password length)
- Navigation from Login → Home using `Navigator.push`

### State & Storage
- Counter screen using `setState` (increase, decrease, reset)
- Counter value persists across restarts via `SharedPreferences`
- To-do style task list with `SharedPreferences` persistence

### Final App (Week 3)
- Full task management: add, delete, mark complete
- Filter tasks: All / Active / Completed
- Progress bar showing completion percentage
- Custom `AppBar` with action buttons (add task, counter, logout)
- Swipe-to-delete on task cards

---

## 🗂️ Project Structure

### Cycle 2 Structure
lib/
├── main.dart
├── models/
│ ├── task_model.dart
│ ├── user_model.dart
│ └── post_model.dart
├── providers/
│ ├── task_provider.dart
│ └── auth_provider.dart
├── services/
│ └── api_service.dart
├── screens/
│ ├── splash_screen.dart
│ ├── login_screen.dart
│ ├── register_screen.dart
│ └── home_screen.dart
└── widgets/
├── loading_widget.dart
└── error_widget.dart

text

### Week 1-3 Structure
lib/
├── main.dart
├── models/
│ └── task.dart
└── screens/
├── splash_screen.dart
├── login_screen.dart
├── home_screen.dart
└── counter_screen.dart

text

---

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.x or newer): https://flutter.dev/docs/get-started/install
- Android Studio or VS Code with Flutter extension
- Android Emulator or physical device
- **Firebase account** (for Cycle 2 features)

### Basic Setup (Week 1-3)

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/task_app.git
   cd task_app
Install dependencies

bash
flutter pub get
Run the app

bash
flutter run
Firebase Setup (Cycle 2)
Create Firebase project

Go to Firebase Console

Click "Add project" and follow setup

Register your app

Click "Add app" → Android/iOS

Package name: com.example.taskflow_pro

Download google-services.json (Android) or GoogleService-Info.plist (iOS)

Place file in android/app/ or ios/Runner/

Enable Authentication

Go to Authentication → Sign-in method

Enable Email/Password

Setup Firestore

Go to Firestore Database

Create database (start in test mode)

Run with Firebase

bash
flutter clean
flutter pub get
flutter run
📦 Dependencies
Cycle 2 Dependencies
Package	Version	Purpose
provider	^6.1.1	State management
firebase_core	^2.24.2	Firebase core
firebase_auth	^4.16.0	Authentication
cloud_firestore	^4.14.0	Cloud database
http	^1.1.0	API calls
shared_preferences	^2.2.3	Local storage
intl	^0.18.1	Date formatting
cached_network_image	^3.3.1	Image caching
Week 1-3 Dependencies
Package	Version	Purpose
shared_preferences	^2.2.3	Local persistent storage
cupertino_icons	^1.0.8	Icons
🎯 Assignment Requirements Met
Cycle 2 (Weeks 4-6)
✅ Week 4: API Integration with JSONPlaceholder

✅ Week 4: JSON parsing and ListView display

✅ Week 4: Error handling and loading indicators

✅ Week 5: Firebase Authentication setup

✅ Week 5: Email/Password login and registration

✅ Week 5: Firestore database integration

✅ Week 6: Provider state management implementation

✅ Week 6: Real-time UI updates

✅ Week 6: Performance optimization

Week 1-3
✅ Basic Flutter UI with login screen

✅ Navigation between screens

✅ Form validation

✅ setState management with counter app

✅ SharedPreferences for data persistence

✅ To-do list with add/delete/complete

✅ Task filtering and progress tracking

🔐 Login Credentials
Cycle 2 (Firebase Auth)
Register a new account or use test credentials

Tasks sync across devices

Week 1-3 (Mock Validation)
Any valid email format + password (6+ characters) will work.

Example:

Email: test@example.com

Password: 123456

📸 Screenshots
Feature	Screenshot
Login Screen	[Add screenshot]
Home Screen	[Add screenshot]
Add Task	[Add screenshot]
API Posts	[Add screenshot]
🎥 Demo Video
[Link to demo video - 4-5 minute walkthrough]

📈 Learning Progress
Week	Topic	Achievement
Week 1	Basic UI & Navigation	✅ Login screen with validation
Week 2	State & Storage	✅ Counter + SharedPreferences
Week 3	Task Management	✅ Complete CRUD operations
Week 4	API Integration	✅ JSONPlaceholder + error handling
Week 5	Firebase	✅ Auth + Firestore
Week 6	Provider	✅ State management refactor
🐛 Known Issues
None currently. Report issues on GitHub.

📝 Future Improvements
Push notifications with FCM

Riverpod/Bloc state management

Task categories and tags

Dark/light theme toggle

Export/import tasks

