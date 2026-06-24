# PureNote Project Architecture

This document defines the MVVM Feature-First project structure for the PureNote cross-platform application.

```text
purenote/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── dependency_injection.dart      # Service Locator setup
│   │   └── purenote_app.dart              # MaterialApp configuration
│   ├── data/
│   │   ├── models/                        # Isar Data Models
│   │   ├── repositories/                  # Repository implementations
│   │   └── services/                      # Background services (Auth, Backup, Notification, Sync)
│   ├── domain/
│   │   ├── models/                        # Domain entities
│   │   └── use_cases/
│   ├── l10n/                              # Localization files
│   ├── shared/
│   │   ├── extensions/
│   │   └── widgets/
│   │       └── adaptive_scaffold.dart     # Desktop sidebar + Mobile bottom nav
│   └── ui/
│       ├── core/
│       │   ├── config/
│       │   │   └── router/app_router.dart # GoRouter configuration
│       │   ├── theme/app_theme.dart       # Material 3 dynamically generated colors
│       │   └── utils/
│       └── features/                      # UI Modules
│           ├── auth/
│           │   ├── view_models/           # ChangeNotifiers for state
│           │   └── views/                 # Flutter widgets & screens
│           ├── folders/
│           ├── notes/
│           ├── settings/
│           └── tags/
└── test/
    ├── data/
    └── ui/
```

## Layer Responsibilities

1. **UI Layer (`lib/ui/`)**: 
   - Feature-based structure (`features/notes`, `features/settings`).
   - Contains Flutter **Views** (Widgets, Screens) and **ViewModels** (`ChangeNotifier` classes via `Provider` package).
   - ViewModels act as the state managers and connect the UI to Repositories/Services.
2. **Data Layer (`lib/data/`)**: 
   - Handles data retrieval and storage.
   - Contains `Isar` Models (DTOs), local data sources, Repositories, and backend/native Services (e.g., `BackupService`, `AuthService`).
3. **Domain Layer (`lib/domain/`)**:
   - Pure Dart code defining core business entities and abstract interfaces.
4. **App/Core Layer (`lib/app/`, `lib/ui/core/`)**:
   - Cross-cutting concerns like Database connection, Dependency Injection (`dependency_injection.dart`), Router (`app_router.dart`), and Theme.
5. **Shared Layer (`lib/shared/`)**:
   - Reusable UI components and extensions.
