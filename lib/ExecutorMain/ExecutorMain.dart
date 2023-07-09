import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/tomorrow-night-eighties.dart';
import 'package:highlight/languages/lua.dart';

final controller = CodeController(
  text: '...', // Initial code
  language: lua,
);

class TextArea extends StatelessWidget {
  const TextArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 500,
        height: 500,
        child: CodeTheme(
          data: CodeThemeData(styles: tomorrowNightEightiesTheme),
          child: SingleChildScrollView(
            child: CodeField(
              controller: controller,
            ),
          ),
        ),
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
    return const Scaffold(body: CodeEditor());
  }
}
