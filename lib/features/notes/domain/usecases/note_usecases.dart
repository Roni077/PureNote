import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotesUseCase {
  final NoteRepository repository;
  GetNotesUseCase(this.repository);

  Future<List<Note>> execute() {
    return repository.getNotes();
  }
}

class CreateNoteUseCase {
  final NoteRepository repository;
  CreateNoteUseCase(this.repository);

  Future<void> execute(Note note) {
    return repository.saveNote(note);
  }
}

class UpdateNoteUseCase {
  final NoteRepository repository;
  UpdateNoteUseCase(this.repository);

  Future<void> execute(Note note) {
    note = note.copyWith(updatedAt: DateTime.now());
    return repository.saveNote(note);
  }
}

class DeleteNoteUseCase {
  final NoteRepository repository;
  DeleteNoteUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.deleteNote(id);
  }

  Future<void> executeBatch(List<String> ids) {
    return repository.deleteNotes(ids);
  }
}

class PinNoteUseCase {
  final NoteRepository repository;
  PinNoteUseCase(this.repository);

  Future<void> execute(Note note) {
    final updatedNote = note.copyWith(
      isPinned: !note.isPinned,
      updatedAt: DateTime.now(),
    );
    return repository.saveNote(updatedNote);
  }
}

class ArchiveNoteUseCase {
  final NoteRepository repository;
  ArchiveNoteUseCase(this.repository);

  Future<void> execute(Note note) {
    final updatedNote = note.copyWith(
      isArchived: !note.isArchived,
      updatedAt: DateTime.now(),
    );
    return repository.saveNote(updatedNote);
  }
}
