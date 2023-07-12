import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:highlight/languages/lua.dart';
import "package:webview_universal/webview_universal.dart";

final controller = CodeController(
  text: '', // Initial code
  language: lua,
);

class Monaco extends StatefulWidget {
  const Monaco({super.key});

  @override
  State<Monaco> createState() => _MonacoState();
}

class _MonacoState extends State<Monaco> {
  WebViewController webViewController = WebViewController();

  @override
  void initState() {
    super.initState();
    webViewController.init(
      context: context,
      setState: setState,
      uri: Uri.parse("https://flutter.dev"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        controller: webViewController,
      ),
    );
  }
}

class TextArea extends StatelessWidget {
  const TextArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0XFF3B4348),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Padding(padding: const EdgeInsets.all(8), child: Monaco()),
      ),
    );
  }
}

class CodeEditor extends StatelessWidget {
  const CodeEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextArea();
  }
}

class ExecutorMain extends StatelessWidget {
  const ExecutorMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: double.infinity,
                // I hate this but it'll have to do, overflows if it choses it's own size
                maxHeight: MediaQuery.of(context).size.height - 200),
            // height: MediaQuery.of(context).size.height,
            child: const CodeEditor()));
  }
}
