import 'package:go_router/go_router.dart';
import 'package:purenote/ui/features/notes/views/home_screen.dart';
import 'package:purenote/ui/features/notes/views/note_editor_screen.dart';
import 'package:purenote/ui/features/settings/views/settings_screen.dart';
import 'package:purenote/ui/features/notes/views/trash_screen.dart';
import 'package:purenote/ui/features/onboarding/views/onboarding_screen.dart';
import 'package:purenote/ui/features/settings/views/appearance_settings_screen.dart';
import 'package:purenote/ui/features/settings/views/backup_settings_screen.dart';
import 'package:purenote/ui/features/settings/views/security_settings_screen.dart';
import 'package:purenote/ui/features/folders/views/folders_screen.dart';
import 'package:purenote/ui/core/widgets/main_scaffold.dart';

bool isFirstLaunch = true;

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    if (isFirstLaunch && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    if (!isFirstLaunch && state.matchedLocation == '/onboarding') {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'appearance',
                  name: 'appearance_settings',
                  builder: (context, state) => const AppearanceSettingsScreen(),
                ),
                GoRoute(
                  path: 'security',
                  name: 'security_settings',
                  builder: (context, state) => const SecuritySettingsScreen(),
                ),
                GoRoute(
                  path: 'backup',
                  name: 'backup_settings',
                  builder: (context, state) => const BackupSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
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
      path: '/folders',
      name: 'folders',
      builder: (context, state) => const FoldersScreen(),
    ),
    GoRoute(
      path: '/trash',
      name: 'trash',
      builder: (context, state) => const TrashScreen(),
    ),
  ],
);
