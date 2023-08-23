import 'dart:io';

import 'package:rubisco/code/executor.dart';
import 'package:rubisco/cloud/script_search.dart';
import 'package:rubisco/settings/settings.dart';
import 'package:rubisco/misc/data_store.dart';
import 'package:rubisco/session/globals.dart';
import 'package:rubisco/key/key_system.dart';
import 'package:rubisco/script/local_scripts.dart';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:csharp_rpc/csharp_rpc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

late CsharpRpc shadowRPC;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Starts RPC in ExecutorMain. Uses some shitty global system.
  print("IF PROGRAM STOPS HERE, YOU NEED TO RUN AS ADMIN!");
  shadowRPC = await getShadowRPC();
  initDeviceInfo();
  noFileHandler();

  // Init Aptabase analytics
  await Aptabase.init("A-EU-2292169984");

  windowManager.ensureInitialized();
  Window.initialize();
  Window.setEffect(effect: WindowEffect.transparent);
  windowManager.waitUntilReadyToShow().then((_) async {
    windowManager.show();
  });

  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(700, 400);
    const minSize = Size(500, 300);
    appWindow.minSize = minSize;
    appWindow.size = initialSize; // default size
    appWindow.title = "Rubisco BETA";
    appWindow.show();
  });
}

Future getShadowRPC() async {
  var modulePath = r"bin\bin\ShadowRPC.exe";
  return await CsharpRpc(modulePath).start();
}

void noFileHandler() async {
  // Adds folders to ensure no runtime errors

  if (!(await File("bin").exists())) {
    Directory('bin').create();
  }
  if (!(await File("scripts").exists())) {
    Directory('scripts').create();
  }

  if (!(await File("bin/tabs").exists())) {
    print("TABS DO NOT EXIST, GENERATING");
    var bin = Directory('bin/tabs').create();
    print(bin);
  } else {
    print(await File("bin/tabs"));
  }
}

void initDeviceInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  final deviceId = deviceInfo.data['deviceId']
      .toString(); // toString just to make sure since return is dynamic

  states['deviceId'] = deviceId;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  bool windowFocused = true;
  void updateOpacity() {
    setState(() {
      /*
        In order to update is I still need to set the state to update the widget
        This is just a callback sent to settings to force an update
        This might be the cause of too much being updated.
      */
    });
  }

  @override
  void initState() {
    Aptabase.instance.trackEvent("Launched");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getData().then((value) {
      g = value ?? g;

      states['dataSet'] = true;

      // Start initial states
      windowManager.setAlwaysOnTop(g['topMost'] ?? false);
    });

    return Opacity(
      // opacity: ((g["transparent"] ?? false) & !windowFocused) ? .6 : 1,

      // Can't use the windowFocused thing since it updates the entire state, thus you can't click the text / stuff breaks
      opacity: (g["transparent"] ?? false) ? .6 : 1,
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(12),
        borderRadius: BorderRadius.circular(0),
        /*
          I hate how messy the theme data is, but it's required for fluent UI
        */
        child: fluent.FluentTheme(
          data: fluent.FluentThemeData(
              activeColor: Colors.white,
              inactiveColor: Colors.white,
              resources: const fluent.ResourceDictionary.dark(
                solidBackgroundFillColorTertiary: Color(0xFF222735),
              ),
              iconTheme: const IconThemeData(color: Colors.white)),
          child: MaterialApp(
            localizationsDelegates:
                fluent.FluentLocalizations.localizationsDelegates,
            supportedLocales: fluent.FluentLocalizations.supportedLocales,
            color: Colors.transparent,
            debugShowCheckedModeBanner: false,
            title: 'Rubisco',
            theme: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF13141A)),
              primaryColor: const Color(0xFF13141A),
              scaffoldBackgroundColor: const Color(0xFF13141A),
              useMaterial3: true,
            ),
            home: MainWindow(updateOpacity: updateOpacity),
          ),
        ),
      ),
    );
  }
}

class MainWindow extends StatelessWidget {
  const MainWindow({Key? key, required this.updateOpacity}) : super(key: key);

  final Function updateOpacity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RubiscoFrame(updateOpacity: updateOpacity),
    );
  }
}

class Sidebar extends StatefulWidget {
  final void Function(int) setPage;

  const Sidebar({required this.setPage});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedPage = 0; // Set initial page to 0

