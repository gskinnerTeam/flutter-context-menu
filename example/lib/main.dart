import 'package:flutter/material.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

// Default menus, with icons or not
// GenericContextMenu
// Custom styling
// Custom Builders
// CustomViews

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Column(
        children: const [
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
  const DefaultMenuTests({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      child: const TestContent(title: 'Default Menus'),
    );
  }
}

class StyledMenuTests extends StatelessWidget {
  const StyledMenuTests({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      buttonStyle: ContextMenuButtonStyle(
        fgColor: Colors.green,
        bgColor: Colors.red.shade100,
        hoverBgColor: Colors.red.shade200,
      ),
      child: const TestContent(title: 'Styled Menus'),
    );
  }
}

/// Presents the tests with custom styling
class CustomMenuTests extends StatelessWidget {
  const CustomMenuTests({
    Key? key,
  }) : super(key: key);

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
        child: SizedBox(
          width: double.infinity,
          child: Text(config.label),
        ),
      ),
      child: Container(
        color: Colors.blue.shade200,
        child: const TestContent(title: 'Custom Menus'),
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          /// Example menu for non-selectable text
          ContextMenuRegion(
            contextMenu: TextContextMenu(data: title),
            child: Text(
              title,
              style: const TextStyle(fontSize: 32),
            ),
          ),

          /// Example hyperlink menu
          ContextMenuRegion(
            contextMenu: const LinkContextMenu(
              url: 'http://flutter.dev',
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text("http://flutter.dev"),
            ),
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
