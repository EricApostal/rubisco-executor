library my_prj.globals;

Map<String, dynamic> g = {
  'topMost': false,
  'transparent': false,
  'keyExpires': '0',
  'tabData': {}, // {id: {'name': null, 'scriptContents': null} }
};

Map<String, dynamic> states = {
  'isInjected': false,
  'deviceId': null,
  'csharpRpc': null,
  'requiredKeyPasses': 4,
  'currentKeyPasses': 0,
  'editorCallback': () {
    print("You tried to run a script but no editor set a callback!");
  },
  'enc': r"VA2Z-yA6qrtDc4{}D<)T)a/`JE)&^C[.6[74?ph&VWZ$Z_,MPxr+Dx$4'Z}C~I1"
};
