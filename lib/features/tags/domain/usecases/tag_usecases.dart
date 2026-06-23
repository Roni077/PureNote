import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

class GetTagsUseCase {
  final TagRepository repository;
  GetTagsUseCase(this.repository);

  Future<List<Tag>> execute() {
    return repository.getTags();
  }
}

class CreateTagUseCase {
  final TagRepository repository;
  CreateTagUseCase(this.repository);

  Future<void> execute(Tag tag) {
    return repository.saveTag(tag);
  }
}

class DeleteTagUseCase {
  final TagRepository repository;
  DeleteTagUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.deleteTag(id);
  }
}
