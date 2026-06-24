import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purenote/l10n/app_localizations.dart';
import 'package:purenote/ui/features/notes/view_models/note_view_model.dart';
import 'package:purenote/ui/features/notes/views/note_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = context.watch<NoteViewModel>();
    final allNotes = noteViewModel.notes; 

    final query = _searchController.text.toLowerCase();
    final notes = query.isEmpty 
       ? [] 
       : allNotes.where((note) =>
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
      body: noteViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : query.isEmpty
              ? const Center(child: Text('Type to search notes.'))
              : notes.isEmpty
                  ? const Center(child: Text('No notes found for this search.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          'editor',
                          queryParameters: {
                            'id': note.id.toString(),
                          },
                        );
                      },
                      child: NoteCard(note: note),
                    );
                  },
                ),
    );
  }
}
