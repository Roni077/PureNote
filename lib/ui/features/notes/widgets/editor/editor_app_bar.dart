import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EditorAppBar extends StatefulWidget implements PreferredSizeWidget {
  final QuillController controller;
  final TextEditingController titleController;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final VoidCallback onSave;
  final VoidCallback onReminder;
  final bool hasReminder;

  const EditorAppBar({
    super.key,
    required this.controller,
    required this.titleController,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onSave,
    required this.onReminder,
    required this.hasReminder,
  });

  @override
  State<EditorAppBar> createState() => _EditorAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _EditorAppBarState extends State<EditorAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.isEditing
          ? TextField(
              controller: widget.titleController,
              decoration: const InputDecoration(
                hintText: 'Untitled Note',
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.titleLarge,
            )
          : Text(widget.titleController.text.isEmpty ? 'Untitled Note' : widget.titleController.text),
      actions: [
        StreamBuilder(
          stream: widget.controller.changes,
          builder: (context, snapshot) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo (Ctrl+Z)',
                  onPressed: widget.controller.hasUndo ? () => widget.controller.undo() : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: 'Redo (Ctrl+Y)',
                  onPressed: widget.controller.hasRedo ? () => widget.controller.redo() : null,
                ),
              ],
            );
          },
        ),
        IconButton(
          icon: Icon(widget.hasReminder ? Icons.alarm_on : Icons.add_alarm),
          tooltip: widget.hasReminder ? 'Clear Reminder' : 'Set Reminder',
          onPressed: widget.onReminder,
        ),
        IconButton(
          icon: Icon(widget.isEditing ? Icons.visibility : Icons.edit),
          tooltip: widget.isEditing ? 'Preview Mode' : 'Edit Mode',
          onPressed: widget.onToggleEdit,
        ),
        IconButton(
          icon: const Icon(Icons.save),
          tooltip: 'Save',
          onPressed: widget.onSave,
        ),
      ],
    );
  }
}
