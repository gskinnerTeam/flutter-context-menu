import 'package:flutter/material.dart';

typedef Widget ContextMenuButtonBuilder(BuildContext context, ContextMenuButtonConfig config,
    [ContextMenuButtonStyle? style]);

/// The default ContextMenu button. To provide your own, override [ContextMenuOverlay] buttonBuilder.
class ContextMenuButton extends StatefulWidget {
  final ContextMenuButtonConfig config;
  final ContextMenuButtonStyle? style;

  const ContextMenuButton(this.config, {Key? key, this.style}) : super(key: key);

  @override
  _ContextMenuButtonState createState() => _ContextMenuButtonState();
}

class _ContextMenuButtonState extends State<ContextMenuButton> {
  bool _isMouseOver = false;
  set isMouseOver(bool isMouseOver) => setState(() => _isMouseOver = isMouseOver);
  ContextMenuButtonConfig get config => widget.config;

  @override
  Widget build(BuildContext context) {
    bool isDisabled = widget.config.onPressed == null;
    bool showMouseOver = _isMouseOver && !isDisabled;
    Color defaultTextColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    final ThemeData theme = Theme.of(context);
    TextStyle? defaultTextStyle = theme.textTheme.bodyText1?.copyWith(color: theme.colorScheme.onSecondary);
    TextStyle? shortcutTextStyle = theme.textTheme.bodyText2?.copyWith(color: theme.colorScheme.onSecondary);
    ContextMenuButtonStyle style = ContextMenuButtonStyle(
      textStyle: widget.style?.textStyle ?? defaultTextStyle,
      shortcutTextStyle: widget.style?.shortcutTextStyle ?? shortcutTextStyle,
      fgColor: widget.style?.fgColor ?? defaultTextColor,
      bgColor: widget.style?.bgColor ?? Colors.transparent,
      hoverBgColor: widget.style?.hoverBgColor ?? Theme.of(context).backgroundColor.withOpacity(.2),
      hoverFgColor: widget.style?.hoverFgColor ?? Theme.of(context).colorScheme.secondary,
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
            color: showMouseOver ? style.hoverBgColor : style.bgColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Optional Icon
                if (config.icon != null) ...[
                  SizedBox(
                      width: 16, height: 16, child: (showMouseOver) ? config.iconHover ?? config.icon! : config.icon!),
                  SizedBox(width: 16)
                ],

                /// Main Label
                Text(config.label,
                    style: style.textStyle!.copyWith(color: showMouseOver ? style.hoverFgColor : style.fgColor)),
                Spacer(),

                /// Shortcut Label
                if (config.shortcutLabel != null) ...[
                  Opacity(
                    opacity: showMouseOver ? 1 : .7,
                    child: Text(
                      config.shortcutLabel!,
                      style: (style.shortcutTextStyle ?? style.textStyle!)
                          .copyWith(color: showMouseOver ? style.hoverFgColor : style.fgColor),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContextMenuButtonStyle {
  const ContextMenuButtonStyle(
      {this.fgColor,
      this.bgColor,
      this.hoverFgColor,
      this.hoverBgColor,
      this.padding,
      this.textStyle,
      this.shortcutTextStyle,
      this.disabledOpacity = .7});
  final Color? fgColor;
  final Color? bgColor;
  final Color? hoverFgColor;
  final Color? hoverBgColor;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final TextStyle? shortcutTextStyle;
  final double disabledOpacity;

  ContextMenuButtonStyle copyWith(
      {Color? fgColor,
      Color? bgColor,
      Color? hoverFgColor,
      Color? hoverBgColor,
      EdgeInsets? padding,
      TextStyle? textStyle,
      TextStyle? shortcutTextStyle,
      double disabledOpacity = .7}) {
    return ContextMenuButtonStyle(
      fgColor: fgColor ?? this.fgColor,
      bgColor: bgColor ?? this.bgColor,
      hoverFgColor: hoverFgColor ?? this.hoverFgColor,
      hoverBgColor: hoverBgColor ?? this.hoverBgColor,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      disabledOpacity: disabledOpacity,
    );
  }
}

class ContextMenuButtonConfig {
  final String label;
  final String? shortcutLabel;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? iconHover;

  ContextMenuButtonConfig(this.label, {required this.onPressed, this.shortcutLabel, this.icon, this.iconHover});
}
