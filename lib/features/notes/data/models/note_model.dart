import 'package:isar/isar.dart';
import '../../domain/entities/note.dart';

part 'note_model.g.dart';

@collection
class NoteModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  late String content;
  late DateTime createdAt;
  late DateTime updatedAt;

  bool isPinned = false;
  bool isArchived = false;
  bool isTrashed = false;
  int colorIndex = 0;
  String? folderId;

  Note toDomain() {
    return Note(
      id: uuid,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      isArchived: isArchived,
      isTrashed: isTrashed,
      colorIndex: colorIndex,
      folderId: folderId,
    );
  }

  static NoteModel fromDomain(Note note) {
    return NoteModel()
      ..uuid = note.id
      ..title = note.title
      ..content = note.content
      ..createdAt = note.createdAt
      ..updatedAt = note.updatedAt
      ..isPinned = note.isPinned
      ..isArchived = note.isArchived
      ..isTrashed = note.isTrashed
      ..colorIndex = note.colorIndex
      ..folderId = note.folderId;
  }
}
