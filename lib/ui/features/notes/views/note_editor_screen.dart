import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/ui/core/utils/debouncer.dart';
import 'package:purenote/ui/features/notes/widgets/editor/editor_app_bar.dart';
import 'package:purenote/ui/features/notes/widgets/editor/formatting_toolbar.dart';
import 'package:purenote/ui/features/notes/widgets/editor/rich_text_editor.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  final String? folderId;

  const NoteEditorScreen({super.key, this.noteId, this.folderId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  StreamSubscription? _documentSub;
  Note? _currentNote;
  bool _isEditing = true;
  final _debouncer = Debouncer(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNote();
    });

    _documentSub = _quillController.document.changes.listen((_) {
      _onContentChanged();
    });
  }

  void _loadNote() {
    if (widget.noteId != null) {
      final noteViewModel = context.read<NoteViewModel>();
      final note = noteViewModel.notes.where((n) => n.id.toString() == widget.noteId).firstOrNull;
      if (note != null) {
        _currentNote = note;
        _titleController.text = note.title;
        
        if (note.content.isNotEmpty) {
          if (note.content.trimLeft().startsWith('[{')) {
            try {
              final doc = Document.fromJson(jsonDecode(note.content));
              _quillController.document = doc;
            } on Exception {
              _quillController.document = Document()..insert(0, note.content);
            }
          } else {
            // Legacy markdown or plain text
            _quillController.document = Document()..insert(0, note.content);
          }
        }
        setState(() {});
      }
    } else {
      String? defaultFolderId;
      if (widget.folderId != null && widget.folderId!.isNotEmpty) {
        final folders = context.read<FolderViewModel>().folders;
        final f = folders.cast<dynamic>().firstWhere((f) => f.id == widget.folderId, orElse: () => null);
        if (f != null) {
           defaultFolderId = f.id;
        }
      }

      setState(() {
        _currentNote = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          folderId: defaultFolderId,
        );
      });
    }
  }

  @override
  void dispose() {
    _documentSub?.cancel();
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final settings = context.read<SettingsViewModel>().settings;
    if (settings.isAutoSaveEnabled) {
      _debouncer.run(() {
        _saveNote();
      });
    }
  }

  Future<void> _saveNote() async {
    if (!mounted) return;
    
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    
    if (_titleController.text.isEmpty && _quillController.document.isEmpty()) return;
    if (_currentNote == null) return;

    final noteViewModel = context.read<NoteViewModel>();
    
    final exists = noteViewModel.notes.any((n) => n.id == _currentNote!.id);

    final updatedNote = _currentNote!.copyWith(
      title: _titleController.text,
      content: contentJson,
      updatedAt: DateTime.now(),
    );

    if (!exists) {
      await noteViewModel.addNote(updatedNote);
      _currentNote = updatedNote;
    } else {
      await noteViewModel.updateNote(updatedNote);
      _currentNote = updatedNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EditorAppBar(
        controller: _quillController,
        titleController: _titleController,
        isEditing: _isEditing,
        hasReminder: _currentNote?.reminderDate != null,
        onToggleEdit: () {
          setState(() {
            _isEditing = !_isEditing;
          });
        },
        onSave: () async {
          await _saveNote();
          if (context.mounted) {
            context.pop();
          }
        },
        onReminder: () async {
          if (_currentNote == null) return;
          final viewModel = context.read<NoteViewModel>();
          
          if (_currentNote!.reminderDate != null) {
            await viewModel.clearReminder(_currentNote!);
            setState(() {
              _currentNote = _currentNote!.clearReminder();
            });
            return;
          }

          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date == null) return;
          if (!context.mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time == null) return;

          final scheduledTime = DateTime(
            date.year, date.month, date.day,
            time.hour, time.minute,
          );
          
          if (scheduledTime.isAfter(DateTime.now())) {
            await viewModel.setReminder(_currentNote!, scheduledTime);
            setState(() {
              _currentNote = _currentNote!.copyWith(reminderDate: scheduledTime);
            });
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a future time.')));
            }
          }
        },
      ),
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyB, control: true): () {
            _toggleAttribute(Attribute.bold);
          },
          const SingleActivator(LogicalKeyboardKey.keyI, control: true): () {
            _toggleAttribute(Attribute.italic);
          },
          const SingleActivator(LogicalKeyboardKey.keyU, control: true): () {
            _toggleAttribute(Attribute.underline);
          },
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
            if (_quillController.hasUndo) _quillController.undo();
          },
          const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
            if (_quillController.hasRedo) _quillController.redo();
          },
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): () {
            if (_quillController.hasRedo) _quillController.redo();
          },
          const SingleActivator(LogicalKeyboardKey.keyL, control: true): () {
            _toggleAttribute(Attribute.ul);
          },
          const SingleActivator(LogicalKeyboardKey.digit7, control: true, shift: true): () {
            _toggleAttribute(Attribute.ol);
          },
          const SingleActivator(LogicalKeyboardKey.digit8, control: true, shift: true): () {
            _toggleAttribute(Attribute.unchecked);
          },
          const SingleActivator(LogicalKeyboardKey.digit1, control: true, alt: true): () {
            _quillController.formatSelection(Attribute.h1);
          },
          const SingleActivator(LogicalKeyboardKey.digit2, control: true, alt: true): () {
            _quillController.formatSelection(Attribute.h2);
          },
          const SingleActivator(LogicalKeyboardKey.digit3, control: true, alt: true): () {
            _quillController.formatSelection(Attribute.h3);
          },
        },
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              if (_isEditing) FormattingToolbar(controller: _quillController),
              RichTextEditor(
                controller: _quillController,
                readOnly: !_isEditing,
                focusNode: _editorFocusNode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleAttribute(Attribute attribute) {
    final isEnabled = _quillController.getSelectionStyle().containsKey(attribute.key);
    if (isEnabled) {
      _quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      _quillController.formatSelection(attribute);
    }
  }
}
