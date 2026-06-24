import 'package:purenote/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/ui/core/utils/debouncer.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  final String? folderId;

  const NoteEditorScreen({super.key, this.noteId, this.folderId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Note? _currentNote;
  bool _isEditing = true;
  final _debouncer = Debouncer(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNote();
    });
  }

  void _loadNote() {
    if (widget.noteId != null) {
      final noteViewModel = context.read<NoteViewModel>();
      final note = noteViewModel.notes.cast<Note?>().firstWhere(
            (n) => n?.id.toString() == widget.noteId,
            orElse: () => null,
          );
      if (note != null) {
        setState(() {
          _currentNote = note;
          _titleController.text = note.title;
          _contentController.text = note.content;
        });
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
    _titleController.dispose();
    _contentController.dispose();
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
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) return;
    if (_currentNote == null) return;

    final noteViewModel = context.read<NoteViewModel>();
    
    // Check if the note already exists in the VM to decide add vs update
    final exists = noteViewModel.notes.any((n) => n.id == _currentNote!.id);

    final updatedNote = _currentNote!.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );

    if (!exists) {
      await noteViewModel.addNote(updatedNote);
      _currentNote = updatedNote;
    } else {
      await noteViewModel.updateNote(updatedNote);
      if (mounted) {
        Navigator.pop(context);
      }
      _currentNote = updatedNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final isMarkdownEnabled = settingsViewModel.settings.isMarkdownEnabled;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_currentNote?.reminderDate != null ? Icons.alarm_on : Icons.add_alarm),
            tooltip: _currentNote?.reminderDate != null ? 'Clear Reminder' : 'Set Reminder',
            onPressed: () async {
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
          IconButton(
            icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveNote();
              context.pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isEditing)
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.titleHint,
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
                onChanged: (_) => _onContentChanged(),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            const Divider(),
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Start typing...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                      onChanged: (_) => _onContentChanged(),
                    )
                  : isMarkdownEnabled
                      ? Markdown(
                          data: _contentController.text,
                          padding: EdgeInsets.zero,
                        )
                      : SingleChildScrollView(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(_contentController.text),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
