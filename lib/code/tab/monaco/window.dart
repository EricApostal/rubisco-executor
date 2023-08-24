import 'package:blossom_tabs/blossom_tabs.dart';
import 'package:flutter/material.dart';
import 'package:csharp_rpc/csharp_rpc.dart';
import 'package:rubisco/code/tab/monaco/code_editor.dart';
import 'package:rubisco/code/tab/monaco/tab.dart';
import 'package:rubisco/session/globals.dart';
import 'package:rubisco/misc/data_store.dart';

import 'dart:math';
import 'dart:io';

late Function addTabWithContent;

// ignore: must_be_immutable
class MonacoTabs extends StatefulWidget {
  MonacoTabs({Key? key, required this.shadowRPC}) : super(key: key);
  CsharpRpc shadowRPC;

  @override
  State<MonacoTabs> createState() => _TabState();
}

class _TabState extends State<MonacoTabs> {
  var _controller = BlossomTabController<int>(tabs: []);
  var _tabs = <BlossomTab<int>>[];
  var hasDataSet = false;

  BlossomTab<int> _getTab(String e) => BlossomTab<int>(
        id: e,
        data: int.parse(e.codeUnits.join()),
        title: e.toUpperCase(),
      );

  final monacoEditorKeys = <String, GlobalKey<MonacoWindowState>>{};

  void callListener(BlossomTabController tabController) {
    final currentTab = tabController.currentTab;

    if (monacoEditorKeys[_controller.currentTab]?.currentState != null) {
      if (currentTab != null) {
        monacoEditorKeys[currentTab]
            ?.currentState
            ?.onTabSelected(tabController);
      }
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (currentTab != null) {
          monacoEditorKeys[currentTab]
              ?.currentState
              ?.onTabSelected(tabController);
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callListener(_controller);
    });
    _controller.pageController.addListener(() {
      callListener(_controller);
    });

    void addSavedTabs() async {
      while (!states['dataSet']) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      g['tabData'].forEach((index, value) {
        _controller.addTab(_getTab(index));
      });
    }

    String generateTabId() {
      // return "t ${Random().nextInt(100) + 50}";
      var tabIdList = [];
      g['tabData'].forEach((index, value) {
        tabIdList.add(index);
      });

      num tabIdIndex = 1;
      while (true) {
        if (!tabIdList.contains("t $tabIdIndex")) {
          return "t $tabIdIndex";
        }
        tabIdIndex += 1;
      }
    }

    // Creates a tab then fills monaco with specified content
    addTabWithContent = (String content) async {
      String tabId = generateTabId();
      if (setContentCallbacks[tabId] == null) {
        setContentCallbacks[tabId] = null;
      }
      _controller.addTab(_getTab(tabId));
      while (setContentCallbacks[tabId] == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      setContentCallbacks[tabId](content);
    };

    void initTabStates() async {
      while (!states['dataSet']) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (g['tabData'].length > 0) {
        addSavedTabs();
      } else {
        _tabs = ['t 1']
            .map(
              (e) => _getTab(e),
            )
            .toList();
        _controller = BlossomTabController<int>(
          currentTab: 't 1',
          tabs: _tabs,
        );

        monacoEditorKeys['t 1'] = GlobalKey<MonacoWindowState>();
      }
    }

    addSavedTabs();

    super.initState();
  }

  Widget buildTab(BuildContext context, BlossomTab<int> tab, bool isActive) {
    if (g['tabData'][tab.id] == null) {
      // crappy, but tends to work
      g['tabData'][tab.id] = {'name': "Script 1"};
      setScript(tab.id, "");
    }

    return CustomTab(
      isActive: isActive,
      tabId: tab.id,
      title: g['tabData'][tab.id]['name'],
      onClose: () async {
        // Remove the current tab
        _controller.removeTabById(tab.id);
        File("bin/tabs/${tab.id}.txt").delete();
        g['tabData'].remove(tab.id);
        saveData(g);

        // Set the new current tab
        // _controller.currentTab = 0;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlossomTabControllerScope(
      controller: _controller,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: Stack(
            children: [
              BlossomTabBar<int>(
                height: 38,
                bottomBarHeight: 0,
                selectedColor: const Color(0xFF222735),
                dragColor: const Color(0xFF222735),
                stickyColor: Colors.white,
                dividerColor: const Color(0xFF222735),
                shadowColor: const Color(0xFF13141A),
                bottomColor: const Color(0xFF222735),
                margin: const EdgeInsets.only(left: 20, top: 0, right: 10),
                tabBarMargin: 0,
                tabBuilder: (context, tab, isActive) =>
                    buildTab(context, tab, isActive),
                tabActions: (context, tab) => [
                  GestureDetector(
                    // Use GestureDetector here
                    onTap: () {
                      _controller.removeTabById(tab.id);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                    ),
                  ),
                ],
                bottomBar: BlossomTabControllerScopeDescendant<int>(
                    builder: (context, controller) {
                  return Container();
                }),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: NewTabBtn(
                      onTap: () {
                        final z = _controller.tabs.map((e) => e.id).toList();
                        z.sort((a, b) {
                          final numericPartA = int.parse(a.split(' ').last);
                          final numericPartB = int.parse(b.split(' ').last);
                          return numericPartA.compareTo(numericPartB);
                        });
                        var c = z.isEmpty ? 't 0' : z.last;
                        final numericPart = int.parse(c.split(' ').last);
                        // Make tab ID
                        c = 't ${numericPart + 1}';
                        // Auto-generated tab name
                        g['tabData'][c] = {'name': "Script ${numericPart + 1}"};
                        setScript(c, "");
                        saveData(g);
                        setScript(c, "");
                        _controller.addTab(_getTab(c));
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        body: BlossomTabView<int>(
          builder: (tab) {
            monacoEditorKeys.putIfAbsent(
                tab.id, () => GlobalKey<MonacoWindowState>());
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 4,
                  child: SizedBox(
                    width: 4000,
                    height: 2000,
                    child: ClipRect(
                      child: MonacoWindow(
                        key: monacoEditorKeys[tab.id],
                        tabController: _controller,
                        tabID: tab.id,
                        shadowRPC: widget.shadowRPC,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
