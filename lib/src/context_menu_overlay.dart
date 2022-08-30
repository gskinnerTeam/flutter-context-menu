library context_menus;

import 'package:flutter/material.dart';

import 'widgets/context_menu_button.dart';
import 'widgets/context_menu_card.dart';
import 'widgets/context_menu_divider.dart';
import 'widgets/measure_size_widget.dart';

// The main overlay class, which should be nested between your top-most view and the MaterialApp.
// Wraps the main app view and shows a contextMenu and contextModal on top.
// This does not rely on Navigator.overlay, so you can place it around your Navigator,
// supporting context menus within persistent portions of your scaffold.
class ContextMenuOverlay extends StatefulWidget {
  ContextMenuOverlay({
    Key? key,
    required this.child,
    this.cardBuilder,
    this.buttonBuilder,
    this.dividerBuilder,
    this.buttonStyle = const ContextMenuButtonStyle(),
  }) : super(key: key);
  final Widget child;

  /// Builds a card that wraps all the buttons in the menu.
  final ContextMenuCardBuilder? cardBuilder;

  /// Builds a button for the menu. It will be provided a [ContextMenuButtonConfig] and should return a button
  late final ContextMenuButtonBuilder? buttonBuilder;

  /// Builds a vertical or horizontal divider
  final ContextMenuDividerBuilder? dividerBuilder;

  /// Provide styles for the default context menu buttons.
  /// You can ignore this if you're using a custom button builder, or use it if it works for your styling system.
  final ContextMenuButtonStyle? buttonStyle;

  @override
  ContextMenuOverlayState createState() => ContextMenuOverlayState();

  static ContextMenuOverlayState of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<_InheritedContextMenuOverlay>() as _InheritedContextMenuOverlay)
          .state;
}

class ContextMenuOverlayState extends State<ContextMenuOverlay> {
  static ContextMenuButtonStyle defaultButtonStyle = ContextMenuButtonStyle();

  Widget? _currentMenu;
  Size? _prevSize;
  Size _menuSize = Size.zero;
  Offset _mousePos = Offset.zero;

  ContextMenuButtonBuilder? get buttonBuilder => widget.buttonBuilder;
  ContextMenuDividerBuilder? get dividerBuilder => widget.dividerBuilder;
  ContextMenuCardBuilder? get cardBuilder => widget.cardBuilder;
  ContextMenuButtonStyle get buttonStyle => widget.buttonStyle ?? defaultButtonStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        // Remove any open menus when we resize (common behavior, and avoids edge cases / complexity)
        _nullMenuIfOverlayWasResized(constraints);
        // Offset the menu depending on which quadrant of the app we're in, this will make sure it always stays in bounds.
        double dx = 0, dy = 0;
        if (_mousePos.dx > (_prevSize?.width ?? 0) / 2) dx = -_menuSize.width;
        if (_mousePos.dy > (_prevSize?.height ?? 0) / 2) dy = -_menuSize.height;
        // The final menuPos, is mousePos + quadrant offset
        Offset _menuPos = _mousePos + Offset(dx, dy);
        Widget? menuToShow = _currentMenu;

        return _InheritedContextMenuOverlay(
            state: this,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Listener(
                onPointerDown: (e) => _mousePos = e.localPosition,
                // Listen for Notifications coming up from the app
                child: Stack(
                  children: [
                    // Child is the contents of the overlay, usually the entire app.
                    widget.child,
                    // Show the menu?
                    if (menuToShow != null) ...[
                      Positioned.fill(child: Container(color: Colors.transparent)),

                      /// Underlay, blocks all taps to the main content.
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (_) => hide(),
                        onTap: () => hide(),
                        onSecondaryTapDown: (_) => hide(),
                        child: Container(),
                      ),

                      /// Position the menu contents
                      Transform.translate(
                        offset: _menuPos,
                        child: Opacity(
                          opacity: _menuSize != Size.zero ? 1 : 0,
                          // Use a measure size widget so we can offset the child properly
                          child: MeasuredSizeWidget(
                            key: ObjectKey(menuToShow),
                            onChange: _handleMenuSizeChanged,
                            child: IntrinsicWidth(child: IntrinsicHeight(child: menuToShow)),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ));
      },
    );
  }

  /// Sets the current menu to be displayed.
  /// It will not be displayed until next frame, as the child needs to be measured first.
  void show(Widget child) {
    setState(() {
      //This will hide the widget until we can calculate it's size which should take 1 frame
      _menuSize = Size.zero;
      _currentMenu = child;
    });
  }

  /// Hides the current popup if there is one. Fails silently if not.
  void hide() => setState(() => _currentMenu = null);

  /// re-position and rebuild whenever menu size changes
  void _handleMenuSizeChanged(Size value) => setState(() => _menuSize = value);

  /// Auto-close the menu when app size changes.
  /// This is classic context menu behavior at the OS level and we'll follow it because it makes life much easier :D
  void _nullMenuIfOverlayWasResized(BoxConstraints constraints) {
    final size = constraints.biggest;
    bool appWasResized = size != _prevSize;
    if (appWasResized) _currentMenu = null;
    _prevSize = size;
  }
}

/// InheritedWidget boilerplate
class _InheritedContextMenuOverlay extends InheritedWidget {
  _InheritedContextMenuOverlay({Key? key, required Widget child, required this.state}) : super(key: key, child: child);

  final ContextMenuOverlayState state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
