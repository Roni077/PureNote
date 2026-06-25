import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/l10n/app_localizations.dart';

class NewNoteIntent extends Intent {
  const NewNoteIntent();
}

// Removed SearchIntent

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
      },
      child: Actions(
        actions: {
          NewNoteIntent: CallbackAction<NewNoteIntent>(
            onInvoke: (intent) {
              context.push('/editor');
              return null;
            },
          ),
        },
        child: Scaffold(
          extendBody: true,
          body: navigationShell,
          bottomNavigationBar: CustomFloatingNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => _onTap(context, index),
          ),
        ),
      ),
    );
  }
}

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomFloatingNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      icon: Icons.edit_document,
                      label: AppLocalizations.of(context)!.allNotes,
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    const SizedBox(width: 48), // Space for FAB
                    _NavBarItem(
                      icon: Icons.settings,
                      label: AppLocalizations.of(context)!.settings,
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
            Positioned(
              top: -20,
              child: FloatingActionButton(
                onPressed: () => context.push('/editor'),
                elevation: 4,
                backgroundColor: isDark ? Colors.blueGrey[800] : theme.colorScheme.primary,
                foregroundColor: isDark ? Colors.white : theme.colorScheme.onPrimary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 32),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isSelected 
        ? theme.primaryColor 
        : (isDark ? Colors.white70 : Colors.black54);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: isSelected ? 26 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
