import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/l10n/app_localizations.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  @override
  void initState() {
    super.initState();
    // Load trashed notes when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteViewModel>().loadTrashedNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteViewModel>();
    final trashedNotes = viewModel.trashedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (trashedNotes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Empty Trash',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Empty Trash?'),
                    content: const Text('This will permanently delete all items in the trash. This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          viewModel.emptyTrash();
                          Navigator.pop(context);
                        },
                        child: const Text('Empty', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: trashedNotes.isEmpty
          ? const Center(child: Text('Trash is empty.'))
          : ListView.builder(
              itemCount: trashedNotes.length,
              itemBuilder: (context, index) {
                final note = trashedNotes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore),
                        tooltip: 'Restore',
                        onPressed: () {
                          viewModel.restoreFromTrash(note.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever),
                        tooltip: 'Delete Permanently',
                        onPressed: () {
                          viewModel.deleteNote(note.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
