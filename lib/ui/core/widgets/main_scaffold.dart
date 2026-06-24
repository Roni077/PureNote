import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/l10n/app_localizations.dart';

class NewNoteIntent extends Intent {
  const NewNoteIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.keyN, control: !Platform.isMacOS, meta: Platform.isMacOS): const NewNoteIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, control: !Platform.isMacOS, meta: Platform.isMacOS): const SearchIntent(),
      },
      child: Actions(
        actions: {
          NewNoteIntent: CallbackAction<NewNoteIntent>(
            onInvoke: (intent) {
              context.push('/editor');
              return null;
            },
          ),
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: (intent) {
              _onTap(context, 2); // Go to Search Tab
              return null;
            },
          ),
        },
        child: Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(context, index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.edit_document),
                label: AppLocalizations.of(context)!.allNotes,
              ),
              NavigationDestination(
                icon: const Icon(Icons.folder),
                label: AppLocalizations.of(context)!.folders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.search),
                label: AppLocalizations.of(context)!.search,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings),
                label: AppLocalizations.of(context)!.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
