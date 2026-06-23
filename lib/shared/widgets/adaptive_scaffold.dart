import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final String title;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: Text(title)),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.notes),
                  label: Text('Notes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder),
                  label: Text('Folders'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (index) {
                // Navigation logic will go here
              },
              extended: MediaQuery.of(context).size.width >= 1000,
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
