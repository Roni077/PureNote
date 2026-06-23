import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/folder.dart';
import '../../domain/usecases/folder_usecases.dart';

// State class for FolderNotifier
class FolderState {
  final List<Folder> folders;
  final String? selectedFolderId;
  final bool isLoading;
  final String? error;

  FolderState({
    this.folders = const [],
    this.selectedFolderId,
    this.isLoading = false,
    this.error,
  });

  FolderState copyWith({
    List<Folder>? folders,
    String? selectedFolderId,
    bool? isLoading,
    String? error,
  }) {
    return FolderState(
      folders: folders ?? this.folders,
      selectedFolderId: selectedFolderId, // Notice: we don't fallback to this.selectedFolderId because we want to allow nulling it
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FolderNotifier extends StateNotifier<FolderState> {
  final GetFoldersUseCase _getFolders;
  final CreateFolderUseCase _createFolder;
  final DeleteFolderUseCase _deleteFolder;

  FolderNotifier(this._getFolders, this._createFolder, this._deleteFolder)
      : super(FolderState()) {
    loadFolders();
  }

  Future<void> loadFolders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final folders = await _getFolders.execute();
      state = state.copyWith(folders: folders, isLoading: false, selectedFolderId: state.selectedFolderId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), selectedFolderId: state.selectedFolderId);
    }
  }

  Future<void> addFolder(Folder folder) async {
    try {
      await _createFolder.execute(folder);
      await loadFolders();
    } catch (e) {
      state = state.copyWith(error: e.toString(), selectedFolderId: state.selectedFolderId);
    }
  }

  Future<void> deleteFolder(String id) async {
    try {
      await _deleteFolder.execute(id);
      if (state.selectedFolderId == id) {
        selectFolder(null); // Deselect if deleted
      } else {
        await loadFolders();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), selectedFolderId: state.selectedFolderId);
    }
  }

  void selectFolder(String? id) {
    state = state.copyWith(selectedFolderId: id);
  }
}

// Providers will be created in app_providers.dart to ensure they have access to the repository
