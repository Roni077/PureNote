import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purenote/domain/models/folder.dart';
import 'package:purenote/data/repositories/folder_repository_impl.dart';
import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';

class MockFolderRepository extends Mock implements FolderRepositoryImpl {}

void main() {
  late MockFolderRepository mockRepository;

  setUp(() {
    mockRepository = MockFolderRepository();
    registerFallbackValue(Folder(id: 'fallback', name: 'fallback', createdAt: DateTime.now()));
  });

  group('FolderViewModel', () {
    test('initialization fetches folders and updates state', () async {
      final mockFolders = [
        Folder(id: '1', name: 'Folder 1', createdAt: DateTime.now()),
      ];
      when(() => mockRepository.getFolders()).thenAnswer((_) async => mockFolders);

      final viewModel = FolderViewModel(repository: mockRepository);
      await Future.delayed(Duration.zero);

      expect(viewModel.folders.length, 1);
      expect(viewModel.folders, equals(mockFolders));
      expect(viewModel.isLoading, isFalse);
    });

    test('addFolder saves folder and reloads folders', () async {
      final newFolder = Folder(id: 'new', name: 'New Folder', createdAt: DateTime.now());
      
      when(() => mockRepository.getFolders()).thenAnswer((_) async => []);
      when(() => mockRepository.addFolder(any())).thenAnswer((_) async => {});

      final viewModel = FolderViewModel(repository: mockRepository);
      await Future.delayed(Duration.zero);
      
      when(() => mockRepository.getFolders()).thenAnswer((_) async => [newFolder]);
      await viewModel.addFolder(newFolder);

      expect(viewModel.folders.length, 1);
      expect(viewModel.folders.first.name, 'New Folder');
      verify(() => mockRepository.addFolder(any())).called(1);
    });
  });
}
