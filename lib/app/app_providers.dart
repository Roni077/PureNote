import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/isar_service.dart';
import '../features/folders/data/datasources/folder_local_data_source.dart';
import '../features/folders/data/repositories/folder_repository_impl.dart';
import '../features/folders/domain/repositories/folder_repository.dart';
import '../features/folders/domain/usecases/folder_usecases.dart';
import '../features/folders/presentation/providers/folder_provider.dart';

import '../features/tags/data/datasources/tag_local_data_source.dart';
import '../features/tags/data/repositories/tag_repository_impl.dart';
import '../features/tags/domain/repositories/tag_repository.dart';
import '../features/tags/domain/usecases/tag_usecases.dart';
import '../features/tags/presentation/providers/tag_provider.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService(); 
});

final folderLocalDataSourceProvider = Provider<FolderLocalDataSource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return FolderLocalDataSource(isarService);
});

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final dataSource = ref.watch(folderLocalDataSourceProvider);
  return FolderRepositoryImpl(dataSource);
});

final folderNotifierProvider = StateNotifierProvider<FolderNotifier, FolderState>((ref) {
  final repository = ref.watch(folderRepositoryProvider);
  return FolderNotifier(
    GetFoldersUseCase(repository),
    CreateFolderUseCase(repository),
    DeleteFolderUseCase(repository),
  );
});

final tagLocalDataSourceProvider = Provider<TagLocalDataSource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TagLocalDataSource(isarService);
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final dataSource = ref.watch(tagLocalDataSourceProvider);
  return TagRepositoryImpl(dataSource);
});

final tagNotifierProvider = StateNotifierProvider<TagNotifier, TagState>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return TagNotifier(
    GetTagsUseCase(repository),
    CreateTagUseCase(repository),
    DeleteTagUseCase(repository),
  );
});
