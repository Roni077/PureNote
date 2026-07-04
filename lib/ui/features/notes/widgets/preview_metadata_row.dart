import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purenote/domain/models/note.dart';

class PreviewMetadataRow extends StatelessWidget {
  final Note note;
  final String? folderName;

  const PreviewMetadataRow({
    super.key,
    required this.note,
    this.folderName,
  });

  int _calculateWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  int _calculateReadingTime(int wordCount) {
    // Average reading speed is roughly 200 words per minute.
    final minutes = (wordCount / 200).ceil();
    return minutes == 0 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wordCount = _calculateWordCount(note.content);
    final readingTime = _calculateReadingTime(wordCount);
    final isDark = theme.brightness == Brightness.dark;
    
    final chipColor = isDark ? Colors.grey[850] : Colors.grey[200];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[700];

    // Localizations keys might not exist for words/minRead. Fallback to English if not available.
    // In a real app we'd add these to app_en.arb
    const wordsText = 'words';
    const minReadText = 'min read';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildMetadataChip(
          icon: Icons.edit_calendar,
          text: DateFormat.yMMMd().add_jm().format(note.updatedAt),
          iconColor: iconColor,
          backgroundColor: chipColor,
          theme: theme,
        ),
        if (folderName != null)
          _buildMetadataChip(
            icon: Icons.folder_outlined,
            text: folderName!,
            iconColor: iconColor,
            backgroundColor: chipColor,
            theme: theme,
          ),
        _buildMetadataChip(
          icon: Icons.text_snippet_outlined,
          text: '$wordCount $wordsText',
          iconColor: iconColor,
          backgroundColor: chipColor,
          theme: theme,
        ),
        _buildMetadataChip(
          icon: Icons.timer_outlined,
          text: '$readingTime $minReadText',
          iconColor: iconColor,
          backgroundColor: chipColor,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    required Color? iconColor,
    required Color? backgroundColor,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
