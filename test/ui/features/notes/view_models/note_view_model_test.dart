import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/data/repositories/note_repository_impl.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/data/services/notification_service.dart';

import 'package:purenote/data/services/sync_service.dart';

class MockNoteRepository extends Mock implements NoteRepositoryImpl {}
class MockNotificationService extends Mock implements NotificationService {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  late MockNoteRepository mockRepository;
  late MockNotificationService mockNotificationService;
  late MockSyncService mockSyncService;

  setUp(() {
    mockRepository = MockNoteRepository();
    mockNotificationService = MockNotificationService();
    mockSyncService = MockSyncService();
    when(() => mockRepository.cleanUpTrash()).thenAnswer((_) async => {});
    registerFallbackValue(Note(id: 'fallback', title: 'fallback', content: 'fallback', createdAt: DateTime.now(), updatedAt: DateTime.now()));
  });

  group('NoteViewModel', () {
    test('initialization fetches notes and updates state', () async {
      final now = DateTime.now();
      final mockNotes = [
        Note(id: '1', title: 'Test Note 1', content: 'Content 1', createdAt: now, updatedAt: now),
        Note(id: '2', title: 'Test Note 2', content: 'Content 2', createdAt: now.subtract(const Duration(hours: 1)), updatedAt: now.subtract(const Duration(hours: 1))),
      ];
      when(() => mockRepository.getNotes()).thenAnswer((_) async => mockNotes);

      final viewModel = NoteViewModel(
        repository: mockRepository, 
        notificationService: mockNotificationService,
        syncService: mockSyncService,
      );
      // Wait for microtasks to complete because _loadNotes is async
      await Future.delayed(Duration.zero);

      expect(viewModel.notes.length, 2);
      expect(viewModel.notes, equals(mockNotes));
      expect(viewModel.isLoading, isFalse);
      verify(() => mockRepository.getNotes()).called(1);
    });

    test('addNote saves note and reloads notes', () async {
      final newNote = Note(id: '3', title: 'New Note', content: 'New Content', createdAt: DateTime.now(), updatedAt: DateTime.now());
      
      when(() => mockRepository.getNotes()).thenAnswer((_) async => []);
      when(() => mockRepository.addNote(any())).thenAnswer((_) async => {});

      final viewModel = NoteViewModel(
        repository: mockRepository, 
        notificationService: mockNotificationService,
        syncService: mockSyncService,
      );
      await Future.delayed(Duration.zero);
      
      when(() => mockRepository.getNotes()).thenAnswer((_) async => [newNote]);
      await viewModel.addNote(newNote);

      expect(viewModel.notes.length, 1);
      expect(viewModel.notes.first.title, 'New Note');
      verify(() => mockRepository.addNote(any())).called(1);
    });

    test('deleteNote removes note and reloads notes', () async {
      when(() => mockRepository.getNotes()).thenAnswer((_) async => []);
      when(() => mockRepository.getTrashedNotes()).thenAnswer((_) async => []);
      final viewModel = NoteViewModel(
        repository: mockRepository, 
        notificationService: mockNotificationService,
        syncService: mockSyncService,
      );
      await Future.delayed(Duration.zero);

      when(() => mockRepository.deleteNote('1')).thenAnswer((_) async => {});
      await viewModel.deleteNote('1');

      expect(viewModel.notes, isEmpty);
      verify(() => mockRepository.deleteNote('1')).called(1);
    });
  });
}
