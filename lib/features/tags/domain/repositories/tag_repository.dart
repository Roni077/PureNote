import '../entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTags();
  Future<Tag?> getTagById(String id);
  Future<void> saveTag(Tag tag);
  Future<void> deleteTag(String id);
}
