import 'dart:async';

import 'package:flutter/material.dart';

import '../../context_menus.dart';

/// Pass a list of ButtonConfigs, and this will create a basic context menu dynamically.
class GenericContextMenu extends StatefulWidget {
  const GenericContextMenu({
    Key? key,
    required this.buttonConfigs,
    this.injectDividers = false,
    this.autoClose = true,
    this.border,
    this.borderRadius,
    this.bgColor,
    this.shadows,
    this.padding,
  }) : super(key: key);

  final List<ContextMenuButtonConfig?> buttonConfigs;
  final bool injectDividers;
  final bool autoClose;
  final Border? border;
  final BorderRadius? borderRadius;
  final Color? bgColor;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;

  @override
  _GenericContextMenuState createState() => _GenericContextMenuState();
}

class _GenericContextMenuState extends State<GenericContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    // Guard against an empty list
    if (widget.buttonConfigs.isEmpty) {
      // auto-close the menu since it's empty
      scheduleMicrotask(() => context.contextMenuOverlay.close());
      return const SizedBox
          .shrink(); // Need to return something, but it will be thrown away next frame.
    }
    // Interleave dividers into the menu, use null as a marker to indicate a divider at some position.
    if (widget.injectDividers) {
      for (var i = widget.buttonConfigs.length - 2; i-- > 1; i++) {
        widget.buttonConfigs.add(null);
      }
    }
    return cardBuilder.call(
      context,
      // Create a list of Buttons / Dividers
      widget.buttonConfigs.map(
        (config) {
          // build a divider on null
          if (config == null) return buildDivider();
          // If not null, build a btn
          VoidCallback? action = config.onPressed;
          // Wrap external action in handlePressed so menu will auto-close
          if (widget.autoClose && action != null) {
            action = () => handlePressed(context, config.onPressed!);
          }
          // Build btn
          return buttonBuilder.call(
            context,
            ContextMenuButtonConfig(
              config.label,
              icon: config.icon,
              iconHover: config.iconHover,
              shortcutLabel: config.shortcutLabel,
              onPressed: action,
              border: config.border,
              borderRadius: config.borderRadius,
            ),
          );
        },
      ).toList(),
      widget.border,
      widget.borderRadius,
      widget.bgColor,
      widget.shadows,
      widget.padding,
    );
  }
}
