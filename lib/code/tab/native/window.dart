import 'dart:math';
import 'package:flutter/material.dart' as material;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rubisco/code/tab/native/monaco_editor.dart';
import 'package:csharp_rpc/csharp_rpc.dart';
import 'package:rubisco/main.dart';

class NativeTabs extends StatefulWidget {
  const NativeTabs({super.key, required this.shadowRPC});

  final CsharpRpc shadowRPC;

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
    late Tab tab;
    tab = Tab(
      text: Text('Script $index', style: const TextStyle(color: Colors.white)),
      semanticLabel: 'Script #$index',
      icon: material.SizedBox(
        width: 20,
        height: 20,
        child: SvgPicture.asset(
          "assets/document.svg",
          key: const ValueKey<String>("assets/folder.svg"),
          colorFilter: const ColorFilter.mode(
            Color.fromARGB(255, 189, 189, 189),
            BlendMode.srcIn,
          ),
          semanticsLabel: "Script",
        ),
      ),
      body: material.Padding(
        padding: const EdgeInsets.only(top: 2),
        child: MonacoWindow(
          shadowRPC: shadowRPC,
        ),
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
  void initState() {
    tabs = List.generate(1, generateTab);
    super.initState();
  }

  // This issue proposes the solution, but I cannot find the color thing
  // https://github.com/bdlukaa/fluent_ui/issues/562
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            final item = tabs.removeAt(oldIndex);
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
