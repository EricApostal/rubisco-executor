import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:csharp_rpc/csharp_rpc.dart';

import 'package:rubisco/code/tab/monaco/window.dart';
import 'package:rubisco/code/tab/native/window.dart';

String initialTab = "";

String getAssetFileUrl(String asset) {
  final assetsDirectory = p.join(
      p.dirname(Platform.resolvedExecutable), 'data', 'flutter_assets', asset);

  return Uri.file(assetsDirectory).toString();
}

// ignore: must_be_immutable
class ExecutorMain extends StatelessWidget {
  ExecutorMain({Key? key, required this.shadowRPC}) : super(key: key);

  CsharpRpc shadowRPC;

  @override
  Widget build(BuildContext context) {
    return const NativeTabs();
  }
}
