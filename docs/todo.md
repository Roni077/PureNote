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
- [ ] Add sorting capabilities to the state (by Date, Title).
- [ ] Implement Batch Action UI (Multi-select, delete, archive).
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
- [ ] Implement Trash Bin UI and logic (Restore, Permanent Delete).
- [ ] Create `Reminder` entity and link to Notes.
- [ ] Integrate `flutter_local_notifications` for cross-platform local alarms.
- [ ] Build UI to set One-Time, Daily, Weekly, and Monthly reminders on notes.

## Phase 9: Backup & Restore
- [ ] Create Backup Service using `path_provider`.
- [ ] Implement Isar database export to JSON format.
- [ ] Build UI in Settings to manually export database or individual notes as JSON/TXT/Markdown.
- [ ] Implement Import logic to deserialize JSON backups back into Isar.
- [ ] Integrate `share_plus` for exporting files on mobile.

## Phase 10: Security & Settings
- [ ] Setup `flutter_secure_storage` to handle App Lock keys.
- [ ] Integrate `local_auth` for Biometrics (Face/Fingerprint) and PIN screen.
- [ ] Build App Lock interceptor widget.
- [x] Build comprehensive `SettingsScreen` (Theme switching, Editor defaults, Backup settings).

## Phase 11: Final Polish & Desktop Shortcuts
- [ ] Finalize responsive UI padding and constraints.
- [ ] Register global desktop keyboard shortcuts (`Ctrl+N`, `Ctrl+S`, `Ctrl+D`, `Ctrl+P`).
- [ ] Implement Desktop Context Menus (right-click) for Note Cards.
- [ ] Accessibility review (Semantic labels, High Contrast, Screen reader testing).
- [ ] Extensive real-device testing across Android, iOS, and Windows.
