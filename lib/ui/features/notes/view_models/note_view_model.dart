import 'package:flutter/material.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/data/repositories/note_repository_impl.dart';
import 'package:purenote/data/services/notification_service.dart';
import 'package:purenote/data/services/sync_service.dart';

enum NoteSortOption { dateModifiedDesc, dateCreatedDesc, titleAsc }

class NoteViewModel extends ChangeNotifier {
  final NoteRepositoryImpl repository;
  final NotificationService notificationService;
  final SyncService syncService;

  List<Note> _allNotes = [];
  List<Note> _notes = [];
  List<Note> _trashedNotes = [];
  bool _isLoading = false;
  String? _selectedFolderId;
  NoteSortOption _sortOption = NoteSortOption.dateModifiedDesc;

  List<Note> get notes => _notes;
  List<Note> get trashedNotes => _trashedNotes;
  bool get isLoading => _isLoading;
  String? get selectedFolderId => _selectedFolderId;

  NoteViewModel({
    required this.repository,
    required this.notificationService,
    required this.syncService,
  }) {
    repository.cleanUpTrash().then((_) {
      _loadNotes();
    });
  }

  Future<void> _loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _allNotes = await repository.getNotes();
    _applyFiltersAndSort();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadAll() async {
    await _loadNotes();
    await loadTrashedNotes();
  }

  Future<void> loadTrashedNotes() async {
    _trashedNotes = await repository.getTrashedNotes();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    var filtered = _allNotes.where((note) => !note.isTrashed).toList();

    if (_selectedFolderId != null) {
      filtered = filtered.where((note) => note.folderId == _selectedFolderId).toList();
    }

    filtered.sort((a, b) {
      switch (_sortOption) {
        case NoteSortOption.dateModifiedDesc:
          return b.updatedAt.compareTo(a.updatedAt);
        case NoteSortOption.dateCreatedDesc:
          return b.createdAt.compareTo(a.createdAt);
        case NoteSortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    _notes = filtered;
  }

  void selectFolder(String? folderId) {
    _selectedFolderId = folderId;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void changeSortOption(NoteSortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await repository.addNote(note);
    await _loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await repository.updateNote(note);
    await _loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await repository.deleteNote(id);
    await _loadNotes();
    await loadTrashedNotes();
  }

  Future<void> deleteMultipleNotes(List<String> ids) async {
    for (final id in ids) {
      await repository.moveToTrash(id);
    }
    await _loadNotes();
  }

  Future<void> moveToTrash(String id) async {
    await repository.moveToTrash(id);
    await _loadNotes();
  }

  Future<void> restoreFromTrash(String id) async {
    await repository.restoreFromTrash(id);
    await _loadNotes();
    await loadTrashedNotes();
  }

  Future<void> emptyTrash() async {
    try {
      final trashedIds = _trashedNotes.map((n) => n.id).toList();
      if (trashedIds.isNotEmpty) {
        await repository.deleteMultipleNotes(trashedIds);
        await loadTrashedNotes();
      }
    } catch (e) {
      debugPrint('Error emptying trash: $e');
    }
  }

  Future<void> syncNotes(void Function(String message) onResult) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await syncService.syncWithCloud();
      onResult(response.message);
    } catch (e) {
      onResult('Sync error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setReminder(Note note, DateTime time) async {
    final updated = note.copyWith(reminderDate: time, updatedAt: DateTime.now());
    await updateNote(updated);
    await notificationService.scheduleReminder(note.id, note.title, note.content, time);
  }

  Future<void> clearReminder(Note note) async {
    final updated = note.clearReminder();
    await updateNote(updated);
    await notificationService.cancelReminder(note.id);
  }

  Future<void> toggleFavorite(Note note) async {
    final updated = note.copyWith(
      isFavorite: !note.isFavorite,
      updatedAt: DateTime.now(),
    );
    await updateNote(updated);
  }

  Future<void> toggleLock(Note note) async {
    final updated = note.copyWith(
      isLocked: !note.isLocked,
      updatedAt: DateTime.now(),
    );
    await updateNote(updated);
  }
}
