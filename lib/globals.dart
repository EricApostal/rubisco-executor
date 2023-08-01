library my_prj.globals;

Map<String, dynamic> g = {
  'topMost': false,
  'transparent': false,
};

Map<String, dynamic> states = {
  'isInjected': false,
  'csharpRpc': null,
  'editorCallback': (){
    print("You tried to run a script but no editor set a callback!");
  } // on self selected, 
};