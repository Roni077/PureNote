import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/isar_service.dart';
import '../features/folders/data/datasources/folder_local_data_source.dart';
import '../features/folders/data/repositories/folder_repository_impl.dart';
import '../features/folders/domain/repositories/folder_repository.dart';
import '../features/folders/domain/usecases/folder_usecases.dart';
import '../features/folders/presentation/providers/folder_provider.dart';

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
