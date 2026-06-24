import 'package:go_router/go_router.dart';
import 'package:purenote/ui/features/notes/views/home_screen.dart';
import 'package:purenote/ui/features/notes/views/note_editor_screen.dart';
import 'package:purenote/ui/features/settings/views/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/editor',
      name: 'editor',
      builder: (context, state) {
        final noteId = state.uri.queryParameters['id'];
        final folderId = state.uri.queryParameters['folderId'];
        return NoteEditorScreen(noteId: noteId, folderId: folderId);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
