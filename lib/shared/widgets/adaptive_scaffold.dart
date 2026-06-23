import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final String title;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.floatingActionButton,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      drawer: isDesktop ? null : drawer,
      body: Row(
        children: [
          if (isDesktop && drawer != null)
            SizedBox(
              width: 280,
              child: drawer,
            ),
          if (isDesktop && drawer != null) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
