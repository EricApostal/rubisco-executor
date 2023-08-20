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

import 'package:rubisco/globals.dart';
import 'package:rubisco/Misc/datastore.dart';

late CsharpRpc csharpRpc;
late Function addTabWithContent;
String initialTab = "";

var webviewInitialized = false;
var setContentCallbacks = {};

void initRPC() async {
  var modulePath = r"bin\bin\ShadowRPC.exe";
  csharpRpc = await CsharpRpc(modulePath).start();
  print("started!");
  states['csharpRpc'] = csharpRpc;
  print(csharpRpc);
}

String getAssetFileUrl(String asset) {
  final assetsDirectory = p.join(
      p.dirname(Platform.resolvedExecutable), 'data', 'flutter_assets', asset);

  return Uri.file(assetsDirectory).toString();
}

final navigatorKey = GlobalKey<NavigatorState>();

String getScript(String tabID) {
  if (File('bin/tabs/${tabID}.txt').existsSync()) {
    return File('bin/tabs/${tabID}.txt').readAsStringSync();
  } else {
    return "";
  }
}

void setScript(String tabID, String content) async {
  File file = File('bin/tabs/${tabID}.txt');
  file.writeAsString(content);
}

class ExampleBrowser extends StatefulWidget {
  const ExampleBrowser(
      {Key? key, required this.tabController, required this.tabID})
      : super(key: key);

  final BlossomTabController tabController;
  final String tabID;

