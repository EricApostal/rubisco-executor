import 'dart:ui';

import 'package:rubisco/Misc/datastore.dart';
import 'package:rubisco/globals.dart';
import 'package:rubisco/Encryption.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_windows/webview_windows.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:google_fonts/google_fonts.dart';

final navigatorKey = GlobalKey<NavigatorState>();
bool webviewInitialized = false;
Encryption encryption = Encryption();

bool isKeyValid() {
  if (g['keyExpires'] == '0') {
    // If key has not been initialized
    return false;
  }

  return (states['currentKeyPasses'] >= states['requiredKeyPasses']) |
      (DateTime.now().toUtc().millisecondsSinceEpoch <=
          encryption.decryptKey(g['keyExpires']));
}

class KeySystemBrowser extends StatefulWidget {
  const KeySystemBrowser({Key? key, required this.updateKeyCallback})
      : super(key: key);
  final updateKeyCallback;

  @override
  State<KeySystemBrowser> createState() => _KeySystemBrowser();
}

class _KeySystemBrowser extends State<KeySystemBrowser> {
  final _controller = WebviewController();
  final _textController = TextEditingController();

  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  void fixInvalidVisit() async {
    // errorContainer
    while (true) {
      if ((await _controller.executeScript(
              'document.getElementsByClassName("errorContainer").length > 0;') ??
          false)) {
        await _controller.setZoomFactor(1000);
        await _controller.setZoomFactor(.1);
        await _controller.setZoomFactor(.7);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void listenForCodeBox() async {
    while (true) {
      var isDone = await _controller.executeScript(
              '(document.getElementById("destination-button") != null)') ??
          false; // annoying asf null error
      if (isDone) {
        print("is done!");
        states['currentKeyPasses'] += 1;
        widget.updateKeyCallback();
        // Maybe fix no click bug?
        await Future.delayed(const Duration(milliseconds: 500));
        await _controller.loadUrl("https://workink.net/1QPE/ll7zmowf");
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> initPlatformState() async {
    try {
      await _controller.initialize();
      _controller.url.listen((url) {
        _textController.text = url;
        webviewInitialized = true;
      });

      // I have to initialize at 1, the rest are handled from listenForCodeBox()
      String url = "https://workink.net/1QPE/ll7zmowf";
      // await _controller.setUserAgent(
      //     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.188");
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.setZoomFactor(1);
      await _controller.clearCache();
      await _controller.clearCookies();
      await _controller.loadUrl(url);

      // fixInvalidVisit();
      // listenForCodeBox();

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (_) {} // we shall pray nothing breaks
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

class KeySystem extends StatefulWidget {
  const KeySystem({super.key});

  @override
  State<KeySystem> createState() => _KeySystemState();
}

class _KeySystemState extends State<KeySystem> {
  bool hasValidKey = false;

  void updateKey() {
    /*
      Called every time the user passes through a key system checkpoint
      Because of this, we can safely set the unix time from this func

      (Except for init state but that shouldn't matter)
    */

    setState(() {
      hasValidKey = isKeyValid();

      if (states['currentKeyPasses'] >= states['requiredKeyPasses']) {
        states['currentKeyPasses'] = 0;
        g['keyExpires'] = encryption.encryptKey(DateTime.now()
            .add(const Duration(hours: 24))
            .toUtc()
            .millisecondsSinceEpoch);
        saveData(g);
      }
    });
  }

  void initKey() {
    // We want to set valid key stuff on init, but not the unix timestamp

    setState(() {
      hasValidKey = (DateTime.now().toUtc().millisecondsSinceEpoch <=
          encryption.decryptKey(g['keyExpires']));
      states['currentKeyPasses'] = 0;
    });
  }

  @override
  void initState() {
    if (g["keyExpires"] == '0') {
      g["keyExpires"] = encryption.encryptKey(0);
    }

    hasValidKey = (DateTime.now().toUtc().millisecondsSinceEpoch <=
        encryption.decryptKey(g["keyExpires"]));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: (!hasValidKey)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  KeySystemBrowser(updateKeyCallback: updateKey),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                        height: 40,
                        width: 60,
                        decoration: const BoxDecoration(
                            color: Color(0xFF222735),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Center(
                              child: Text(
                                  "${states['currentKeyPasses']}/${states['requiredKeyPasses']}",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 22))),
                        )),
                  )
                ],
              ))
          : Center(
              child: Container(
                width: 350,
                height: 200,
                decoration: const BoxDecoration(
                    color: Color(0xFF222735),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          "Key Time Remaining",
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontSize: 24),
                        ),
                      ),
                      TimerCountdown(
                        colonsTextStyle: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 16),
                        timeTextStyle: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 32),
                        descriptionTextStyle: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 16),
                        format: CountDownTimerFormat.hoursMinutesSeconds,
                        endTime: DateTime.fromMillisecondsSinceEpoch(int.parse(
                            encryption.decryptKey(g['keyExpires']).toString())),
                        onEnd: () {
                          setState(() {
                            hasValidKey = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
