
import 'package:purenote/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purenote/ui/features/notes/views/note_card.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

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

  void _showContextMenu(BuildContext context, Offset offset, dynamic note, NoteViewModel viewModel) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
      items: [
        PopupMenuItem(
          value: 'open',
          child: const Text('Open'),
          onTap: () {
            context.pushNamed(
              'editor',
              queryParameters: {
                'id': note.id.toString(),
              },
            );
          },
        ),
        PopupMenuItem(
          value: 'pin',
          child: Text(note.isPinned ? 'Unpin' : 'Pin'),
          onTap: () {
            viewModel.updateNote(note.copyWith(isPinned: !note.isPinned));
          },
        ),
        PopupMenuItem(
          value: 'archive',
          child: const Text('Archive'),
          onTap: () {
            viewModel.updateNote(note.copyWith(isArchived: true));
          },
        ),
        PopupMenuItem(
          value: 'delete',
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: () {
            viewModel.updateNote(note.copyWith(isTrashed: true));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              title: const Text('PureNote', style: TextStyle(fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined),
                  tooltip: AppLocalizations.of(context)!.folders,
                  onPressed: () {
                    context.pushNamed('folders');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: AppLocalizations.of(context)!.syncNotes,
                  onPressed: () {
                    context.read<NoteViewModel>().syncNotes((message) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    });
                  },
                ),
                PopupMenuButton<NoteSortOption>(
                  onSelected: (option) {
                    context.read<NoteViewModel>().changeSortOption(option);
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              leading: const Icon(Icons.search),
              hintText: AppLocalizations.of(context)!.search,
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
              ],
              elevation: WidgetStateProperty.all(2),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          
          // Folder Filter Chips
          Consumer<FolderViewModel>(
            builder: (context, folderViewModel, child) {
              final folders = folderViewModel.folders;
              final selectedId = folderViewModel.selectedFolderId;
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: folders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = selectedId == null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.allNotes),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              folderViewModel.selectFolder(null);
                            }
                          },
                        ),
                      );
                    }
                    final folder = folders[index - 1];
                    final isSelected = selectedId == folder.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(folder.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            folderViewModel.selectFolder(folder.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          Expanded(
            child: Consumer<NoteViewModel>(
              builder: (context, noteViewModel, child) {
                final allNotes = noteViewModel.notes;
                final notes = _searchQuery.isEmpty 
                    ? allNotes 
                    : allNotes.where((note) => 
                        note.title.toLowerCase().contains(_searchQuery) ||
                        note.content.toLowerCase().contains(_searchQuery)).toList();
                        
                return noteViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notes.isEmpty
                        ? const Center(child: Text('No notes found.'))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 100.0), // Padding for Floating Nav Bar
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              final isSelected = _selectedNoteIds.contains(note.id);
                              return GestureDetector(
                                onLongPress: () => _toggleSelectionMode(note.id),
                                onSecondaryTapDown: (details) {
                                  _showContextMenu(context, details.globalPosition, note, noteViewModel);
                                },
                                onTap: () {
                                  if (_isSelectionMode) {
                                    _toggleSelectionMode(note.id);
                                  } else {
                                    context.pushNamed(
                                      'preview',
                                      queryParameters: {
                                        'id': note.id.toString(),
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
                          );
              },
            ),
          ),
        ],
      ),
    );
  }
}
