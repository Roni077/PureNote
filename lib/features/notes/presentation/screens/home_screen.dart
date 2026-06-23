import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/adaptive_scaffold.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../../domain/entities/note.dart';

import '../../../folders/presentation/widgets/folder_list_widget.dart';
import '../../../../app/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<String> _selectedNoteIds = {};
  bool _isSelectionMode = false;
  bool _isSearching = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNoteIds.contains(id)) {
        _selectedNoteIds.remove(id);
      } else {
        _selectedNoteIds.add(id);
      }
      _isSelectionMode = _selectedNoteIds.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;
    final idsToDelete = _selectedNoteIds.toList();
    _clearSelection();
    await ref.read(noteNotifierProvider.notifier).deleteMultipleNotes(idsToDelete);
  }

  void _createNewNote() async {
    final selectedFolderId = ref.read(folderNotifierProvider).selectedFolderId;
    context.pushNamed('editor', queryParameters: {'folderId': selectedFolderId});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noteNotifierProvider);
    final folderState = ref.watch(folderNotifierProvider);
    final tagState = ref.watch(tagNotifierProvider);
    
    final displayedNotes = state.notes.where((n) {
      final matchesFolder = folderState.selectedFolderId == null || n.folderId == folderState.selectedFolderId;
      final matchesTag = tagState.selectedTagId == null || n.tagIds.contains(tagState.selectedTagId);
      return matchesFolder && matchesTag;
    }).toList();

    String title = 'All Notes';
    if (folderState.selectedFolderId != null) {
      final matches = folderState.folders.where((f) => f.id == folderState.selectedFolderId);
      if (matches.isNotEmpty) {
        title = matches.first.name;
      }
    }
    if (tagState.selectedTagId != null) {
      final matches = tagState.tags.where((t) => t.id == tagState.selectedTagId);
      if (matches.isNotEmpty) {
        if (title == 'All Notes') {
          title = matches.first.name;
        } else {
          title += ' - ${matches.first.name}';
        }
      }
    }

    return AdaptiveScaffold(
      title: title,
      drawer: const FolderListWidget(),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _createNewNote,
              child: const Icon(Icons.add),
            ),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, state, title),
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (displayedNotes.isEmpty)
            _buildEmptyState(context)
          else
            _buildNotesGrid(context, displayedNotes),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, NoteState state, String title) {
    if (_isSelectionMode) {
      return SliverAppBar(
        pinned: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _clearSelection,
        ),
        title: Text('${_selectedNoteIds.length} Selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelectedNotes,
          ),
        ],
      );
    }

    return SliverAppBar(
      pinned: true,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
              ),
              onChanged: (query) {
                ref.read(noteNotifierProvider.notifier).setSearchQuery(query);
              },
            )
          : Text(title),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                ref.read(noteNotifierProvider.notifier).setSearchQuery('');
              }
            });
          },
        ),
        PopupMenuButton<NoteSortOption>(
          icon: const Icon(Icons.sort),
          onSelected: (option) {
            ref.read(noteNotifierProvider.notifier).changeSortOption(option);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: NoteSortOption.dateDesc, child: Text('Date (Newest)')),
            PopupMenuItem(value: NoteSortOption.dateAsc, child: Text('Date (Oldest)')),
            PopupMenuItem(value: NoteSortOption.titleAsc, child: Text('Title (A-Z)')),
            PopupMenuItem(value: NoteSortOption.titleDesc, child: Text('Title (Z-A)')),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes, size: 64, color: Theme.of(context).colorScheme.primary.withAlpha(128)),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary.withAlpha(128),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesGrid(BuildContext context, List<Note> notes) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final crossAxisCount = isDesktop ? 4 : 2;

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) {
          final note = notes[index];
          final isSelected = _selectedNoteIds.contains(note.id);

          return NoteCard(
            note: note,
            isSelected: isSelected,
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(note.id);
              } else {
                context.pushNamed('editor', queryParameters: {'id': note.id});
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelection(note.id);
              }
            },
          );
        },
        childCount: notes.length,
      ),
    );
  }
}
