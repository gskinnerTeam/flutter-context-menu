import 'package:flutter/material.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

// Default menus, with icons or not
// GenericContextMenu
// Custom styling
// Custom Builders
// CustomViews

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Column(
        children: [
          Expanded(child: DefaultMenuTests()),
          Expanded(child: StyledMenuTests()),
          Expanded(child: CustomMenuTests()),
        ],
      ),
    );
  }
}

/// Presents the tests with default styling
class DefaultMenuTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      child: TestContent(title: 'Default Menus'),
    );
  }
}

class StyledMenuTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      buttonStyle: ContextMenuButtonStyle(
        fgColor: Colors.green,
        bgColor: Colors.red.shade100,
        hoverBgColor: Colors.red.shade200,
      ),
      child: TestContent(title: 'Styled Menus'),
    );
  }
}

/// Presents the tests with custom styling
class CustomMenuTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      /// Make a custom background
      cardBuilder:
          (_, children, border, borderRadius, bgColor, shadows, padding) {
        return Container(
          color: Colors.purple.shade100,
          child: Column(children: children),
        );
      },

      /// Make custom buttons
      buttonBuilder: (_, config, [__]) => TextButton(
        onPressed: config.onPressed,
        child: Container(
          width: double.infinity,
          child: Text(config.label),
        ),
      ),
      child: Container(
        color: Colors.blue.shade200,
        child: TestContent(title: 'Custom Menus'),
      ),
    );
  }
}

class TestContent extends StatelessWidget {
  const TestContent({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;
  final String _testImageUrl =
      'https://images.unsplash.com/photo-1590005354167-6da97870c757?auto=format&fit=crop&w=100&q=80';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          /// Example menu for non-selectable text
          ContextMenuRegion(
            contextMenu: TextContextMenu(data: title),
            child: Text(
              title,
              style: TextStyle(fontSize: 32),
            ),
          ),

          /// Example hyperlink menu
          ContextMenuRegion(
            contextMenu: LinkContextMenu(url: 'http://flutter.dev'),
            child:
                TextButton(onPressed: () {}, child: Text("http://flutter.dev")),
          ),

          /// Custom Context Menu for an Image
          ContextMenuRegion(
            contextMenu: GenericContextMenu(
              buttonConfigs: [
                ContextMenuButtonConfig(
                  'View image in browser',
                  onPressed: () => launch(_testImageUrl),
                ),
                ContextMenuButtonConfig(
                  'Copy image path',
                  onPressed: () => Clipboard.setData(
                    ClipboardData(text: _testImageUrl),
                  ),
                )
              ],
            ),
            child: Image.network(_testImageUrl),
          ),
        ],
      ),
    );
  }
}
