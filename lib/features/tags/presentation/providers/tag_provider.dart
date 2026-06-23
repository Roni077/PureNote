import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/tag_usecases.dart';

class TagState {
  final List<Tag> tags;
  final String? selectedTagId;
  final bool isLoading;
  final String? error;

  TagState({
    this.tags = const [],
    this.selectedTagId,
    this.isLoading = false,
    this.error,
  });

  TagState copyWith({
    List<Tag>? tags,
    String? selectedTagId,
    bool? isLoading,
    String? error,
  }) {
    return TagState(
      tags: tags ?? this.tags,
      selectedTagId: selectedTagId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TagNotifier extends StateNotifier<TagState> {
  final GetTagsUseCase _getTags;
  final CreateTagUseCase _createTag;
  final DeleteTagUseCase _deleteTag;

  TagNotifier(this._getTags, this._createTag, this._deleteTag) : super(TagState()) {
    loadTags();
  }

  Future<void> loadTags() async {
    state = state.copyWith(isLoading: true, error: null, selectedTagId: state.selectedTagId);
    try {
      final tags = await _getTags.execute();
      state = state.copyWith(tags: tags, isLoading: false, selectedTagId: state.selectedTagId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), selectedTagId: state.selectedTagId);
    }
  }

  Future<void> addTag(Tag tag) async {
    try {
      await _createTag.execute(tag);
      await loadTags();
    } catch (e) {
      state = state.copyWith(error: e.toString(), selectedTagId: state.selectedTagId);
    }
  }

  Future<void> deleteTag(String id) async {
    try {
      await _deleteTag.execute(id);
      if (state.selectedTagId == id) {
        selectTag(null);
      } else {
        await loadTags();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), selectedTagId: state.selectedTagId);
    }
  }

  void selectTag(String? id) {
    state = state.copyWith(selectedTagId: id);
  }
}
