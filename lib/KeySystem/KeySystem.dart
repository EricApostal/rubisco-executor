import 'dart:ui';

import 'package:Rubisco/Misc/datastore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:Rubisco/globals.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:google_fonts/google_fonts.dart';

final navigatorKey = GlobalKey<NavigatorState>();
bool webviewInitialized = false;

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
      if (await _controller.executeScript(
          'document.getElementsByClassName("errorContainer").length > 0;')) {
        await _controller.setZoomFactor(1000);
        await _controller.setZoomFactor(.1);
        await _controller.setZoomFactor(.8);
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  void listenForCodeBox() async {
    while (true) {
      var isDone = await _controller.executeScript(
          'document.getElementsByClassName("scriptname").length > 0;');
      if (isDone) {
        print("went through key pass!");
        states['currentKeyPasses'] += 1;
        print(states['currentKeyPasses']);
        widget.updateKeyCallback();
        await _controller.loadUrl("https://link-target.net/918115/rubisco");
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

      String url = "https://link-target.net/918115/rubisco";
      await _controller.setUserAgent(
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.188");
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.setZoomFactor(1);
      await _controller.loadUrl(url);

      fixInvalidVisit();
      listenForCodeBox();

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
  bool hasValidKey =
      (DateTime.now().toUtc().millisecondsSinceEpoch <= g['keyExpires']);

  void updateKey() {
    /*
      Called every time the user passes through a key system checkpoint
      Because of this, we can safely set the unix time from this func

      (Except for init state but that shouldn't matter)
    */

    setState(() {
      hasValidKey = (states['currentKeyPasses'] >=
              states['requiredKeyPasses']) |
          (DateTime.now().toUtc().millisecondsSinceEpoch <= g['keyExpires']);

      print(states['currentKeyPasses'] >= states['requiredKeyPasses']);
      print((DateTime.now().toUtc().millisecondsSinceEpoch > g['keyExpires']));

      print("Key Expires? ${g['keyExpires']}");
      print("hasValidKey? ${hasValidKey}");
      print(
          "Time until key? ${(g['keyExpires'] - DateTime.now().toUtc().millisecondsSinceEpoch) / 1000 / 60 / 60}");

      if (states['currentKeyPasses'] >= states['requiredKeyPasses']) {
        states['currentKeyPasses'] = 0;
        print("setting key expire!");
        g['keyExpires'] = DateTime.now()
            .add(
              const Duration(
                hours: 24,
              ),
            )
            .toUtc()
            .millisecondsSinceEpoch;
        print("set key expire!");
        saveData(g);
      }
    });
  }

  void initKey() {
    // We want to set valid key stuff on init, but not the unix timestamp

    setState(() {
      hasValidKey =
          (DateTime.now().toUtc().millisecondsSinceEpoch <= g['keyExpires']);
      states['currentKeyPasses'] = 0;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: (!hasValidKey)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: KeySystemBrowser(updateKeyCallback: updateKey))
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
                        endTime: DateTime.fromMillisecondsSinceEpoch(
                            g['keyExpires']),
                        onEnd: () {
                          print(DateTime.fromMillisecondsSinceEpoch(
                              g['keyExpires']));
                          print("Timer finished");
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
