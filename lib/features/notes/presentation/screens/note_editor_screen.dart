import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/debouncer.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../../../../app/app_providers.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String? folderId;

  const NoteEditorScreen({super.key, this.noteId, this.folderId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Debouncer _debouncer;

  Note? _currentNote;
  bool _isInitialized = false;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _debouncer = Debouncer(milliseconds: 500);

    // Auto-save listeners
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadNote();
      _isInitialized = true;
    }
  }

  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      // Find note in state
      final notes = ref.read(noteNotifierProvider).notes;
      try {
        _currentNote = notes.firstWhere((n) => n.id == widget.noteId);
        _titleController.text = _currentNote!.title;
        _contentController.text = _currentNote!.content;
      } catch (e) {
        // Note not found
        _currentNote = null;
      }
    }

    if (_currentNote == null) {
      // Create new note immediately so we can auto-save
      _currentNote = Note(
        id: const Uuid().v4(),
        title: '',
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        folderId: widget.folderId,
      );
      // Wait for build cycle to complete before modifying provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
         ref.read(noteNotifierProvider.notifier).addNote(_currentNote!);
      });
    }
    setState(() {});
  }

  void _onTextChanged() {
    final isAutoSaveEnabled = ref.read(settingsNotifierProvider).settings.isAutoSaveEnabled;
    if (isAutoSaveEnabled) {
      _debouncer.run(() {
        _saveNote();
      });
    }
  }

  Future<void> _saveNote() async {
    if (_currentNote == null) return;

    final updatedNote = _currentNote!.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );

    _currentNote = updatedNote;
    await ref.read(noteNotifierProvider.notifier).updateNote(updatedNote);
  }

  @override
  void dispose() {
    // Save one last time on dispose immediately
    _saveNote();
    _titleController.dispose();
    _contentController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _insertMarkdown(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    
    if (selection.start == -1) {
      _contentController.text = text + prefix + suffix;
      return;
    }

    final newText = text.replaceRange(selection.start, selection.end, prefix + text.substring(selection.start, selection.end) + suffix);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + prefix.length + (selection.end - selection.start)),
    );
  }

  void _showTagSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final tagState = ref.watch(tagNotifierProvider);
            final allTags = tagState.tags;
            final currentTagIds = _currentNote?.tagIds ?? [];

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Select Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const Divider(height: 1),
                  if (allTags.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No tags created yet.'),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allTags.length,
                        itemBuilder: (context, index) {
                          final tag = allTags[index];
                          final isSelected = currentTagIds.contains(tag.id);
                          return CheckboxListTile(
                            title: Text(tag.name),
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value == true) {
                                setState(() {
                                  _currentNote = _currentNote!.copyWith(tagIds: [...currentTagIds, tag.id]);
                                });
                                _saveNote();
                              } else {
                                setState(() {
                                  _currentNote = _currentNote!.copyWith(
                                    tagIds: currentTagIds.where((id) => id != tag.id).toList(),
                                  );
                                });
                                _saveNote();
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNote == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = ref.watch(settingsNotifierProvider).settings;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!settings.isAutoSaveEnabled)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _saveNote();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note saved'), duration: Duration(seconds: 1)),
                );
              },
            ),
          IconButton(
            icon: Icon(_currentNote!.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () async {
              await ref.read(noteNotifierProvider.notifier).togglePin(_currentNote!);
              setState(() {
                _currentNote = _currentNote!.copyWith(isPinned: !_currentNote!.isPinned);
              });
            },
          ),
          IconButton(
            icon: Icon(_currentNote!.isArchived ? Icons.archive : Icons.archive_outlined),
            onPressed: () {
              ref.read(noteNotifierProvider.notifier).toggleArchive(_currentNote!);
              setState(() {
                _currentNote = _currentNote!.copyWith(isArchived: !_currentNote!.isArchived);
              });
              context.pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.label_outline),
            onPressed: () => _showTagSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: () {
              // Show color picker dialog (to be implemented)
            },
          ),
          if (settings.isMarkdownEnabled)
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isPreviewMode = !_isPreviewMode;
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isPreviewMode && settings.isMarkdownEnabled
            ? Markdown(
                data: '# ${_titleController.text}\n\n${_contentController.text}',
                padding: const EdgeInsets.all(24.0),
              )
            : Column(
                children: [
                  if (settings.isMarkdownEnabled)
                    // Formatting Toolbar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.format_bold), onPressed: () => _insertMarkdown('**', '**')),
                          IconButton(icon: const Icon(Icons.format_italic), onPressed: () => _insertMarkdown('*', '*')),
                          IconButton(icon: const Icon(Icons.format_list_bulleted), onPressed: () => _insertMarkdown('- ', '')),
                          IconButton(icon: const Icon(Icons.format_list_numbered), onPressed: () => _insertMarkdown('1. ', '')),
                          IconButton(icon: const Icon(Icons.check_box_outlined), onPressed: () => _insertMarkdown('- [ ] ', '')),
                        ],
                      ),
                    ),
                  if (settings.isMarkdownEnabled) const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            decoration: const InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _contentController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: const InputDecoration(
                                hintText: 'Start writing...',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                filled: false,
                              ),
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
