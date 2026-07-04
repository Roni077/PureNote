import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class FormattingState extends ChangeNotifier {
  final QuillController controller;

  bool get isBold => controller.getSelectionStyle().containsKey(Attribute.bold.key);
  bool get isItalic => controller.getSelectionStyle().containsKey(Attribute.italic.key);
  bool get isUnderline => controller.getSelectionStyle().containsKey(Attribute.underline.key);
  bool get isStrikethrough => controller.getSelectionStyle().containsKey(Attribute.strikeThrough.key);
  
  bool get isBulletList => controller.getSelectionStyle().containsKey(Attribute.ul.key);
  bool get isNumberedList => controller.getSelectionStyle().containsKey(Attribute.ol.key);
  bool get isChecklist => controller.getSelectionStyle().containsKey(Attribute.unchecked.key) || controller.getSelectionStyle().containsKey(Attribute.checked.key);
  
  bool get isInlineCode => controller.getSelectionStyle().containsKey(Attribute.inlineCode.key);
  bool get isCodeBlock => controller.getSelectionStyle().containsKey(Attribute.codeBlock.key);
  bool get isQuote => controller.getSelectionStyle().containsKey(Attribute.blockQuote.key);
  
  String get alignment {
    final style = controller.getSelectionStyle();
    if (style.containsKey(Attribute.centerAlignment.key)) return 'center';
    if (style.containsKey(Attribute.rightAlignment.key)) return 'right';
    if (style.containsKey(Attribute.justifyAlignment.key)) return 'justify';
    return 'left';
  }

  int get heading {
    final style = controller.getSelectionStyle();
    if (style.containsKey(Attribute.h1.key)) return 1;
    if (style.containsKey(Attribute.h2.key)) return 2;
    if (style.containsKey(Attribute.h3.key)) return 3;
    if (style.containsKey(Attribute.h4.key)) return 4;
    if (style.containsKey(Attribute.h5.key)) return 5;
    if (style.containsKey(Attribute.h6.key)) return 6;
    return 0; // Paragraph
  }
  
  Color? get textColor {
    final style = controller.getSelectionStyle();
    final attr = style.attributes[Attribute.color.key];
    if (attr != null && attr.value is String) {
      return _hexToColor(attr.value as String);
    }
    return null;
  }
  
  Color? get highlightColor {
    final style = controller.getSelectionStyle();
    final attr = style.attributes[Attribute.background.key];
    if (attr != null && attr.value is String) {
      return _hexToColor(attr.value as String);
    }
    return null;
  }

  FormattingState(this.controller) {
    controller.addListener(_onChanged);
  }

  void _onChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    super.dispose();
  }
  
  Color _hexToColor(String hexString) {
    var hexColor = hexString.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse('0x$hexColor'));
  }
}
