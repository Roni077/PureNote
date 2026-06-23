import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_providers.dart';
import 'create_folder_dialog.dart';

class FolderListWidget extends ConsumerWidget {
  const FolderListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderState = ref.watch(folderNotifierProvider);
    final notifier = ref.read(folderNotifierProvider.notifier);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'PureNote',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('All Notes'),
              selected: folderState.selectedFolderId == null,
              onTap: () {
                notifier.selectFolder(null);
                Navigator.pop(context); // Close drawer
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FOLDERS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const CreateFolderDialog(),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            if (folderState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: folderState.folders.length,
                  itemBuilder: (context, index) {
                    final folder = folderState.folders[index];
                    return ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(folder.name),
                      selected: folderState.selectedFolderId == folder.id,
                      onTap: () {
                        notifier.selectFolder(folder.id);
                        Navigator.pop(context); // Close drawer
                      },
                      onLongPress: () {
                        // Show delete confirmation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Folder?'),
                            content: Text('Are you sure you want to delete "${folder.name}"? Notes inside will not be deleted, but will be removed from this folder.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  foregroundColor: Theme.of(context).colorScheme.onError,
                                ),
                                onPressed: () {
                                  notifier.deleteFolder(folder.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
