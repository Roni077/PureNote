import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichTextEditor extends StatelessWidget {
  final QuillController controller;
  final bool readOnly;
  final FocusNode focusNode;

  const RichTextEditor({
    super.key,
    required this.controller,
    required this.readOnly,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    // controller.readOnly is how v11 does readOnly
    controller.readOnly = readOnly;

    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: QuillEditor.basic(
          controller: controller,
          focusNode: focusNode,
          config: const QuillEditorConfig(),
        ),
      ),
    );
  }
}
