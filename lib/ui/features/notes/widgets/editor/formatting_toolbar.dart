import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'formatting_state.dart';
import 'toolbar_button.dart';
import 'heading_dropdown.dart';
import 'color_picker_button.dart';

class FormattingToolbar extends StatelessWidget {
  final QuillController controller;

  const FormattingToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormattingState(controller),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withAlpha(25),
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Consumer<FormattingState>(
            builder: (context, state, _) {
              return Row(
                children: [
                  HeadingDropdown(
                    controller: controller,
                    currentHeading: state.heading,
                  ),
                  _buildDivider(),
                  ToolbarButton(
                    icon: Icons.format_bold,
                    isActive: state.isBold,
                    tooltip: 'Bold (Ctrl+B)',
                    onPressed: () => _toggleAttribute(Attribute.bold),
                  ),
                  ToolbarButton(
                    icon: Icons.format_italic,
                    isActive: state.isItalic,
                    tooltip: 'Italic (Ctrl+I)',
                    onPressed: () => _toggleAttribute(Attribute.italic),
                  ),
                  ToolbarButton(
                    icon: Icons.format_underline,
                    isActive: state.isUnderline,
                    tooltip: 'Underline (Ctrl+U)',
                    onPressed: () => _toggleAttribute(Attribute.underline),
                  ),
                  ToolbarButton(
                    icon: Icons.format_strikethrough,
                    isActive: state.isStrikethrough,
                    tooltip: 'Strikethrough',
                    onPressed: () => _toggleAttribute(Attribute.strikeThrough),
                  ),
                  _buildDivider(),
                  ColorPickerButton(
                    controller: controller,
                    isBackground: false,
                    currentColor: state.textColor,
                    icon: Icons.format_color_text,
                    tooltip: 'Text Color',
                  ),
                  ColorPickerButton(
                    controller: controller,
                    isBackground: true,
                    currentColor: state.highlightColor,
                    icon: Icons.format_color_fill,
                    tooltip: 'Highlight Color',
                  ),
                  _buildDivider(),
                  ToolbarButton(
                    icon: Icons.format_align_left,
                    isActive: state.alignment == 'left',
                    tooltip: 'Align Left',
                    onPressed: () => controller.formatSelection(Attribute.leftAlignment),
                  ),
                  ToolbarButton(
                    icon: Icons.format_align_center,
                    isActive: state.alignment == 'center',
                    tooltip: 'Align Center',
                    onPressed: () => controller.formatSelection(Attribute.centerAlignment),
                  ),
                  ToolbarButton(
                    icon: Icons.format_align_right,
                    isActive: state.alignment == 'right',
                    tooltip: 'Align Right',
                    onPressed: () => controller.formatSelection(Attribute.rightAlignment),
                  ),
                  ToolbarButton(
                    icon: Icons.format_align_justify,
                    isActive: state.alignment == 'justify',
                    tooltip: 'Justify',
                    onPressed: () => controller.formatSelection(Attribute.justifyAlignment),
                  ),
                  _buildDivider(),
                  ToolbarButton(
                    icon: Icons.format_list_bulleted,
                    isActive: state.isBulletList,
                    tooltip: 'Bullet List (Ctrl+L)',
                    onPressed: () => _toggleAttribute(Attribute.ul),
                  ),
                  ToolbarButton(
                    icon: Icons.format_list_numbered,
                    isActive: state.isNumberedList,
                    tooltip: 'Numbered List (Ctrl+Shift+7)',
                    onPressed: () => _toggleAttribute(Attribute.ol),
                  ),
                  ToolbarButton(
                    icon: Icons.checklist,
                    isActive: state.isChecklist,
                    tooltip: 'Checklist (Ctrl+Shift+8)',
                    onPressed: () => _toggleAttribute(Attribute.unchecked),
                  ),
                  _buildDivider(),
                  ToolbarButton(
                    icon: Icons.format_indent_decrease,
                    isActive: false,
                    tooltip: 'Decrease Indent',
                    onPressed: () => controller.formatSelection(Attribute.indent), // Quill uses custom logic for indent
                  ),
                  ToolbarButton(
                    icon: Icons.format_indent_increase,
                    isActive: false,
                    tooltip: 'Increase Indent',
                    onPressed: () => controller.formatSelection(Attribute.indent), // Placeholder
                  ),
                  _buildDivider(),
                  ToolbarButton(
                    icon: Icons.format_quote,
                    isActive: state.isQuote,
                    tooltip: 'Quote',
                    onPressed: () => _toggleAttribute(Attribute.blockQuote),
                  ),
                  ToolbarButton(
                    icon: Icons.code,
                    isActive: state.isInlineCode,
                    tooltip: 'Inline Code',
                    onPressed: () => _toggleAttribute(Attribute.inlineCode),
                  ),
                  ToolbarButton(
                    icon: Icons.integration_instructions_outlined,
                    isActive: state.isCodeBlock,
                    tooltip: 'Code Block',
                    onPressed: () => _toggleAttribute(Attribute.codeBlock),
                  ),
                  ToolbarButton(
                    icon: Icons.link,
                    isActive: false,
                    tooltip: 'Insert Link',
                    onPressed: () {
                      // Show link dialog
                    },
                  ),
                  ToolbarButton(
                    icon: Icons.format_clear,
                    isActive: false,
                    tooltip: 'Clear Formatting',
                    onPressed: () {
                      final index = controller.selection.start;
                      final length = controller.selection.end - index;
                      if (length > 0) {
                        controller.formatText(index, length, Attribute.clone(Attribute.bold, null));
                        controller.formatText(index, length, Attribute.clone(Attribute.italic, null));
                        controller.formatText(index, length, Attribute.clone(Attribute.underline, null));
                        controller.formatText(index, length, Attribute.clone(Attribute.strikeThrough, null));
                        controller.formatText(index, length, Attribute.clone(Attribute.color, null));
                        controller.formatText(index, length, Attribute.clone(Attribute.background, null));
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      color: Colors.grey.withAlpha(76),
    );
  }
  
  void _toggleAttribute(Attribute attribute) {
    final isEnabled = controller.getSelectionStyle().containsKey(attribute.key);
    if (isEnabled) {
      controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      controller.formatSelection(attribute);
    }
  }
}
