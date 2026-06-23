class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isArchived;
  final bool isTrashed;
  final int colorIndex;
  final String? folderId;
  final List<String> tagIds;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isArchived = false,
    this.isTrashed = false,
    this.colorIndex = 0,
    this.folderId,
    this.tagIds = const [],
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isArchived,
    bool? isTrashed,
    int? colorIndex,
    String? folderId,
    List<String>? tagIds,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isTrashed: isTrashed ?? this.isTrashed,
      colorIndex: colorIndex ?? this.colorIndex,
      folderId: folderId ?? this.folderId,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}
