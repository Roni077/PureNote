import 'package:flutter/material.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/data/repositories/note_repository_impl.dart';
import 'package:purenote/data/services/notification_service.dart';

enum NoteSortOption { dateModifiedDesc, dateCreatedDesc, titleAsc }

class NoteViewModel extends ChangeNotifier {
  final NoteRepositoryImpl repository;
  final NotificationService notificationService;

  List<Note> _allNotes = [];
  List<Note> _notes = [];
  List<Note> _trashedNotes = [];
  bool _isLoading = false;
  String? _selectedFolderId;
  String _searchQuery = '';
  NoteSortOption _sortOption = NoteSortOption.dateModifiedDesc;

  List<Note> get notes => _notes;
  List<Note> get trashedNotes => _trashedNotes;
  bool get isLoading => _isLoading;
  String? get selectedFolderId => _selectedFolderId;

  NoteViewModel({
    required this.repository,
    required this.notificationService,
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

  Future<void> loadTrashedNotes() async {
    _trashedNotes = await repository.getTrashedNotes();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    var filtered = _allNotes.where((note) => !note.isTrashed).toList();

    if (_selectedFolderId != null) {
      filtered = filtered.where((note) => note.folderId == _selectedFolderId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((note) =>
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query)).toList();
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

  void setSearchQuery(String query) {
    _searchQuery = query;
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
    final trashedIds = _trashedNotes.map((n) => n.id).toList();
    if (trashedIds.isNotEmpty) {
      await repository.deleteMultipleNotes(trashedIds);
      await loadTrashedNotes();
    }
  }

  Future<void> syncNotes(void Function(String message) onResult) async {
    _isLoading = true;
    notifyListeners();

    final response = await repository.syncWithCloud();
    onResult(response.message);

    _isLoading = false;
    notifyListeners();
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
}
