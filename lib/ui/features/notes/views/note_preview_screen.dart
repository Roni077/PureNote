import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';
import 'package:purenote/ui/features/notes/widgets/preview_metadata_row.dart';
import 'package:purenote/l10n/app_localizations.dart';

class NotePreviewScreen extends StatefulWidget {
  final String noteId;

  const NotePreviewScreen({super.key, required this.noteId});

  @override
  State<NotePreviewScreen> createState() => _NotePreviewScreenState();
}

class _NotePreviewScreenState extends State<NotePreviewScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  
  QuillController? _quillController;
  final FocusNode _focusNode = FocusNode();
  String? _lastContent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _quillController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, noteViewModel, child) {
        final note = noteViewModel.notes.firstWhere(
          (n) => n.id == widget.noteId,
          orElse: () => noteViewModel.trashedNotes.firstWhere(
            (n) => n.id == widget.noteId,
            orElse: () => Note(
              id: '',
              title: 'Note not found',
              content: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
        );

        if (note.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: Text('Note not found')),
          );
        }

        // Catch folder exceptions if folder is deleted
        String? displayFolderName;
        try {
          if (note.folderId != null) {
            displayFolderName = context.read<FolderViewModel>().folders.firstWhere((f) => f.id == note.folderId).name;
          }
        } catch (_) {}

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildAppBar(context, note, noteViewModel),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: 'note_title_${note.id}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    note.title.isEmpty ? AppLocalizations.of(context)!.untitled : note.title,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              PreviewMetadataRow(
                                note: note,
                                folderName: displayFolderName,
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              _buildPreviewContent(note, context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildBottomActionBar(context, note, noteViewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Note note, NoteViewModel viewModel) {
    return SliverAppBar(
      pinned: true,
      title: AnimatedOpacity(
        opacity: _isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(note.isFavorite ? Icons.star : Icons.star_border),
          onPressed: () {
            viewModel.toggleFavorite(note);
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, note, viewModel, context),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'pin',
              child: Text(note.isPinned ? 'Unpin' : 'Pin'),
            ),
            const PopupMenuItem(value: 'archive', child: Text('Archive')),
            const PopupMenuItem(value: 'move', child: Text('Move')),
            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            const PopupMenuItem(value: 'share', child: Text('Share')),
            const PopupMenuItem(value: 'export', child: Text('Export')),
            PopupMenuItem(
              value: 'lock',
              child: Text(note.isLocked ? 'Unlock Note' : 'Lock Note'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, Note note, NoteViewModel viewModel) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    context.pushNamed(
                      'editor',
                      queryParameters: {
                        'id': note.id.toString(),
                        'folderId': note.folderId ?? '',
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search within note
                  },
                ),
                IconButton(
                  icon: Icon(note.isFavorite ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: () {
                    viewModel.toggleFavorite(note);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    _handleMenuAction('share', note, viewModel, context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _handleMenuAction('delete', note, viewModel, context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Note note, NoteViewModel viewModel, BuildContext context) {
    switch (action) {
      case 'edit':
        context.pushNamed(
          'editor',
          queryParameters: {
            'id': note.id.toString(),
            'folderId': note.folderId ?? '',
          },
        );
        break;
      case 'pin':
        viewModel.updateNote(note.copyWith(isPinned: !note.isPinned));
        break;
      case 'archive':
        viewModel.updateNote(note.copyWith(isArchived: true));
        context.pop();
        break;
      case 'move':
        // Show folder picker
        break;
      case 'duplicate':
        // Duplicate note
        break;
      case 'share':
        // Share via share_plus
        break;
      case 'export':
        // Export logic
        break;
      case 'lock':
        viewModel.toggleLock(note);
        break;
      case 'delete':
        viewModel.updateNote(note.copyWith(isTrashed: true));
        context.pop();
        break;
    }
  }
  void _updateQuillController(String content) {
    if (_lastContent == content) return;
    _lastContent = content;

    Document doc;
    if (content.trimLeft().startsWith('[{')) {
      try {
        doc = Document.fromJson(jsonDecode(content));
      } on FormatException {
        doc = Document()..insert(0, content);
      }
    } else {
      doc = Document()..insert(0, content);
    }

    if (_quillController == null) {
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _quillController!.readOnly = true;
    } else {
      _quillController!.document = doc;
    }
  }

  Widget _buildPreviewContent(Note note, BuildContext context) {
    if (note.content.isEmpty) return const SizedBox.shrink();

    _updateQuillController(note.content);

    return QuillEditor.basic(
      controller: _quillController!,
      focusNode: _focusNode,
      config: const QuillEditorConfig(),
    );
  }
}
