import 'package:purenote/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/ui/features/folders/views/folder_list_widget.dart';
import 'package:purenote/ui/features/notes/views/note_card.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';
import 'package:purenote/ui/features/tags/view_models/tag_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode(String noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(noteId);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelectedNotes() async {
    final noteViewModel = context.read<NoteViewModel>();
    await noteViewModel.deleteMultipleNotes(_selectedNoteIds.toList());
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = context.watch<NoteViewModel>();
    final folderViewModel = context.watch<FolderViewModel>();
    final notes = noteViewModel.notes;
    
    final selectedFolderId = folderViewModel.selectedFolderId;
    String appBarTitle = 'All Notes';
    if (selectedFolderId != null) {
      final folder = folderViewModel.folders.firstWhere(
        (f) => f.id == selectedFolderId,
        orElse: () => folderViewModel.folders.first,
      );
      appBarTitle = folder.name;
    }

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
              title: Text(AppLocalizations.of(context)!.selected),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedNotes,
                ),
              ],
            )
          : AppBar(
              title: Text(appBarTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: AppLocalizations.of(context)!.syncNotes,
                  onPressed: () {
                    noteViewModel.syncNotes((message) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _NoteSearchDelegate(),
                    );
                  },
                ),
                PopupMenuButton<NoteSortOption>(
                  onSelected: (option) {
                    noteViewModel.changeSortOption(option);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: NoteSortOption.dateModifiedDesc,
                      child: Text(AppLocalizations.of(context)!.sortByDateModified),
                    ),
                    PopupMenuItem(
                      value: NoteSortOption.dateCreatedDesc,
                      child: Text(AppLocalizations.of(context)!.sortByDateCreated),
                    ),
                    PopupMenuItem(
                      value: NoteSortOption.titleAsc,
                      child: Text(AppLocalizations.of(context)!.sortByTitle),
                    ),
                  ],
                ),
              ],
            ),
      drawer: const Drawer(
        child: FolderListWidget(),
      ),
      body: noteViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(child: Text('No notes found.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final isSelected = _selectedNoteIds.contains(note.id);
                    return GestureDetector(
                      onLongPress: () => _toggleSelectionMode(note.id!),
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelectionMode(note.id!);
                        } else {
                          context.pushNamed(
                            'editor',
                            queryParameters: {
                              'id': note.id.toString(),
                              'folderId': selectedFolderId?.toString() ?? '',
                            },
                          );
                        }
                      },
                      child: Stack(
                        children: [
                          NoteCard(note: note),
                          if (_isSelectionMode)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(
            'editor',
            queryParameters: {
              'folderId': selectedFolderId?.toString() ?? '',
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          context.read<NoteViewModel>().setSearchQuery('');
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
        context.read<NoteViewModel>().setSearchQuery('');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    context.read<NoteViewModel>().setSearchQuery(query);
    return Center(child: Text(AppLocalizations.of(context)!.searchApplied));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
