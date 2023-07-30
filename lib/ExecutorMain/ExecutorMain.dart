import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:blossom_tabs/blossom_tabs.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:google_fonts/google_fonts.dart';
import 'package:rubisco_one/Misc/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

String getAssetFileUrl(String asset) {
  final assetsDirectory = p.join(
      p.dirname(Platform.resolvedExecutable), 'data', 'flutter_assets', asset);

  return Uri.file(assetsDirectory).toString();
}

final navigatorKey = GlobalKey<NavigatorState>();

class ExampleBrowser extends StatefulWidget {
  @override
  State<ExampleBrowser> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<ExampleBrowser> {
  final _controller = WebviewController();
  final _textController = TextEditingController();
  bool _isWebviewSuspended = false;

  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    // print("disposing");
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await _controller.initialize();
      _controller.url.listen((url) {
        _textController.text = url;
      });

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl("file://" +
          Directory.current
              .toString()
              .replaceAll("'", "")
              .replaceAll("Directory: ", "") +
          '/bin/monaco/Monaco.html');
      // print("file://" +
      //     Directory.current
      //         .toString()
      //         .replaceAll("'", "")
      //         .replaceAll("Directory: ", "") +
      //     '/bin/monaco/Monaco.html');

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
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
                      child: Text('Continue'),
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
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF00FFA3),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: TextButton(
                onPressed: () {
                  _controller.executeScript("editor.getValue()").then((value) {
                    print(value);
              });
                },
                child: Center(
                    child: SvgPicture.asset("assets/play_arrow.svg",
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF13141A), BlendMode.srcIn),
                        semanticsLabel: 'Run script')),
              ),
            )),
        body: Webview(
          _controller,
          permissionRequested: _onPermissionRequested,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return compositeView();
  }

  @override
  bool shouldReload(_ExampleBrowser old) => false;
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
    return Tabs();
  }
}

Widget buildTab(
  BuildContext context, {
  required bool isActive,
  bool useRow = true,
  Widget? icon,
  Widget? activeIcon,
  String? title,
}) {
  var children = [
    (isActive ? activeIcon ?? icon : icon) ??
        const SizedBox(
          width: 10,
        ),
    if (title != null)
      Flexible(
        child: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: const TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
      ),
  ];
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: useRow
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: children),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ],
          ),
  );
}

class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  State<Tabs> createState() => _TabState();
}

class _TabState extends State<Tabs> {
  var _controller = BlossomTabController<int>(tabs: []);
  var _tabs = <BlossomTab<int>>[];

  BlossomTab<int> _getTab(String e) => BlossomTab<int>(
        id: e,
        data: int.parse(e.codeUnits.join()),
        title: e.toUpperCase(),
        // isSticky: e == 'd',
      );

  @override
  void initState() {
    _tabs = ['Tab 1']
        .map(
          (e) => _getTab(e),
          // (e) => BlossomTab.fromJson<int>(
          // Example of how to load from JSON-- Saving / retriving script tabs will still be a touch difficult
          //   {
          //     "id": "Tab 17",
          //     "data": {"value": 8497983251},
          //     "title": e.toUpperCase(),
          //     "maxWidth": 200.0,
          //     "stickyWidth": 50.0
          //   },
          //   (map) => map['value'],
          // ),
        )
        .toList();
    _controller = BlossomTabController<int>(currentTab: 'Tab 1', tabs: _tabs);
    super.initState();
  }

  var tabIndex = [];
  @override
  Widget build(BuildContext context) {
    // print( jsonEncode(_controller.toJson()));
    // print( _controller.tabs[0].data );
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
                dividerColor: Color.fromARGB(255, 255, 255, 255),
                shadowColor: const Color(0xFF13141A),
                bottomColor: const Color(0xFF222735),
                margin: const EdgeInsets.only(left: 40, top: 0, right: 10),
                tabBarMargin: 0,
                tabBuilder: (context, tab, isActive) =>
                    buildTab(context, isActive: isActive, title: tab.id),
                tabActions: (context, tab) => [
                  Listener(
                    onPointerDown: (_) {
                      _controller.removeTabById(tab.id);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
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
                        final z = _controller.tabs.map((e) => e.id).toList()
                          ..sort();
                        var c = z.isEmpty ? 'Tab 0' : z.last;
                        final lastCharacter =
                            String.fromCharCode(c.codeUnitAt(c.length - 1) + 1);
                        c = c.substring(0, c.length - 1) + lastCharacter;
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
            builder: (tab) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ExampleBrowser(),
                )),
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

class ColorBox extends StatefulWidget {
  const ColorBox({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  _ColorBoxState createState() => _ColorBoxState();
}

class _ColorBoxState extends State<ColorBox> {
  Color? _color;

  _randomColor() => Color(0xFF000000 + Random().nextInt(0x00FFFFFF));

  @override
  void initState() {
    _color = _randomColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = _randomColor();
        });
      },
      child: Container(
          width: 150, height: 150, color: _color, child: widget.child),
    );
  }
}