import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../context_menus.dart';

class TextContextMenu extends StatefulWidget {
  const TextContextMenu({
    Key? key,
    required this.data,
    this.controller,
    this.obscuredText = false,
    this.border,
    this.borderRadius,
    this.bgColor,
    this.shadows,
    this.padding,
  }) : super(key: key);

  final String data;
  final TextEditingController? controller;
  final bool obscuredText;
  final Border? border;
  final BorderRadius? borderRadius;
  final Color? bgColor;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;

  @override
  _TextContextMenuState createState() => _TextContextMenuState();
}

class _TextContextMenuState extends State<TextContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    bool allSelected = false, noneSelected = true;
    final tc = widget.controller;
    if (tc != null) {
      tc.value = tc.value.copyWith(
        selection: TextSelection(baseOffset: 0, extentOffset: tc.text.length),
      );
      noneSelected = tc.value.selection.isCollapsed;
    }
    bool disableCopy = widget.obscuredText;
    bool disableCut = noneSelected || widget.obscuredText;
    bool disablePaste = widget.obscuredText;
    bool disableDelete = noneSelected;
    bool disableSelectAll = allSelected || widget.data.isEmpty;

    return cardBuilder.call(
      context,
      [
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            'Copy',
            onPressed: disableCopy
                ? null
                : () => handlePressed(context, _handleCopyPressed),
            border: widget.border,
            borderRadius: widget.borderRadius,
          ),
        ),
        if (widget.controller != null) ...[
          buildDivider(),
          if (!widget.obscuredText) ...[
            buttonBuilder.call(
              context,
              ContextMenuButtonConfig(
                'Cut',
                onPressed: disableCut
                    ? null
                    : () => handlePressed(context, _handleCutPressed),
                border: widget.border,
                borderRadius: widget.borderRadius,
              ),
            ),
            buttonBuilder.call(
              context,
              ContextMenuButtonConfig(
                'Paste',
                onPressed: disablePaste
                    ? null
                    : () => handlePressed(context, _handlePastePressed),
                border: widget.border,
                borderRadius: widget.borderRadius,
              ),
            ),
          ],
          buttonBuilder.call(
            context,
            ContextMenuButtonConfig(
              'Delete',
              onPressed: disableDelete
                  ? null
                  : () => handlePressed(context, _handleDeletePressed),
              border: widget.border,
              borderRadius: widget.borderRadius,
            ),
          ),
          buildDivider(),
          buttonBuilder.call(
            context,
            ContextMenuButtonConfig(
              'Select All',
              onPressed: disableSelectAll
                  ? null
                  : () => handlePressed(context, _handleSelectAllPressed),
              border: widget.border,
              borderRadius: widget.borderRadius,
            ),
          ),
        ],
      ],
      widget.border,
      widget.borderRadius,
      widget.bgColor,
      widget.shadows,
      widget.padding,
    );
  }

  void _handleCopyPressed() async {
    String value =
        widget.controller?.selection.textInside(widget.data) ?? widget.data;
    Clipboard.setData(ClipboardData(text: value));
  }

  void _handleDeletePressed() async => widget.controller?.clear();

  void _handleSelectAllPressed() async {
    widget.controller?.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.controller?.text.length ?? 0,
    );
  }

  void _handlePastePressed() async {
    final c = widget.controller;
    if (c == null) return;
    int start = c.selection.start;
    _removeTextRange(c.selection.start, c.selection.end);
    String? value = (await Clipboard.getData('text/plain'))?.text;
    if (value != null) {
      _addTextAtOffset(c.selection.start, value);
      // Move cursor to end on paste, as one does on desktop :)
      c.selection = TextSelection.fromPosition(
        TextPosition(offset: start + value.length),
      );
    }
  }

  void _handleCutPressed() async {
    final c = widget.controller;
    if (c == null) return;
    // Remove selected section, insert new selection at offset
    int start = c.selection.start;
    int end = c.selection.end;
    //Copy content
    String content = c.text.substring(start, end);
    Clipboard.setData(ClipboardData(text: content));
    //Remove content
    _removeTextRange(start, end);
  }

  void _addTextAtOffset(int start, String value) {
    final c = widget.controller;
    if (c == null) return;
    String p1 = c.text.substring(0, start);
    String p2 = c.text.substring(start);
    c.text = p1 + value + p2;
    c.selection = TextSelection.fromPosition(
      TextPosition(offset: start + value.length),
    );
  }

  void _removeTextRange(int start, int end) {
    if (widget.controller == null) return;
    String p1 = widget.controller!.text.substring(0, start);
    String p2 = widget.controller!.text.substring(end);
    widget.controller!.text = p1 + p2;
    widget.controller!.selection = TextSelection.fromPosition(
      TextPosition(offset: start),
    );
  }
}
