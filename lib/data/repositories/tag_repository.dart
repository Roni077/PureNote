import 'package:purenote/domain/models/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTags();
  Future<Tag?> getTagById(String id);
  Future<void> addTag(Tag tag);
  Future<void> saveTag(Tag tag);
  Future<void> deleteTag(String id);
}
