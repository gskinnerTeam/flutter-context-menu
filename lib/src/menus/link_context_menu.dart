import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../context_menus.dart';

class LinkContextMenu extends StatefulWidget {
  const LinkContextMenu({
    Key? key,
    required this.url,
    this.useIcons = true,
    this.border,
    this.borderRadius,
    this.bgColor,
    this.shadows,
    this.padding,
  }) : super(key: key);

  final String url;
  final bool useIcons;
  final Border? border;
  final BorderRadius? borderRadius;
  final Color? bgColor;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;

  @override
  _LinkContextMenuState createState() => _LinkContextMenuState();
}

class _LinkContextMenuState extends State<LinkContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    return cardBuilder.call(
      context,
      [
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            'Open link in new window',
            icon: widget.useIcons ? Icon(Icons.link, size: 18) : null,
            onPressed: () => handlePressed(context, _handleNewWindowPressed),
            border: widget.border,
            borderRadius: widget.borderRadius,
          ),
        ),
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            'Copy link address',
            icon: widget.useIcons ? Icon(Icons.copy, size: 18) : null,
            onPressed: () => handlePressed(context, _handleClipboardPressed),
            border: widget.border,
            borderRadius: widget.borderRadius,
          ),
        )
      ],
      widget.border,
      widget.borderRadius,
      widget.bgColor,
      widget.shadows,
      widget.padding,
    );
  }

  String _getUrl() {
    String url = this.widget.url;
    bool needsPrefix = !url.contains('http://') && !url.contains('https://');
    return (needsPrefix) ? 'https://' + url : url;
  }

  void _handleNewWindowPressed() async {
    try {
      launch(_getUrl());
    } catch (e) {
      print('$e');
    }
  }

  void _handleClipboardPressed() async =>
      Clipboard.setData(ClipboardData(text: _getUrl()));
}
