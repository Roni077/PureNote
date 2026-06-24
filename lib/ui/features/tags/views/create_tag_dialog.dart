import 'package:purenote/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/domain/models/tag.dart';
import 'package:purenote/ui/features/tags/view_models/tag_view_model.dart';

class CreateTagDialog extends StatefulWidget {
  const CreateTagDialog({super.key});

  @override
  State<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<CreateTagDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final newTag = Tag(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      );
      context.read<TagViewModel>().addTag(newTag);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.newTag),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(hintText: 'Tag Name'),
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.create),
        ),
      ],
    );
  }
}
