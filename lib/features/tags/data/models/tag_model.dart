import 'package:isar/isar.dart';
import '../../domain/entities/tag.dart';

part 'tag_model.g.dart';

@collection
class TagModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;

  Tag toDomain() {
    return Tag(
      id: uuid,
      name: name,
    );
  }

  static TagModel fromDomain(Tag tag) {
    return TagModel()
      ..uuid = tag.id
      ..name = tag.name;
  }
}
