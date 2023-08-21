import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

class NativeTabs extends StatefulWidget {
  const NativeTabs({super.key});

  @override
  State<NativeTabs> createState() => _TabViewPageState();
}

class _TabViewPageState extends State<NativeTabs> {
  int currentIndex = 0;
  List<Tab> tabs = [];

  TabWidthBehavior tabWidthBehavior = TabWidthBehavior.equal;
  CloseButtonVisibilityMode closeButtonVisibilityMode =
      CloseButtonVisibilityMode.always;
  bool showScrollButtons = true;
  bool wheelScroll = false;

  Tab generateTab(int index) {
    final allIcons = FluentIcons.allIcons.values;
    late Tab tab;
    tab = Tab(
      text: Text('Document $index'),
      semanticLabel: 'Document #$index',
      icon: Icon(allIcons.elementAt(Random().nextInt(allIcons.length))),
      body: Container(
        color:
            Colors.accentColors[Random().nextInt(Colors.accentColors.length)],
      ),
      onClosed: () {
        setState(() {
          tabs.remove(tab);

          if (currentIndex > 0) currentIndex--;
        });
      },
    );
    return tab;
  }

  @override
  Widget build(BuildContext context) {
    generateTab(1);
    tabs = List.generate(3, generateTab);
    final theme = FluentTheme.of(context);
    return SizedBox(
      height: 400,
      child: TabView(
        tabs: tabs,
        currentIndex: currentIndex,
        onChanged: (index) => setState(() => currentIndex = index),
        tabWidthBehavior: tabWidthBehavior,
        closeButtonVisibility: closeButtonVisibilityMode,
        showScrollButtons: showScrollButtons,
        onNewPressed: () {
          setState(() {
            final index = tabs.length + 1;
            final tab = generateTab(index);
            tabs.add(tab);
          });
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = tabs!.removeAt(oldIndex);
            tabs.insert(newIndex, item);

            if (currentIndex == newIndex) {
              currentIndex = oldIndex;
            } else if (currentIndex == oldIndex) {
              currentIndex = newIndex;
            }
          });
        },
      ),
    );
  }
}
