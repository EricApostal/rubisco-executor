import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/tomorrow-night-eighties.dart';
import 'package:highlight/languages/lua.dart';

/*
  I really do like this, but it crashes when using large scripts, and uses a shitload of ram
  I don't think it's a possiblity :(
*/

final controller = CodeController(
  text: '', // Initial code
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
    return CodeTheme(
      data: CodeThemeData(styles: tomorrowNightEightiesTheme),
      child: SingleChildScrollView(
        child: CodeField(
          background: const Color(0xFF13141A),
          controller: controller,
        ),
      ),
    );
  }
}
