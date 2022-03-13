import 'package:flutter/material.dart';

typedef Widget ContextMenuButtonBuilder(
  BuildContext context,
  ContextMenuButtonConfig config, [
  ContextMenuButtonStyle? style,
]);

/// The default ContextMenu button. To provide your own, override [ContextMenuOverlay] buttonBuilder.
class ContextMenuButton extends StatefulWidget {
  const ContextMenuButton(
    this.config, {
    Key? key,
    this.style,
  }) : super(key: key);

  final ContextMenuButtonConfig config;
  final ContextMenuButtonStyle? style;

  @override
  _ContextMenuButtonState createState() => _ContextMenuButtonState();
}

class _ContextMenuButtonState extends State<ContextMenuButton> {
  bool _isMouseOver = false;
  ContextMenuButtonConfig get config => widget.config;

  set isMouseOver(bool isMouseOver) {
    setState(() => _isMouseOver = isMouseOver);
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = widget.config.onPressed == null;
    bool showMouseOver = _isMouseOver && !isDisabled;
    Color defaultTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    ContextMenuButtonStyle style = ContextMenuButtonStyle(
      textStyle:
          widget.style?.textStyle ?? Theme.of(context).textTheme.bodyText1,
      shortcutTextStyle: widget.style?.shortcutTextStyle ??
          Theme.of(context).textTheme.bodyText2,
      fgColor: widget.style?.fgColor ?? defaultTextColor,
      bgColor: widget.style?.bgColor ?? Colors.transparent,
      hoverBgColor: widget.style?.hoverBgColor ??
          Theme.of(context).backgroundColor.withOpacity(.2),
      hoverFgColor:
          widget.style?.hoverFgColor ?? Theme.of(context).colorScheme.secondary,
      padding: widget.style?.padding ?? EdgeInsets.all(6),
    );

    /// Handling our own clicks
    return GestureDetector(
      onTapDown: (_) => isMouseOver = true,
      onTapUp: (_) {
        isMouseOver = false;
        widget.config.onPressed?.call();
      },
      child: MouseRegion(
        onEnter: (_) => isMouseOver = true,
        onExit: (_) => isMouseOver = false,
        cursor: !isDisabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: Opacity(
          opacity: isDisabled ? style.disabledOpacity : 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: showMouseOver ? style.hoverBgColor : style.bgColor,
              borderRadius: widget.config.borderRadius,
              border: widget.config.border,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Optional Icon
                if (config.icon != null) ...[
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: (_isMouseOver)
                          ? config.iconHover ?? config.icon!
                          : config.icon!),
                  SizedBox(width: 16)
                ],

                /// Main Label
                Text(
                  config.label,
                  style: style.textStyle!.copyWith(color: style.fgColor),
                ),
                Spacer(),

                /// Shortcut Label
                if (config.shortcutLabel != null) ...[
                  Opacity(
                    opacity: showMouseOver ? 1 : .7,
                    child: Text(
                      config.shortcutLabel!,
                      style: (style.shortcutTextStyle ?? style.textStyle!)
                          .copyWith(
                        color: style.fgColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContextMenuButtonStyle {
  ContextMenuButtonStyle({
    this.fgColor,
    this.bgColor,
    this.hoverFgColor,
    this.hoverBgColor,
    this.padding,
    this.textStyle,
    this.shortcutTextStyle,
    this.disabledOpacity = .7,
  });

  final Color? fgColor;
  final Color? bgColor;
  final Color? hoverFgColor;
  final Color? hoverBgColor;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final TextStyle? shortcutTextStyle;
  final double disabledOpacity;
}

class ContextMenuButtonConfig {
  ContextMenuButtonConfig(
    this.label, {
    required this.onPressed,
    this.shortcutLabel,
    this.icon,
    this.iconHover,
    this.border,
    this.borderRadius,
  });

  final String label;
  final String? shortcutLabel;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? iconHover;
  final Border? border;
  final BorderRadius? borderRadius;
}
