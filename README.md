# FlowForge

FlowForge is a cloud-synchronized task execution workspace built with Flutter. It is designed around a typed workflow model rather than a basic checklist: tasks have lifecycle states, priorities, due dates and tags, while the dashboard exposes completion and overdue indicators.

## Engineering problem

Small task applications often mix UI state with database documents, trust unvalidated writes and lose compatibility when the data model changes. FlowForge separates the domain model from synchronization state, validates writes at the Firestore boundary and reads the earlier boolean-completion schema for backward compatibility.

## Capabilities

- Email/password authentication and per-user Firestore collections
- Real-time synchronization with managed stream cancellation and error states
- `todo`, `inProgress` and `completed` workflow states
- Low, medium, high and urgent priorities
- Due dates, overdue detection and free-form tags
- Search and focused views for active, due-soon, overdue and completed work
- Execution dashboard with active/completed/overdue counts and completion rate
- Versioned task documents and migration support for the original schema
- Firestore rules that enforce ownership, field types and input limits
- Domain tests for serialization and legacy compatibility

## Architecture

```text
Presentation (Material 3 screens)
        â†“
State and workflow (Provider / TaskProvider)
        â†“
Typed domain model (Task, TaskStatus, TaskPriority)
        â†“
Firebase Authentication + per-user Cloud Firestore
        â†“
Security rules and composite indexes
```

## Data model

Each task records its title, description, priority, status, optional due date, tags, created/updated timestamps, completion timestamp and schema version. The reader accepts original documents that contain only `isCompleted`, allowing existing data to remain usable.

## Security model

`firestore.rules` restricts every task path to its authenticated owner and validates core fields. Firebase configuration files remain outside version control; the repository contains no credentials.

## Run and verify

```bash
flutter pub get
dart analyze
dart test test/task_model_test.dart
flutter run
```

Before running the application, register the target platform in Firebase, add its generated configuration file, enable Email/Password authentication and deploy `firestore.rules` plus `firestore.indexes.json`.

## Current boundaries

- The repository does not ship a Firebase project or production credentials.
- Offline behavior relies on the Firestore client cache and has not yet been benchmarked under long network partitions.
- Provider/domain tests are included; Firebase emulator integration tests are the next validation layer.

## Author

Muhammad Arbab Ahmed