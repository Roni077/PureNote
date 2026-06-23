# PureNote Project Architecture

This document defines the Clean Architecture, Feature-First project structure for the PureNote cross-platform application.

```text
purenote/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── purenote_app.dart              # MaterialApp configuration
│   │   └── app_providers.dart             # Global level providers
│   ├── config/
│   │   ├── router/
│   │   │   ├── app_router.dart            # GoRouter configuration
│   │   │   └── app_routes.dart            # Route name constants
│   │   └── constants/
│   │       ├── app_constants.dart
│   │       └── env.dart
│   ├── core/
│   │   ├── database/
│   │   │   ├── isar_service.dart          # Local database initialization
│   │   │   └── database_exceptions.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Light/Dark Theme logic
│   │   │   ├── color_schemes.dart         # Material 3 dynamically generated colors
│   │   │   └── typography.dart            # Text styles
│   │   ├── security/
│   │   │   ├── secure_storage.dart        # Encryption key management
│   │   │   └── biometric_service.dart     # Local auth integration
│   │   └── utils/
│   │       ├── date_formatter.dart
│   │       └── logger.dart
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── adaptive_scaffold.dart     # Desktop sidebar + Mobile bottom nav
│   │   │   ├── custom_app_bar.dart
│   │   │   └── empty_state.dart
│   │   └── extensions/
│   │       └── context_extensions.dart
│   └── features/
│       ├── notes/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── note.dart
│       │   │   ├── repositories/
│       │   │   │   └── note_repository.dart
│       │   │   └── usecases/
│       │   │       ├── create_note.dart
│       │   │       ├── delete_note.dart
│       │   │       ├── get_notes.dart
│       │   │       └── update_note.dart
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── note_model.dart    # Isar collection & Freezed model
│       │   │   ├── datasources/
│       │   │   │   └── note_local_data_source.dart
│       │   │   └── repositories/
│       │   │       └── note_repository_impl.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   ├── note_provider.dart
│       │       │   └── note_list_state.dart
│       │       ├── screens/
│       │       │   ├── home_screen.dart
│       │       │   └── edit_note_screen.dart
│       │       └── widgets/
│       │           ├── note_card.dart
│       │           └── markdown_toolbar.dart
│       ├── folders/
│       │   ├── domain/
│       │   ├── data/
│       │   └── presentation/
│       ├── tags/
│       │   ├── domain/
│       │   ├── data/
│       │   └── presentation/
│       ├── search/
│       │   ├── domain/
│       │   ├── data/
│       │   └── presentation/
│       │       └── screens/
│       │           └── search_screen.dart
│       ├── backup/
│       │   ├── domain/
│       │   ├── data/
│       │   └── presentation/
│       ├── settings/
│       │   └── presentation/
│       │       └── screens/
│       │           └── settings_screen.dart
│       └── reminders/
│           ├── domain/
│           ├── data/
│           └── presentation/
└── test/
    ├── features/
    │   └── notes/
    │       ├── domain/
    │       ├── data/
    │       └── presentation/
    └── core/
```

## Layer Responsibilities

1. **Domain Layer**: 
   - Pure Dart code. No Flutter dependencies. 
   - Contains enterprise business rules (Entities), application business rules (Use Cases), and abstract interfaces (Repositories).
2. **Data Layer**: 
   - Handles data retrieval and storage. 
   - Implements the Repositories defined in the Domain layer. 
   - Contains DTOs (Data Transfer Objects), Isar Collections, and local data sources.
3. **Presentation Layer**: 
   - Flutter UI code (Widgets, Screens). 
   - Riverpod StateNotifiers/Providers acting as Presenters/Controllers to link UI with Use Cases.
4. **Core**:
   - Cross-cutting concerns like Database connection, Security services, Theme, and Error Handling.
5. **Shared**:
   - Reusable UI components and utilities that are not specific to a single feature.
