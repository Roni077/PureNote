import 'package:isar/isar.dart';
import '../../domain/entities/folder.dart';

part 'folder_model.g.dart';

@collection
class FolderModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  late DateTime createdAt;

  Folder toDomain() {
    return Folder(
      id: uuid,
      name: name,
      createdAt: createdAt,
    );
  }

  static FolderModel fromDomain(Folder folder) {
    return FolderModel()
      ..uuid = folder.id
      ..name = folder.name
      ..createdAt = folder.createdAt;
  }
}
