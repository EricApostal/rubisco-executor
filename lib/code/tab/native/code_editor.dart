import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/lua.dart';

final controller = CodeController(
  text: '...', // Initial code
  language: lua,
);

class NativeEditor extends StatefulWidget {
  const NativeEditor({super.key});

  @override
  State<NativeEditor> createState() => NativeEditorState();
}

class NativeEditorState extends State<NativeEditor> {
  void onTabSelected() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
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
