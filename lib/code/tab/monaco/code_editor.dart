import 'dart:io';
import 'dart:async';

import 'package:blossom_tabs/blossom_tabs.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter/services.dart';
import 'package:csharp_rpc/csharp_rpc.dart';

import 'package:rubisco/session/globals.dart';
import 'package:rubisco/misc/data_store.dart';

final navigatorKey = GlobalKey<NavigatorState>();
bool webviewInitialized = false;
Map<dynamic, dynamic> setContentCallbacks = {};

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

class MonacoWindow extends StatefulWidget {
  MonacoWindow({
    Key? key,
    required this.tabController,
    required this.tabID,
    required this.shadowRPC,
  }) : super(key: key);

  final BlossomTabController tabController;
  final String tabID;
  final CsharpRpc shadowRPC;

  bool tabStillOpen = true;

  void setTabOpenState(bool newState) {
    tabStillOpen = newState;
  }

  @override
  State<MonacoWindow> createState() => MonacoWindowState();
}

class MonacoWindowState extends State<MonacoWindow> {
  final _controller = WebviewController();
  final _textController = TextEditingController();

  // TODO: Implement a way to mutate this on close

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
        widget.shadowRPC
            .invoke(method: "RunScript", params: [jsonUtf8Escape(script)]);
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

      if (!widget.tabStillOpen) {
        // Tab is no longer open, don't run file
        return;
      }

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
        await Future.delayed(const Duration(milliseconds: 100));
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
    }
    setContentCallbacks[widget.tabID] = (String content) async {
      print("set content callback");
      String escapedScript = content.replaceAll('`', '\\`');
      print("waiting for value to be correct...");
      print("Tab ID is:");
      print(widget.tabID);
      // await Future.delayed(Duration(milliseconds: 0));
      // await _controller.executeScript('editor.setValue(`$escapedScript`)');
      print("Is editor null?: ");
      print(await _controller.executeScript("editor.getValue();") == null);
      while ((await _controller.executeScript("editor.getValue();")) == null) {
        print("Set content attempt...");
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
    // borderRadius: const BorderRadius.all( Radius.circular(4) ),
    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 8),
      child: Scaffold(
        body: ClipRRect(
          borderRadius: const BorderRadius.all( Radius.circular(4) ),
          child: Container(
            decoration: BoxDecoration(
              color: colors['secondary']
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Webview(
                widget.webviewController,
                permissionRequested: _onPermissionRequested,
              ),
            ),
          ),
        ),
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
