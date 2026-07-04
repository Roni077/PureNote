import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class HeadingDropdown extends StatelessWidget {
  final QuillController controller;
  final int currentHeading;

  const HeadingDropdown({
    super.key,
    required this.controller,
    required this.currentHeading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentHeading,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isDense: true,
          style: Theme.of(context).textTheme.bodyMedium,
          onChanged: (int? newValue) {
            if (newValue != null) {
              if (newValue == 0) {
                controller.formatSelection(Attribute.header); // Paragraph
              } else {
                switch (newValue) {
                  case 1: controller.formatSelection(Attribute.h1); break;
                  case 2: controller.formatSelection(Attribute.h2); break;
                  case 3: controller.formatSelection(Attribute.h3); break;
                  case 4: controller.formatSelection(Attribute.h4); break;
                  case 5: controller.formatSelection(Attribute.h5); break;
                  case 6: controller.formatSelection(Attribute.h6); break;
                }
              }
            }
          },
          items: const [
            DropdownMenuItem(value: 0, child: Text('Paragraph')),
            DropdownMenuItem(value: 1, child: Text('Heading 1')),
            DropdownMenuItem(value: 2, child: Text('Heading 2')),
            DropdownMenuItem(value: 3, child: Text('Heading 3')),
            DropdownMenuItem(value: 4, child: Text('Heading 4')),
            DropdownMenuItem(value: 5, child: Text('Heading 5')),
            DropdownMenuItem(value: 6, child: Text('Heading 6')),
          ],
        ),
      ),
    );
  }
}
