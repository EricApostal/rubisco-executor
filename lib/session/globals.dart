library my_prj.globals;

import 'package:flutter/material.dart';

Map<String, dynamic> g = {
  'topMost': false,
  'transparent': false,
  'keyExpires': '0',
  'tabData': {}, // {id: {'name': null, 'scriptContents': null} }
};

Map<String, dynamic> states = {
  'isInjected': false,
  'dataSet': false,
  'deviceId': null,
  'csharpRpc': null,
  'requiredKeyPasses': 2,
  'currentKeyPasses': 0,
  'editorCallback': () {
    print("You tried to run a script but no editor set a callback!");
  },
  'enc': r"VA2Z-yA6qrtDc4{}D<)T)a/`JE)&^C[.6[74?ph&VWZ$Z_,MPxr+Dx$4'Z}C~I1"
};


const Map<String, Color> colors = {
  'primary': Color(0xFF1B1B20),
  'secondary':  Color(0xFF292B30),
  'selected': Color(0xFFFFFFFF)
};