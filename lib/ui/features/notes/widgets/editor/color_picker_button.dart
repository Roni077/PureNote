import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class ColorPickerButton extends StatelessWidget {
  final QuillController controller;
  final bool isBackground;
  final Color? currentColor;
  final IconData icon;
  final String tooltip;

  const ColorPickerButton({
    super.key,
    required this.controller,
    required this.isBackground,
    this.currentColor,
    required this.icon,
    required this.tooltip,
  });

  Future<void> _showColorPicker(BuildContext context) async {
    Color selectedColor = currentColor ?? (isBackground ? Colors.transparent : Colors.black);

    final Color newColor = await showColorPickerDialog(
      context,
      selectedColor,
      title: Text(isBackground ? 'Highlight Color' : 'Text Color', style: Theme.of(context).textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 0,
      runSpacing: 0,
      borderRadius: 4,
      wheelDiameter: 165,
      enableOpacity: false,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: false,
      ),
    );

    String hex = '#${newColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    
    if (isBackground) {
      if (newColor == Colors.transparent) {
        controller.formatSelection(Attribute.clone(Attribute.background, null));
      } else {
        controller.formatSelection(BackgroundAttribute(hex));
      }
    } else {
      controller.formatSelection(ColorAttribute(hex));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () => _showColorPicker(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(height: 2),
                Container(
                  height: 4,
                  width: 16,
                  decoration: BoxDecoration(
                    color: currentColor ?? (isBackground ? Colors.transparent : Theme.of(context).iconTheme.color),
                    border: isBackground && currentColor == null ? Border.all(color: Colors.grey) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
