import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai.dart';
import 'package:highlight/languages/lua.dart';

final controller = CodeController(
  text: '', // Initial code
  language: lua,
);

class TextArea extends StatelessWidget {
  const TextArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController(); // Create a ScrollController

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0XFF3B4348)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: CodeTheme(
            data: CodeThemeData(styles: monokaiTheme),
            child: SizedBox(
              width: 100,
              height: 100,
              child: SingleChildScrollView(
                controller: scrollController, // Attach the ScrollController
                child: CodeField(
                  background: const Color(0XFF3B4348),
                  controller: controller,
                ),
              ),
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
  const ExecutorMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        children: [
          Expanded(
            child: CodeEditor(),
          ),
        ],
      ),
    );
  }
}
