# TaskFlow

A Flutter task-management application with Firebase authentication, cloud-synchronized tasks, and Provider-based state management.

TaskFlow was built as a learning project for applying mobile UI, authentication, real-time data, API integration, and application state management in one Flutter codebase.

## Features

- Email and password registration and sign-in with Firebase Authentication
- Per-user task storage in Cloud Firestore
- Add, complete, and delete tasks
- Real-time task updates through Firestore snapshots
- Centralized authentication and task state with Provider
- JSONPlaceholder API service for networking practice

## Technology

| Area | Technology |
|---|---|
| Mobile application | Flutter, Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| State management | Provider |
| HTTP client | `http` |

## Run locally

### Requirements

- Flutter 3.x
- Android Studio or Visual Studio Code with Flutter support
- A Firebase project

### Setup

```bash
git clone https://github.com/zasclan/task_app.git
cd task_app
flutter pub get
```

Register the Android or iOS application in Firebase, add the platform configuration file, enable Email/Password authentication, and create a Firestore database.

Run the application:

```bash
flutter run
```

## Project structure

```text
lib/
|-- main.dart
|-- models/
|   `-- task.dart
|-- providers/
|   |-- auth_provider.dart
|   `-- task_provider.dart
|-- screens/
|   |-- counter_screen.dart
|   |-- home_screen.dart
|   |-- login_screen.dart
|   `-- splash_screen.dart
`-- services/
    `-- api_service.dart
```

## Current limitations

- Firebase platform files are intentionally not included.
- Automated tests are not yet available.
- The API service is a learning example and is not part of the core task workflow.

## Planned improvements

- Add widget and provider tests
- Improve error messages and retry handling
- Add task categories, due dates, and sorting
- Add light and dark themes
- Add screenshots and a short demonstration

## Author

Muhammad Arbab Ahmed
