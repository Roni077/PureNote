import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_providers.dart';
import 'create_folder_dialog.dart';
import '../../../tags/presentation/widgets/create_tag_dialog.dart';

class FolderListWidget extends ConsumerWidget {
  const FolderListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderState = ref.watch(folderNotifierProvider);
    final folderNotifier = ref.read(folderNotifierProvider.notifier);
    
    final tagState = ref.watch(tagNotifierProvider);
    final tagNotifier = ref.read(tagNotifierProvider.notifier);

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
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notes),
                    title: const Text('All Notes'),
                    selected: folderState.selectedFolderId == null && tagState.selectedTagId == null,
                    onTap: () {
                      folderNotifier.selectFolder(null);
                      tagNotifier.selectTag(null);
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  const Divider(),
                  
                  // FOLDERS SECTION
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
                    ...folderState.folders.map((folder) {
                      return ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(folder.name),
                        selected: folderState.selectedFolderId == folder.id,
                        onTap: () {
                          folderNotifier.selectFolder(folder.id);
                          Navigator.pop(context); // Close drawer
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Folder?'),
                              content: Text('Are you sure you want to delete "${folder.name}"?'),
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
                                    folderNotifier.deleteFolder(folder.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),

                  const Divider(),

                  // TAGS SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TAGS',
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
                              builder: (context) => const CreateTagDialog(),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  if (tagState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ...tagState.tags.map((tag) {
                      return ListTile(
                        leading: const Icon(Icons.tag),
                        title: Text(tag.name),
                        selected: tagState.selectedTagId == tag.id,
                        onTap: () {
                          tagNotifier.selectTag(tag.id);
                          Navigator.pop(context); // Close drawer
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Tag?'),
                              content: Text('Are you sure you want to delete "${tag.name}"?'),
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
                                    tagNotifier.deleteTag(tag.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
