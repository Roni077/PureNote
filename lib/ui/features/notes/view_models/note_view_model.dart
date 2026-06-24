import 'package:flutter/material.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/data/repositories/note_repository_impl.dart';

enum NoteSortOption { dateModifiedDesc, dateCreatedDesc, titleAsc }

class NoteViewModel extends ChangeNotifier {
  final NoteRepositoryImpl repository;

  List<Note> _allNotes = [];
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _selectedFolderId;
  String _searchQuery = '';
  NoteSortOption _sortOption = NoteSortOption.dateModifiedDesc;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get selectedFolderId => _selectedFolderId;

  NoteViewModel({required this.repository}) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _allNotes = await repository.getNotes();
    _applyFiltersAndSort();

    _isLoading = false;
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
  }

  Future<void> deleteMultipleNotes(List<String> ids) async {
    await repository.deleteMultipleNotes(ids);
    await _loadNotes();
  }

  Future<void> syncNotes(void Function(String message) onResult) async {
    _isLoading = true;
    notifyListeners();

    final response = await repository.syncWithCloud();
    onResult(response.message);

    _isLoading = false;
    notifyListeners();
  }
}
