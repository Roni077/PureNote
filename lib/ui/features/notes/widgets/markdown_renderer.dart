import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class MarkdownRenderer extends StatelessWidget {
  final String content;

  const MarkdownRenderer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MarkdownBody(
      data: content,
      selectable: true,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        h2: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        h3: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        h4: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        h5: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        h6: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        blockquote: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        code: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
        ),
        codeblockDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.grey[900] : Colors.grey[100],
        ),
      ),
      onTapLink: (text, href, title) async {
        if (href != null) {
          final uri = Uri.parse(href);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
      },
      builders: {
        'code': CodeBlockBuilder(isDark: isDark),
      },
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDark;

  CodeBlockBuilder({required this.isDark});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String language = 'plaintext';
    if (element.attributes.containsKey('class')) {
      final String className = element.attributes['class']!;
      if (className.startsWith('language-')) {
        language = className.substring(9);
      }
    }

    // Only apply syntax highlighter to multiline code blocks (<pre><code>)
    // flutter_markdown_plus passes the inner <code> element here. We check if parent is pre.
    // However, MarkdownElementBuilder does not easily expose parent.
    // A simple heuristic is checking if it contains newlines.
    final text = element.textContent;
    if (!text.contains('\n')) {
      return null; // Let default inline code renderer handle it
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? const Color(0xFF282C34) : const Color(0xFFFAFAFA),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: HighlightView(
        text,
        language: language,
        theme: isDark ? atomOneDarkTheme : atomOneLightTheme,
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }
}
