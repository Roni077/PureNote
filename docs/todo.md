# PureNote Implementation Roadmap

This is the detailed, step-by-step TODO list for the PureNote application, adhering to Clean Architecture and modern Flutter best practices.

---

## Phase 1: Core Scaffolding & Configuration
- [x] Initialize standard Flutter project structure
- [x] Add `pubspec.yaml` dependencies (Riverpod, Isar, Freezed, GoRouter, WindowManager, etc.)
- [x] Create `lib/core`, `lib/shared`, `lib/features`, `lib/config`, `lib/app` directories.
- [x] Configure `build.yaml` for code generation.
- [x] Implement `AppTheme` with Material 3 dynamic color support.
- [x] Set up `GoRouter` in `lib/config/router/app_router.dart`.
- [x] Initialize `window_manager` in `main.dart` for desktop window sizing/persistence.
- [ ] Create adaptive layout wrapper (`lib/shared/widgets/adaptive_scaffold.dart`).

## Phase 2: Domain & Data Layer (Notes)
- [x] Create `Note` entity (Domain).
- [x] Create `NoteModel` using `@freezed` and `@collection` (Isar) annotations (Data).
- [x] Run `build_runner` to generate Isar schema and Freezed boilerplate.
- [x] Create `NoteRepository` interface (Domain).
- [x] Implement `NoteLocalDataSource` using Isar (Data).
- [x] Implement `NoteRepositoryImpl` (Data).
- [x] Create Use Cases: `CreateNote`, `GetNotes`, `UpdateNote`, `DeleteNote`, `PinNote`, `ArchiveNote` (Domain).

## Phase 3: Presentation - Home Screen & Note State
- [x] Create `NoteNotifier` and `notesProvider` (Riverpod) to manage note state.
- [x] Build `NoteCard` widget for displaying note previews in grid/list.
- [x] Implement `HomeScreen` with `flutter_staggered_grid_view` to display notes.
- [x] Add sorting capabilities to the state (by Date, Title).
- [x] Implement Batch Action UI (Multi-select, delete, archive).
- [x] Handle Empty States and Pull-to-Refresh UI.

## Phase 4: The Markdown Editor
- [x] Build `EditNoteScreen` UI (Title field, Markdown body field).
- [x] Implement Riverpod state for auto-saving (debounce input).
- [x] Integrate a markdown renderer for Live Preview.
- [x] Build `MarkdownToolbar` widget for inserting bold, italics, links, checklists, etc.
- [ ] Implement Word Count, Character Count, and Reading Time indicators.
- [ ] Add Undo/Redo support to the editor.

## Phase 5: Folders & Organization
- [x] Create `Folder` entity, model, and Isar schema.
- [x] Implement Folder CRUD Use Cases and Repository.
- [x] Build `FolderNotifier` provider.
- [x] Create Sidebar/Drawer UI for managing and selecting folders.
- [x] Update Note Model/Schema to establish a many-to-one relationship with Folders.
- [x] Update Home Screen to filter notes by selected Folder.

## Phase 6: Tags & Metadata
- [x] Create `Tag` entity, model, and Isar schema.
- [x] Establish many-to-many relationship between Notes and Tags in Isar.
- [x] Build UI to create, edit, and assign Tags to a Note within `EditNoteScreen`.
- [x] Update Sidebar/Drawer to display Tags.
- [x] Update Home Screen to filter notes by selected Tag.

## Phase 7: Search Engine
- [x] Build `SearchScreen` UI.
- [x] Create `SearchNotifier` provider to manage search queries.
- [x] Implement fast full-text search using Isar's index capabilities.
- [x] Implement search filters (By Folder, By Tag, By Date).
- [ ] Add keyboard shortcut listener (`Ctrl+Shift+F`) to open Search globally on Desktop.

## Phase 8: Advanced Note Lifecycle & Reminders
- [x] Implement Trash Bin UI and logic (Restore, Permanent Delete).
- [x] Create `Reminder` entity and link to Notes.
- [x] Integrate `flutter_local_notifications` for cross-platform local alarms.
- [x] Build UI to set One-Time, Daily, Weekly, and Monthly reminders on notes.

### Phase 9: Backup & Restore (Completed)
- [x] Export database (Notes, Folders, Tags) to JSON file.
- [x] Import from JSON file (overwrite or merge).
- [x] File picker integration.
- [x] Manual export database or individual notes as JSON/TXT/Markdown.
- [x] Implement Import logic to deserialize JSON backups back into Isar.
- [x] Integrate `share_plus` for exporting files on mobile.

## Phase 10: Security & Settings (Completed)
- [x] Setup `flutter_secure_storage` to handle App Lock keys.
- [x] Integrate `local_auth` for Biometrics (Face/Fingerprint) and PIN screen.
- [x] Build App Lock interceptor widget.
- [x] Build comprehensive `SettingsScreen` (Theme switching, Editor defaults, Backup settings).

## Phase 11: Final Polish & Desktop Shortcuts (Completed)
- [x] Finalize responsive UI padding and constraints.
- [x] Register global desktop keyboard shortcuts (`Ctrl+N`, `Ctrl+S`, `Ctrl+D`, `Ctrl+P`).
- [x] Implement Desktop Context Menus (right-click) for Note Cards.
- [x] Accessibility review (Semantic labels, High Contrast, Screen reader testing).
- [x] Extensive real-device testing across Android, iOS, and Windows.

## Phase 12: Onboarding & Setup Screen
- [ ] Create `OnboardingScreen` UI (Welcome, Features overview).
- [ ] Add permission request step in onboarding (Notifications, Storage).
- [ ] Save onboarding completion state in `shared_preferences` or `SettingsViewModel`.
- [ ] Update router to show `OnboardingScreen` on first launch instead of `HomeScreen`.

## Phase 13: Release Preparation & Theming Polish
- [x] Implement Note Preview Screen (Hero animations, syntax highlighting, metadata).
- [ ] Generate and apply custom App Icons.
- [ ] Generate and apply custom Launch Screens.
- [ ] Setup Android Keystore and code signing for release (arm64-v8a).

## Phase 14: Rich Text Editor & Formatting Toolbar
- [x] Install `flutter_quill` and `flex_color_picker`.
- [x] Create `FormattingState` provider for toolbar logic.
- [x] Build custom Material 3 `FormattingToolbar` and buttons.
- [x] Update `NoteEditorScreen` to use `QuillEditor` and `QuillController`.
- [x] Update `NotePreviewScreen` to render Delta JSON.
- [x] Add legacy Markdown fallback migration logic.
