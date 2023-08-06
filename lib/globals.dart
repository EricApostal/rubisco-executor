library my_prj.globals;

Map<String, dynamic> g = {
  'topMost': false,
  'transparent': false,
  'keyExpires': 0
};

Map<String, dynamic> states = {
  'isInjected': false,
  'csharpRpc': null,
  'requiredKeyPasses': 1,
  'currentKeyPasses': 0,
  'editorCallback': () {
    print("You tried to run a script but no editor set a callback!");
  } // on self selected,
};
