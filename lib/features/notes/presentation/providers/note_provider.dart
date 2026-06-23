import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/note_usecases.dart';
import '../../data/datasources/note_local_data_source.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../../../app/app_providers.dart';

// Repositories & Use Cases Providers
final noteLocalDataSourceProvider = Provider<NoteLocalDataSource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return NoteLocalDataSource(isarService);
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final dataSource = ref.watch(noteLocalDataSourceProvider);
  return NoteRepositoryImpl(dataSource);
});

final getNotesUseCaseProvider = Provider<GetNotesUseCase>((ref) {
  return GetNotesUseCase(ref.watch(noteRepositoryProvider));
});
final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(noteRepositoryProvider));
});
final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((ref) {
  return UpdateNoteUseCase(ref.watch(noteRepositoryProvider));
});
final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
  return DeleteNoteUseCase(ref.watch(noteRepositoryProvider));
});
final pinNoteUseCaseProvider = Provider<PinNoteUseCase>((ref) {
  return PinNoteUseCase(ref.watch(noteRepositoryProvider));
});
final archiveNoteUseCaseProvider = Provider<ArchiveNoteUseCase>((ref) {
  return ArchiveNoteUseCase(ref.watch(noteRepositoryProvider));
});

// State classes
enum NoteSortOption { dateDesc, dateAsc, titleAsc, titleDesc }

class NoteState {
  final List<Note> notes;
  final bool isLoading;
  final NoteSortOption sortOption;
  final String searchQuery;

  NoteState({
    this.notes = const [],
    this.isLoading = true,
    this.sortOption = NoteSortOption.dateDesc,
    this.searchQuery = '',
  });

  NoteState copyWith({
    List<Note>? notes,
    bool? isLoading,
    NoteSortOption? sortOption,
    String? searchQuery,
  }) {
    return NoteState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// State Notifier
class NoteNotifier extends StateNotifier<NoteState> {
  List<Note> _allNotes = [];
  
  final GetNotesUseCase _getNotes;
  final CreateNoteUseCase _createNote;
  final UpdateNoteUseCase _updateNote;
  final DeleteNoteUseCase _deleteNote;
  final PinNoteUseCase _pinNote;
  final ArchiveNoteUseCase _archiveNote;

  NoteNotifier(
    this._getNotes,
    this._createNote,
    this._updateNote,
    this._deleteNote,
    this._pinNote,
    this._archiveNote,
  ) : super(NoteState()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true);
    _allNotes = await _getNotes.execute();
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allNotes;
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
      }).toList();
    }
    state = state.copyWith(
      notes: _sortNotes(filtered, state.sortOption),
      isLoading: false,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  Future<void> addNote(Note note) async {
    await _createNote.execute(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _updateNote.execute(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _deleteNote.execute(id);
    await loadNotes();
  }

  Future<void> deleteMultipleNotes(List<String> ids) async {
    await _deleteNote.executeBatch(ids);
    await loadNotes();
  }

  Future<void> togglePin(Note note) async {
    await _pinNote.execute(note);
    await loadNotes();
  }

  Future<void> toggleArchive(Note note) async {
    await _archiveNote.execute(note);
    await loadNotes();
  }

  void changeSortOption(NoteSortOption option) {
    state = state.copyWith(sortOption: option);
    _applyFilters();
  }

  List<Note> _sortNotes(List<Note> notes, NoteSortOption option) {
    final sorted = List<Note>.from(notes);
    switch (option) {
      case NoteSortOption.dateDesc:
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOption.dateAsc:
        sorted.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSortOption.titleAsc:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case NoteSortOption.titleDesc:
        sorted.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
    // Pinned notes always on top
    sorted.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    return sorted;
  }
}

final noteNotifierProvider = StateNotifierProvider<NoteNotifier, NoteState>((ref) {
  return NoteNotifier(
    ref.watch(getNotesUseCaseProvider),
    ref.watch(createNoteUseCaseProvider),
    ref.watch(updateNoteUseCaseProvider),
    ref.watch(deleteNoteUseCaseProvider),
    ref.watch(pinNoteUseCaseProvider),
    ref.watch(archiveNoteUseCaseProvider),
  );
});