  @override
  State<ExampleBrowser> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<ExampleBrowser> {
  final _controller = WebviewController();
  final _textController = TextEditingController();

  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void onTabSelected(BlossomTabController controller) async {
    while (!webviewInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    String jsonUtf8Escape(String input) {
      var runes = input.runes;
      var buffer = StringBuffer();

      for (var rune in runes) {
        if (rune < 0x80) {
          buffer.writeCharCode(rune);
        } else {
          buffer.write('\\u{${rune.toRadixString(16)}}');
        }
      }

      return buffer.toString();
    }

    states["editorCallback"] = () {
      _controller.executeScript("editor.getValue()").then((script) {
        // this doesn't have to be a callback but whatever
        csharpRpc.invoke(method: "RunScript", params: [jsonUtf8Escape(script)]);
      });
    };
  }

  // Sets the current tab state's box content (for tab saving)
  void statePersistLoop() async {
    // Prevents us from setting content when we don't need to
    String lastContent = "";
    while (true) {
      // This technically can return Null, so we have to add a handler for that
      String currentContent =
          await _controller.executeScript("editor.getValue()") ?? "";

      // If it even matters to write
      if (lastContent != currentContent) {
        print("UPDATING CONTENT!");
        // bad fix, just for tab 1 which initializes seperately
        if (g['tabData'][widget.tabID] == null) {
          print("Tab is Null!");
          g['tabData'][widget.tabID] = {'name': "Script ${widget.tabID}"};
          setScript(widget.tabID, currentContent);
        }

        // Update tab array with new state
        setScript(widget.tabID, currentContent);
        print(g['tabData'][widget.tabID]);
        // Write to file (shouldn't cause race condition hopefully)
        saveData(g);

        // To prevent excessive writes
        lastContent = currentContent;
      }
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  void fillTabContent() async {
    /*
    Problem: It will retrieve properly, but often sets the wrong value
    Why: I'm using currentTab, which may not be itself. I should pass self into constructor.
  */
    var currentTab = g['tabData'][widget.tabID];
    if (currentTab != null) {
      while (getScript(widget.tabID) !=
          (await _controller.executeScript("editor.getValue();"))) {
        // replaces backticks with escaped so it doesn't escape the JS script
        String escapedScript = getScript(widget.tabID).replaceAll('`', '\\`');
        await _controller.executeScript('editor.setValue(`$escapedScript`)');
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  void initSetEditorCallback() async {
    /*
    Maybe the problem is that, if this is called when it's not built, it won't work?
    */
    // await Future.delayed(const Duration(seconds: 1));
    if (setContentCallbacks[widget.tabID] != null) {
      setContentCallbacks[widget.tabID] = null;
      print("DEFINITE PROBLEM: This Tab ID already has a callback.");
    }
    setContentCallbacks[widget.tabID] = (String content) async {
      print("set content callback");
      String escapedScript = content.replaceAll('`', '\\`');
      print("waiting for value to be correct...");
      print("Tab ID is:");
      print(widget.tabID);
      // await Future.delayed(Duration(milliseconds: 0));
      // await _controller.executeScript('editor.setValue(`$escapedScript`)');
      print("Script: ");
      print(await _controller.executeScript("editor.getValue();") == null);
      while ((await _controller.executeScript("editor.getValue();")) == null) {
        await Future.delayed(const Duration(milliseconds: 250));
        await _controller.executeScript('editor.setValue(`$escapedScript`)');
      }
      print("Value has been set!");
    };
  }

  Future<void> initPlatformState() async {
    try {
      await _controller.initialize();
      _controller.url.listen((url) {
        _textController.text = url;
        webviewInitialized = true;
      });

      String url = "${Directory.current.path}\\bin\\bin\\monaco\\Monaco.html";

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl(url);
      await _controller.setZoomFactor(1.1);

      statePersistLoop();
      fillTabContent();

      // TODO: make a required bool "isFirstTab", this won't work if user removes t 1.
      // if (initialTab == "") {
      //   print("forcing tab selected call");
      //   onTabSelected(widget.tabController);
      //   initialTab = widget.tabID;
      // }

      // I mean I *think* this works?
      onTabSelected(widget.tabController);

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        '', // 'Not Initialized', // blank so it doesn't look goofy
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      initSetEditorCallback();
      return RunButton(
        webviewController: _controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return compositeView();
  }
}

class RunButton extends StatefulWidget {
  const RunButton({super.key, required this.webviewController});

  final WebviewController webviewController;

  @override
  State<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<RunButton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Webview(
        widget.webviewController,
        permissionRequested: _onPermissionRequested,
      ),
    );
  }
}

Future<WebviewPermissionDecision> _onPermissionRequested(
    String url, WebviewPermissionKind kind, bool isUserInitiated) async {
  final decision = await showDialog<WebviewPermissionDecision>(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('WebView permission requested'),
      content: Text('WebView has requested permission \'$kind\''),
      actions: <Widget>[
        TextButton(
          onPressed: () =>
              Navigator.pop(context, WebviewPermissionDecision.deny),
          child: const Text('Deny'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, WebviewPermissionDecision.allow),
          child: const Text('Allow'),
        ),
      ],
    ),
  );

  return decision ?? WebviewPermissionDecision.none;
}

class ExecutorMain extends StatelessWidget {
  const ExecutorMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Tabs();
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
              color: Colors
                  .white, // You might want to change the color when hovered, so the icon remains visible.
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

  const CustomTab(
      {required this.isActive,
      required this.title,
      required this.onClose,
      required this.tabId});

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
              vertical: BorderSide(color: Color(0xff13141A), width: 2))),
      child: Container(
        decoration: BoxDecoration(
            color:
                widget.isActive ? const Color(0xff222735) : Color(0xFF13141A),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              Positioned(
                left: 4,
                top: 8,
                child: SizedBox(
                  width: 23,
                  height: 23,
                  child: SvgPicture.asset("assets/document.svg",
                      key: const ValueKey<String>("assets/folder.svg"),
                      colorFilter: ColorFilter.mode(
                          widget.isActive
                              ? Colors.white
                              : const Color.fromARGB(255, 189, 189, 189),
                          BlendMode.srcIn),
                      semanticsLabel: "Script"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _isEditing
                      ? Padding(
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
                                g['tabData'][widget.tabId]['name'] = value;
                                title = value;
                                _isEditing = false;
                              });
                              // Update the title value in the parent widget if necessary
                            },
                          ),
                        )
                      : GestureDetector(
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
                        ),
                ),
              ),
              if (widget.isActive)
                Positioned(
                  right: 0,
                  top: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                        onTap: widget.onClose, child: HoverableContainer()),
                  ),
                ),
            ],
          ),
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
  const Tabs({Key? key}) : super(key: key);

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

  final exampleBrowserKeys = <String, GlobalKey<_ExampleBrowser>>{};

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

        exampleBrowserKeys['t 1'] = GlobalKey<_ExampleBrowser>();
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
                tab.id, () => GlobalKey<_ExampleBrowser>());
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 4,
                  child: SizedBox(
                    width: 4000, // or your desired width
                    height: 2000, // or your desired height
                    child: ClipRect(
                      child: ExampleBrowser(
                        key: exampleBrowserKeys[tab.id],
                        tabController: _controller,
                        tabID: tab.id,
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