  void setPage(int newPage) {
    setState(() {
      _selectedPage = newPage;
    });
    widget.setPage(
        newPage); // Call the function with the newPage parameter to navigate
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: MediaQuery.of(context).size.height - 40,
      decoration: const BoxDecoration(color: Color(0xFF13141A)),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            _buildTextButton("assets/code_editor.svg", 'Go to Code Editor', 0),
            _buildTextButton("assets/cloud.svg", 'Go to Script Search', 1),
            _buildTextButton("assets/key.svg", 'Key System', 2),
            Expanded(child: Container()),
            _buildTextButton("assets/settings.svg", 'Settings', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String asset, String semanticsLabel, int pageIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Stack(
          children: [
            Positioned(
                left: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear,
                  width: 5,
                  height: 100,
                  color: _selectedPage == pageIndex
                      ? const Color(0xFF23CAFF)
                      : const Color(0xFF13141A),
                )),
            SizedBox(
                height: 45,
                width: 55,
                child: TextButton(
                  onPressed: () {
                    setPage(pageIndex);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: SvgPicture.asset(
                      asset,
                      colorFilter: const ColorFilter.mode(
                          Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn),
                      semanticsLabel: semanticsLabel,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class DropDown extends StatefulWidget {
  const DropDown({super.key});

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
    'Item5',
    'Item6',
    'Item7',
    'Item8',
  ];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Row(
              children: [
                const SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(
                    "View",
                    style: GoogleFonts.content(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFFC8C8C8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Center(
                        child: Text(
                          item,
                          style: GoogleFonts.content(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFFC8C8C8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ))
                .toList(),
            value: selectedValue,
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
            },
            buttonStyleData: ButtonStyleData(
              height: 100,
              width: 160,
              padding: const EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF222735),
              ),
              elevation: 2,
            ),
            iconStyleData: const IconStyleData(icon: SizedBox()),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF13141A),
              ),
              offset: const Offset(-20, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all(6),
                thumbVisibility: MaterialStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class RubiscoFrame extends StatefulWidget {
  const RubiscoFrame({Key? key, required this.updateOpacity}) : super(key: key);

  final Function updateOpacity;

  @override
  State<RubiscoFrame> createState() => _RubiscoFrameState();
}

class _RubiscoFrameState extends State<RubiscoFrame> {
  final _pageController = PageController();
  int selectedPage = 0;

  void setPage(int newPage) {
    setState(() {
      selectedPage = newPage;
    });
    _pageController.jumpToPage(newPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            color: const Color(0xFF13141A),
            child: Row(
              children: [
                Expanded(
                    child: MoveWindow(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Text(
                      "RUBISCO",
                      style: GoogleFonts.istokWeb(
                        fontSize: 24,
                        color: Color.fromARGB(255, 218, 218, 218),
                      ),
                    ),
                  ),
                )),
                // Container(width: 70, height: 30, child: DropDown()),
                const WindowButtons(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Sidebar(setPage: setPage),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 50,
                      width: MediaQuery.of(context).size.width,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 89,
                            height: MediaQuery.of(context).size.height - 150,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalScripts(),
                                ExecutorWindow(),
                              ],
                            ),
                          ),
                          ScriptSearch(shadowRPC: shadowRPC),
                          const KeySystem(),
                          Settings(updateOpacity: widget.updateOpacity),
                        ],
                        onPageChanged: (page) {
                          setState(() {
                            selectedPage = page;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 45,
          child: MinimizeWindowButton(colors: buttonColors),
        ),
        SizedBox(
          height: 45,
          child: MaximizeWindowButton(colors: buttonColors),
        ),
        SizedBox(
          height: 45,
          child: CloseWindowButton(colors: closeButtonColors),
        ),
      ],
    );
  }
}

// Constants for button colors
final buttonColors = WindowButtonColors(
  iconNormal: const Color.fromARGB(255, 255, 255, 255),
);

final closeButtonColors = WindowButtonColors(
  iconNormal: const Color.fromARGB(255, 255, 255, 255),
  mouseOver: const Color.fromARGB(255, 220, 54, 54),
);

class RunButton extends StatefulWidget {
  const RunButton({Key? key}) : super(key: key);

  @override
  State<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<RunButton> {
  var currentColor = const Color.fromARGB(255, 11, 96, 214);
  var iconColor = Colors.white;
  var isAttached = false;
  var assetPath = "assets/attach.svg";

  void updateButtonState(int newState) {
    setState(() {
      // Idle: 1, Injecting: 2, Ready: 3
      if (newState == 1) {
        currentColor = const Color.fromARGB(255, 11, 96, 214);
        iconColor = Colors.white;
        isAttached = false;
        assetPath = "assets/attach.svg";
      }
      if (newState == 2) {
        currentColor = const Color.fromARGB(255, 235, 255, 54);
        iconColor = Colors.black;
        assetPath = "assets/wait.svg";
      }
      if (newState == 3) {
        isAttached = true;
        currentColor = const Color.fromARGB(255, 54, 255, 141);
        iconColor = Colors.black;
        assetPath = "assets/play_arrow.svg";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    stateChangeListen();
  }

  void stateChangeListen() async {
    while (true) {
      var isAttachedRealtime = await shadowRPC.invoke(method: "IsAttached");
      if (isAttachedRealtime != isAttached) {
        isAttached = isAttachedRealtime;
        updateButtonState(isAttachedRealtime ? 3 : 1);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void onAttach() {
    updateButtonState(3);
    isAttached = true;
    Aptabase.instance.trackEvent("Attached");
  }

  void onRunScript() {
    states["editorCallback"]();
    Aptabase.instance.trackEvent("Run Script");
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: TextButton(
          onPressed: () async {
            if (!isKeyValid()) {
              context.setPage(2); // Navigate to the KeySystem page
              return;
            }

            if (!isAttached) {
              updateButtonState(2);
            }
            shadowRPC.invoke(method: "IsAttached").then((isAttached) async {
              if (!isAttached) {
                updateButtonState(2);
                shadowRPC.invoke(method: "Attach");
                while (!await shadowRPC.invoke(method: "IsAttached")) {
                  updateButtonState(2);
                  await Future.delayed(const Duration(milliseconds: 50));
                }
                onAttach();
              } else {
                onRunScript();
              }
            });
          },
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: SvgPicture.asset(
                assetPath,
                key: ValueKey<String>(assetPath),
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                semanticsLabel: 'Run script',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension SetPageContext on BuildContext {
  Function get setPage =>
      this.findAncestorStateOfType<_RubiscoFrameState>()!.setPage;
}

class ExecutorWindow extends StatelessWidget {
  const ExecutorWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
          children: [ExecutorMain(shadowRPC: shadowRPC), const RunButton()]),
    );
  }
}
