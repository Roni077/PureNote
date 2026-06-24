import 'package:flutter/material.dart';
import 'package:purenote/domain/models/tag.dart';
import 'package:purenote/data/repositories/tag_repository_impl.dart';

class TagViewModel extends ChangeNotifier {
  final TagRepositoryImpl repository;

  List<Tag> _tags = [];
  bool _isLoading = false;

  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;

  TagViewModel({required this.repository}) {
    _loadTags();
  }

  Future<void> _loadTags() async {
    _isLoading = true;
    notifyListeners();

    _tags = await repository.getTags();
    _tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadAll() async {
    await _loadTags();
  }

  Future<void> addTag(Tag tag) async {
    await repository.addTag(tag);
    await _loadTags();
  }

  Future<void> deleteTag(String id) async {
    await repository.deleteTag(id);
    await _loadTags();
  }
}
