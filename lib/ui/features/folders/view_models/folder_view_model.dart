import 'package:flutter/material.dart';
import 'package:purenote/domain/models/folder.dart';
import 'package:purenote/data/repositories/folder_repository_impl.dart';

class FolderViewModel extends ChangeNotifier {
  final FolderRepositoryImpl repository;

  List<Folder> _folders = [];
  bool _isLoading = false;
  String? _selectedFolderId;

  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get selectedFolderId => _selectedFolderId;

  FolderViewModel({required this.repository}) {
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    _isLoading = true;
    notifyListeners();

    _folders = await repository.getFolders();
    _folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadAll() async {
    await _loadFolders();
  }

  void selectFolder(String? id) {
    _selectedFolderId = id;
    notifyListeners();
  }

  Future<void> addFolder(Folder folder) async {
    await repository.addFolder(folder);
    await _loadFolders();
  }

  Future<void> updateFolder(Folder folder) async {
    await repository.saveFolder(folder);
    await _loadFolders();
  }

  Future<void> deleteFolder(String id) async {
    await repository.deleteFolder(id);
    if (_selectedFolderId == id) {
      _selectedFolderId = null;
    }
    await _loadFolders();
  }
}
