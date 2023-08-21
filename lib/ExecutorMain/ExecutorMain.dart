import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:blossom_tabs/blossom_tabs.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:csharp_rpc/csharp_rpc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:code_editor/code_editor.dart';

import 'package:rubisco/globals.dart';
import 'package:rubisco/Misc/datastore.dart';
import 'package:rubisco/ExecutorMain/Monaco.dart';

late Function addTabWithContent;
String initialTab = "";

String getAssetFileUrl(String asset) {
  final assetsDirectory = p.join(
      p.dirname(Platform.resolvedExecutable), 'data', 'flutter_assets', asset);

  return Uri.file(assetsDirectory).toString();
}

class ExecutorMain extends StatelessWidget {
  ExecutorMain({Key? key, required this.shadowRPC}) : super(key: key);

  CsharpRpc shadowRPC;

  @override
  Widget build(BuildContext context) {
    return Tabs(shadowRPC: shadowRPC);
  }
}

class HoverableContainer extends StatefulWidget {
  @override
  _HoverableContainerState createState() => _HoverableContainerState();
}

class _HoverableContainerState extends State<HoverableContainer> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isHovered,
      builder: (BuildContext context, bool isHovered, Widget? child) {
        return MouseRegion(
          onEnter: (_) => _isHovered.value = true,
          onExit: (_) => _isHovered.value = false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 75),
            curve: Curves.easeInOut,
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color:
                  isHovered ? const Color(0xFF13141A) : const Color(0xFF222735),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}

class CustomTab extends StatefulWidget {
  final bool isActive;
  final String title;
  final VoidCallback onClose;
  final String tabId;

  const CustomTab({
    required this.isActive,
    required this.title,
    required this.onClose,
    required this.tabId,
  });

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  late TextEditingController _titleController;
  bool _isEditing = false;
  String title = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(color: Color(0xff13141A), width: 2),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isActive ? const Color(0xff222735) : Color(0xFF13141A),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              _buildIcon(),
              _buildTitleOrTextField(),
              if (widget.isActive) _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Positioned(
      left: 4,
      top: 8,
      child: SizedBox(
        width: 23,
        height: 23,
        child: SvgPicture.asset(
          "assets/document.svg",
          key: const ValueKey<String>("assets/folder.svg"),
          colorFilter: ColorFilter.mode(
            widget.isActive
                ? Colors.white
                : const Color.fromARGB(255, 189, 189, 189),
            BlendMode.srcIn,
          ),
          semanticsLabel: "Script",
        ),
      ),
    );
  }

  Widget _buildTitleOrTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _isEditing ? _buildTextField() : _buildTitleText(),
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 38),
      child: TextField(
        controller: _titleController,
        style: TextStyle(
          color: widget.isActive
              ? Colors.white
              : const Color.fromARGB(255, 189, 189, 189),
          fontSize: 15,
        ),
        onSubmitted: (value) {
          setState(() {
            // Use appropriate way to get g['tabData']
            g['tabData'][widget.tabId]['name'] = value;
            title = value;
            _isEditing = false;
          });
        },
      ),
    );
  }

  Widget _buildTitleText() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: Text(
        title,
        softWrap: false,
        style: TextStyle(
          overflow: TextOverflow.fade,
          color: widget.isActive
              ? Colors.white
              : const Color.fromARGB(255, 189, 189, 189),
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      right: 0,
      top: 6,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: GestureDetector(
          onTap: widget.onClose,
          child: HoverableContainer(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class Tabs extends StatefulWidget {
  Tabs({Key? key, required this.shadowRPC}) : super(key: key);
  CsharpRpc shadowRPC;

  @override
  State<Tabs> createState() => _TabState();
}

class _TabState extends State<Tabs> {
  var _controller = BlossomTabController<int>(tabs: []);
  var _tabs = <BlossomTab<int>>[];
  var hasDataSet = false;

  BlossomTab<int> _getTab(String e) => BlossomTab<int>(
        id: e,
        data: int.parse(e.codeUnits.join()),
        title: e.toUpperCase(),
      );

  final exampleBrowserKeys = <String, GlobalKey<MonacoWindowState>>{};

  void callListener(BlossomTabController tabController) {
    final currentTab = tabController.currentTab;

    if (exampleBrowserKeys[_controller.currentTab]?.currentState != null) {
      if (currentTab != null) {
        exampleBrowserKeys[currentTab]
            ?.currentState
            ?.onTabSelected(tabController);
      }
    } else {
      Future.delayed(Duration(milliseconds: 100), () {
        if (currentTab != null) {
          exampleBrowserKeys[currentTab]
              ?.currentState
              ?.onTabSelected(tabController);
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
      print('generating tab');
      var tabIdList = [];
      g['tabData'].forEach((index, value) {
        tabIdList.add(index);
      });

      num tabIdIndex = 1;
      while (true) {
        if (!tabIdList.contains("t $tabIdIndex")) {
          print("generated!");
          print("t $tabIdIndex");
          return "t $tabIdIndex";
        }
        tabIdIndex += 1;
      }
    }

    addTabWithContent = (String content) async {
      /*
        PROBLEM MAYBE:
        Okay so I think it calls the init twice (for some reason)
        I think that it calls init on initialized, and init on build.
        I want init on build, but maybe it's just not getting that?
      */
      String tabId = generateTabId();
      if (setContentCallbacks[tabId] == null) {
        print("set right after generating tab (probably bad), removing key");
        setContentCallbacks[tabId] = null;
      }
      _controller.addTab(_getTab(tabId));
      print("added tab, now setting content via callback (waiting for set)");
      while (setContentCallbacks[tabId] == null) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      print("Set complete, calling");
      print("generated tab: ");
      print(tabId);
      print("callbacks: ");
      print(setContentCallbacks);
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

        exampleBrowserKeys['t 1'] = GlobalKey<MonacoWindowState>();
      }
    }

    addSavedTabs();

    super.initState();
  }

  Widget buildTab(BuildContext context, BlossomTab<int> tab, bool isActive) {
    if (g['tabData'][tab.id] == null) {
      // crappy, but tends to work
      g['tabData'][tab.id] = {'name': "Script ${1}"};
      setScript(tab.id, "");
    }

    return CustomTab(
      isActive: isActive,
      tabId: tab.id,
      title: g['tabData'][tab.id]['name'],
      onClose: () {
        _controller.removeTabById(tab.id);
        g['tabData'].remove(tab.id);
        saveData(g);
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
                        c = 't ${numericPart + 1}';
                        print("Number bit:");
                        print(numericPart);
                        g['tabData'][c] = {'name': "Script ${numericPart + 1}"};
                        setScript(c, "");
                        saveData(g);
                        print(g['tabData']);
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
            exampleBrowserKeys.putIfAbsent(
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
                        key: exampleBrowserKeys[tab.id],
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

class NewTabBtn extends StatefulWidget {
  const NewTabBtn({
    Key? key,
    required this.onTap,
  }) : super(key: key);
  final void Function() onTap;

  @override
  State<NewTabBtn> createState() => _NewTabBtnState();
}

class _NewTabBtnState extends State<NewTabBtn> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: const Icon(
          Icons.add,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }
}
