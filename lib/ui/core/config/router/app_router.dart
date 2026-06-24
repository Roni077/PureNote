import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purenote/ui/features/notes/views/home_screen.dart';
import 'package:purenote/ui/features/notes/views/note_editor_screen.dart';
import 'package:purenote/ui/features/settings/views/settings_screen.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/ui/features/notes/views/trash_screen.dart';
import 'package:purenote/ui/features/onboarding/views/onboarding_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        final settingsViewModel = context.watch<SettingsViewModel>();
        if (!settingsViewModel.settings.hasCompletedOnboarding) {
          return const OnboardingScreen();
        }
        return const HomeScreen();
      },
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
    GoRoute(
      path: '/trash',
      name: 'trash',
      builder: (context, state) => const TrashScreen(),
    ),
  ],
);
