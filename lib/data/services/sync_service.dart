import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:purenote/domain/models/note.dart';

class SyncResponse {
  final bool success;
  final int syncedCount;
  final String message;

  SyncResponse({
    required this.success,
    required this.syncedCount,
    required this.message,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    return SyncResponse(
      success: json['success'] ?? false,
      syncedCount: json['syncedCount'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class SyncService {
  // A mock endpoint (or use a real one if available)
  static const String _syncUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<SyncResponse> syncNotes(List<Note> notes) async {
    try {
      // 1. Serialize notes to JSON (can be heavy if many notes)
      final String jsonPayload = await compute(_serializeNotes, notes);

      // 2. Perform HTTP request
      final response = await http.post(
        Uri.parse(_syncUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonPayload,
      );

      // 3. Parse JSON response (using compute for isolate)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Since jsonplaceholder returns the posted object, we'll mock our successful response
        final Map<String, dynamic> mockResponse = {
          'success': true,
          'syncedCount': notes.length,
          'message': 'Successfully synced ${notes.length} notes.',
        };
        final SyncResponse result = await compute(_parseSyncResponse, mockResponse);
        return result;
      } else {
        return SyncResponse(
          success: false,
          syncedCount: 0,
          message: 'Failed to sync. Server returned ${response.statusCode}.',
        );
      }
    } catch (e) {
      return SyncResponse(
        success: false,
        syncedCount: 0,
        message: 'Sync error: $e',
      );
    }
  }

  // Isolate function: serialize
  static String _serializeNotes(List<Note> notes) {
    final List<Map<String, dynamic>> mapList = notes.map((note) => {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
    }).toList();
    return jsonEncode(mapList);
  }

  // Isolate function: parse response
  static SyncResponse _parseSyncResponse(Map<String, dynamic> json) {
    return SyncResponse.fromJson(json);
  }
}
