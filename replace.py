import os

replacements = {
    'lib/ui/features/settings/views/settings_screen.dart': [
        ("const Text('Settings')", "Text(AppLocalizations.of(context)!.settings)"),
        ("const Text('Theme Mode')", "Text(AppLocalizations.of(context)!.themeMode)"),
        ("Text('System')", "Text(AppLocalizations.of(context)!.system)"),
        ("Text('Light')", "Text(AppLocalizations.of(context)!.light)"),
        ("Text('Dark')", "Text(AppLocalizations.of(context)!.dark)"),
        ("const Text('Auto-Save')", "Text(AppLocalizations.of(context)!.autoSave)"),
        ("const Text('Automatically save notes while editing')", "Text(AppLocalizations.of(context)!.autoSaveDescription)"),
        ("const Text('Markdown Preview')", "Text(AppLocalizations.of(context)!.markdownPreview)"),
        ("const Text('Enable markdown rendering in view mode')", "Text(AppLocalizations.of(context)!.markdownPreviewDescription)"),
    ],
    'lib/ui/features/folders/views/create_folder_dialog.dart': [
        ("const Text('New Folder')", "Text(AppLocalizations.of(context)!.newFolder)"),
        ("const Text('Cancel')", "Text(AppLocalizations.of(context)!.cancel)"),
        ("const Text('Create')", "Text(AppLocalizations.of(context)!.create)"),
    ],
    'lib/ui/features/folders/views/folder_list_widget.dart': [
        ("const Text('All Notes')", "Text(AppLocalizations.of(context)!.allNotes)"),
        ("const Text('Folders',", "Text(AppLocalizations.of(context)!.folders,"),
        ("const Text('Tags',", "Text(AppLocalizations.of(context)!.tags,"),
        ("const Text('AppSettings')", "Text(AppLocalizations.of(context)!.appSettings)"),
        ("const Text('Settings')", "Text(AppLocalizations.of(context)!.settings)"),
    ],
    'lib/ui/features/tags/views/create_tag_dialog.dart': [
        ("const Text('New Tag')", "Text(AppLocalizations.of(context)!.newTag)"),
        ("const Text('Cancel')", "Text(AppLocalizations.of(context)!.cancel)"),
        ("const Text('Create')", "Text(AppLocalizations.of(context)!.create)"),
    ],
    'lib/ui/features/notes/views/home_screen.dart': [
        ("Text(' selected')", "Text(AppLocalizations.of(context)!.selected)"),
        ("Text('Sort by Date Modified')", "Text(AppLocalizations.of(context)!.sortByDateModified)"),
        ("Text('Sort by Date Created')", "Text(AppLocalizations.of(context)!.sortByDateCreated)"),
        ("Text('Sort by Title (A-Z)')", "Text(AppLocalizations.of(context)!.sortByTitle)"),
        ("const Text('No notes found.')", "Text(AppLocalizations.of(context)!.noNotesFound)"),
        ("const Center(child: Text('Search applied. Please press back to view results.'))", "Center(child: Text(AppLocalizations.of(context)!.searchApplied))"),
        ("const Center(child: Text('No notes found'))", "Center(child: Text(AppLocalizations.of(context)!.noNotesFound))")
    ],
    'lib/ui/features/notes/views/note_editor_screen.dart': [
        ("const Text('Untitled')", "Text(AppLocalizations.of(context)!.untitled)"),
        ("hintText: 'Title'", "hintText: AppLocalizations.of(context)!.titleHint"),
        ("hintText: 'Start writing...'", "hintText: AppLocalizations.of(context)!.contentHint")
    ],
    'lib/ui/features/notes/views/note_card.dart': [
        ("'Untitled'", "AppLocalizations.of(context)!.untitled")
    ]
}

for filepath, pairs in replacements.items():
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add import if needed
        if 'AppLocalizations.of' in str(pairs) and 'package:purenote/l10n/app_localizations.dart' not in content:
            import_str = "import 'package:purenote/l10n/app_localizations.dart';\n"
            content = import_str + content
            
        for old_text, new_text in pairs:
            content = content.replace(old_text, new_text)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Updated {filepath}')
