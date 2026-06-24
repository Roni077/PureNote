import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'package:purenote/data/models/note_model.dart';
import 'package:purenote/data/models/folder_model.dart';
import 'package:purenote/data/models/tag_model.dart';

class BackupService {
  final Future<Isar> db;

  BackupService(this.db);

  Future<String> generateBackupJson() async {
    final isar = await db;
    final notes = await isar.noteModels.where().findAll();
    final folders = await isar.folderModels.where().findAll();
    final tags = await isar.tagModels.where().findAll();

    final backup = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'notes': notes.map((n) => {
            'uuid': n.uuid,
            'title': n.title,
            'content': n.content,
            'createdAt': n.createdAt.toIso8601String(),
            'updatedAt': n.updatedAt.toIso8601String(),
            'isPinned': n.isPinned,
            'isArchived': n.isArchived,
            'isTrashed': n.isTrashed,
            'colorIndex': n.colorIndex,
            'folderId': n.folderId,
            'tagIds': n.tagIds,
            'reminderDate': n.reminderDate?.toIso8601String(),
          }).toList(),
      'folders': folders.map((f) => {
            'uuid': f.uuid,
            'name': f.name,
            'createdAt': f.createdAt.toIso8601String(),
          }).toList(),
      'tags': tags.map((t) => {
            'uuid': t.uuid,
            'name': t.name,
          }).toList(),
    };

    return jsonEncode(backup);
  }

  Future<void> restoreFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    if (data['version'] != 1) {
      throw Exception('Unsupported backup version');
    }

    final List<dynamic> rawNotes = data['notes'] ?? [];
    final List<dynamic> rawFolders = data['folders'] ?? [];
    final List<dynamic> rawTags = data['tags'] ?? [];

    final newNotes = rawNotes.map((n) {
      return NoteModel()
        ..uuid = n['uuid'] as String
        ..title = n['title'] as String
        ..content = n['content'] as String
        ..createdAt = DateTime.parse(n['createdAt'] as String)
        ..updatedAt = DateTime.parse(n['updatedAt'] as String)
        ..isPinned = n['isPinned'] as bool
        ..isArchived = n['isArchived'] as bool
        ..isTrashed = n['isTrashed'] as bool
        ..colorIndex = n['colorIndex'] as int
        ..folderId = n['folderId'] as String?
        ..tagIds = (n['tagIds'] as List<dynamic>).cast<String>()
        ..reminderDate = n['reminderDate'] != null ? DateTime.parse(n['reminderDate'] as String) : null;
    }).toList();

    final newFolders = rawFolders.map((f) {
      return FolderModel()
        ..uuid = f['uuid'] as String
        ..name = f['name'] as String
        ..createdAt = DateTime.parse(f['createdAt'] as String);
    }).toList();

    final newTags = rawTags.map((t) {
      return TagModel()
        ..uuid = t['uuid'] as String
        ..name = t['name'] as String;
    }).toList();

    final isar = await db;
    await isar.writeTxn(() async {
      await isar.noteModels.clear();
      await isar.folderModels.clear();
      await isar.tagModels.clear();

      await isar.noteModels.putAll(newNotes);
      await isar.folderModels.putAll(newFolders);
      await isar.tagModels.putAll(newTags);
    });
  }

  Future<void> exportBackup() async {
    try {
      final jsonString = await generateBackupJson();
      final fileName = 'purenote_backup_${DateTime.now().toIso8601String().split('T').first}.json';

      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        // Desktop / Web
        final String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonString);
        }
      } else {
        // Mobile (Android / iOS)
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(jsonString);
        
        final xFile = XFile(file.path, mimeType: 'application/json');
        // ignore: deprecated_member_use
        await Share.shareXFiles([xFile], subject: 'PureNote Backup');
      }
    } catch (e) {
      debugPrint('Export failed: $e');
      rethrow;
    }
  }

  Future<void> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        await restoreFromJson(jsonString);
      }
    } catch (e) {
      debugPrint('Import failed: $e');
      rethrow;
    }
  }
}
