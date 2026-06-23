import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService(); 
});
