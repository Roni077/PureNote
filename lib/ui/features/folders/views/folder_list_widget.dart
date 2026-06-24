import 'package:purenote/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';
import 'package:purenote/ui/features/tags/view_models/tag_view_model.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/folders/views/create_folder_dialog.dart';
import 'package:purenote/ui/features/tags/views/create_tag_dialog.dart';

class FolderListWidget extends StatelessWidget {
  const FolderListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final folderViewModel = context.watch<FolderViewModel>();
    final tagViewModel = context.watch<TagViewModel>();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text(
            'PureNote',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notes),
          title: Text(AppLocalizations.of(context)!.allNotes),
          selected: folderViewModel.selectedFolderId == null,
          onTap: () {
            folderViewModel.selectFolder(null);
            context.read<NoteViewModel>().selectFolder(null);
            Navigator.pop(context);
          },
        ),
        const Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context)!.folders, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CreateFolderDialog(),
              );
            },
          ),
        ),
        if (folderViewModel.isLoading)
           const Center(child: CircularProgressIndicator())
        else
          ...folderViewModel.folders.map((folder) => ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                selected: folderViewModel.selectedFolderId == folder.id,
                onTap: () {
                  folderViewModel.selectFolder(folder.id);
                  context.read<NoteViewModel>().selectFolder(folder.id);
                  Navigator.pop(context);
                },
                onLongPress: () {
                  folderViewModel.deleteFolder(folder.id);
                },
              )),
        const Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context)!.tags, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CreateTagDialog(),
              );
            },
          ),
        ),
        if (tagViewModel.isLoading)
           const Center(child: CircularProgressIndicator())
        else
          ...tagViewModel.tags.map((tag) => ListTile(
                leading: const Icon(Icons.local_offer, size: 16),
                title: Text(tag.name),
                onLongPress: () {
                  tagViewModel.deleteTag(tag.id);
                },
              )),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Trash'),
          onTap: () {
            Navigator.pop(context);
            context.pushNamed('trash');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(AppLocalizations.of(context)!.appSettings),
          onTap: () {
            Navigator.pop(context);
            context.pushNamed('settings');
          },
        ),
      ],
    );
  }
}
