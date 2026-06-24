import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:purenote/data/services/isar_service.dart';
import 'package:purenote/data/services/sync_service.dart';
import 'package:purenote/data/services/notification_service.dart';
import 'package:purenote/data/services/backup_service.dart';
import 'package:purenote/data/services/folder_local_data_source.dart';
import 'package:purenote/data/services/note_local_data_source.dart';
import 'package:purenote/data/services/tag_local_data_source.dart';
import 'package:purenote/data/services/settings_local_data_source.dart';

import 'package:purenote/data/repositories/folder_repository_impl.dart';
import 'package:purenote/data/repositories/note_repository_impl.dart';
import 'package:purenote/data/repositories/tag_repository_impl.dart';
import 'package:purenote/data/repositories/settings_repository_impl.dart';

import 'package:purenote/ui/features/folders/view_models/folder_view_model.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/tags/view_models/tag_view_model.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/data/services/auth_service.dart';
import 'package:purenote/ui/features/auth/view_models/auth_view_model.dart';

class AppDependencyInjection extends StatelessWidget {
  final Widget child;

  const AppDependencyInjection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<IsarService>(create: (_) => IsarService()),
        Provider<SyncService>(create: (_) => SyncService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<NotificationService>(create: (_) => NotificationService()..initialize()),
        ProxyProvider<IsarService, BackupService>(
          update: (_, isar, __) => BackupService(isar.db),
        ),
        
        // Data Sources
        ProxyProvider<IsarService, FolderLocalDataSource>(
          update: (_, isar, __) => FolderLocalDataSource(isar),
        ),
        ProxyProvider<IsarService, NoteLocalDataSource>(
          update: (_, isar, __) => NoteLocalDataSource(isar),
        ),
        ProxyProvider<IsarService, TagLocalDataSource>(
          update: (_, isar, __) => TagLocalDataSource(isar),
        ),
        ProxyProvider<IsarService, SettingsLocalDataSource>(
          update: (_, isar, __) => SettingsLocalDataSource(isar),
        ),
        
        // Repositories
        ProxyProvider<FolderLocalDataSource, FolderRepositoryImpl>(
          update: (_, ds, __) => FolderRepositoryImpl(ds),
        ),
        ProxyProvider2<NoteLocalDataSource, SyncService, NoteRepositoryImpl>(
          update: (_, ds, syncService, __) => NoteRepositoryImpl(ds, syncService),
        ),
        ProxyProvider<TagLocalDataSource, TagRepositoryImpl>(
          update: (_, ds, __) => TagRepositoryImpl(ds),
        ),
        ProxyProvider<SettingsLocalDataSource, SettingsRepositoryImpl>(
          update: (_, ds, __) => SettingsRepositoryImpl(ds),
        ),

        // ViewModels
        ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
          create: (context) => AuthViewModel(authService: context.read<AuthService>()),
          update: (_, auth, vm) => vm ?? AuthViewModel(authService: auth),
        ),
        ChangeNotifierProxyProvider2<SettingsRepositoryImpl, BackupService, SettingsViewModel>(
          create: (context) => SettingsViewModel(
            settingsRepository: context.read<SettingsRepositoryImpl>(),
            backupService: context.read<BackupService>(),
          ),
          update: (_, repo, backup, vm) => vm ?? SettingsViewModel(
            settingsRepository: repo,
            backupService: backup,
          ),
        ),
        ChangeNotifierProxyProvider<FolderRepositoryImpl, FolderViewModel>(
          create: (context) => FolderViewModel(repository: context.read<FolderRepositoryImpl>()),
          update: (_, repo, vm) => vm ?? FolderViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider<TagRepositoryImpl, TagViewModel>(
          create: (context) => TagViewModel(repository: context.read<TagRepositoryImpl>()),
          update: (_, repo, vm) => vm ?? TagViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider2<NoteRepositoryImpl, NotificationService, NoteViewModel>(
          create: (context) => NoteViewModel(
            repository: context.read<NoteRepositoryImpl>(),
            notificationService: context.read<NotificationService>(),
          ),
          update: (_, repo, notif, vm) => vm ?? NoteViewModel(
            repository: repo,
            notificationService: notif,
          ),
        ),
      ],
      child: child,
    );
  }
}
