import 'dart:io';

import 'package:rubisco/code/executor.dart';
import 'package:rubisco/cloud/script_search.dart';
import 'package:rubisco/settings/settings.dart';
import 'package:rubisco/misc/data_store.dart';
import 'package:rubisco/misc/top_dropdowns.dart';
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
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
              colorScheme: ColorScheme.fromSeed(seedColor: colors['primary']!),
              primaryColor: colors['primary'],
              scaffoldBackgroundColor: colors['primary'],
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
      width: 60,
      height: MediaQuery.of(context).size.height - 40,
      decoration: BoxDecoration(color: colors['primary']),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _buildTextButton("assets/settings.svg", 'Settings', 3),
            ),
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
                      ? colors['selected']
                      : colors['primary'],
                )),
            SizedBox(
                height: 45,
                width: 55,
                child: TextButton(
                  style: ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent),
                  ),
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

class RubiscoFrame extends StatefulWidget {
  const RubiscoFrame({Key? key, required this.updateOpacity}) : super(key: key);

  final Function updateOpacity;

  @override
  State<RubiscoFrame> createState() => _RubiscoFrameState();
}

class _RubiscoFrameState extends State<RubiscoFrame> {
  final _pageController = PageController();
  int selectedPage = 0;
  bool explorerShown = true;

  void setPage(int newPage) {
    setState(() {
      selectedPage = newPage;
    });
    _pageController.jumpToPage(newPage);
  }

  void toggleExplorer() {
    setState(() {
      explorerShown = !explorerShown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            color: colors['primary'],
            child: Row(
              children: [
                Expanded(
                    child: MoveWindow(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 2),
                    child: Row(
                      children: [
                        Text(
                          "RUBISCO",
                          style: GoogleFonts.inriaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 30,
                              color: const Color(0xFF69C0FF)),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Text(
                          "v1.1.0",
                          style: GoogleFonts.inriaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: const Color(0xFFD3D3D3)),
                        ),
                      ],
                    ),
                  ),
                )),
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
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // if (explorerShown) LocalScripts(),
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
  var textColor = Colors.white;
  var isAttached = false;
  int injectionState = 1;
  String buttonText = "Attach";

  void updateButtonState(int newState) {
    setState(() {
      // Idle: 1, Injecting: 2, Ready: 3
      injectionState = newState;
      if (newState == 1) {
        currentColor = Colors.white;
        textColor = Colors.black;
        isAttached = false;
        buttonText = "Attach";
      }
      if (newState == 2) {
        currentColor = const Color.fromARGB(255, 235, 255, 54);
        textColor = Colors.black;
        buttonText = "Attaching";
      }
      if (newState == 3) {
        isAttached = true;
        currentColor = const Color.fromARGB(255, 54, 255, 141);
        textColor = Colors.black;
        buttonText = "Run";
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
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
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
            style: ButtonStyle(
                splashFactory: NoSplash.splashFactory,
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent)),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: (injectionState == 2)
                    ? SizedBox(
                        width: 100,
                        height: 30,
                        child: LoadingAnimationWidget.fallingDot(
                            color: colors['primary']!, size: 40))
                    : (injectionState == 1)
                        ? Text(
                            buttonText,
                            style: GoogleFonts.inriaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: textColor),
                          )
                        : SizedBox(
                          width: 100,
                          height: 300,
                          child: SvgPicture.asset(
                              "assets/play_arrow.svg",
                              colorFilter: ColorFilter.mode(
                                  colors['primary']!, BlendMode.srcIn),
                              semanticsLabel: "Run",
                            ),
                        ),
              ),
            ),
          ),
        ));
  }
}

extension SetPageContext on BuildContext {
  Function get setPage =>
      findAncestorStateOfType<_RubiscoFrameState>()!.setPage;
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  Widget _buildBottomButton(String label, Function callback) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
              color: colors['secondary'],
              borderRadius: const BorderRadius.all(Radius.circular(6))),
          child: TextButton(
            onPressed: () {
              callback();
            },
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => Colors.transparent),
            ),
            child: Text(
              label,
              style: GoogleFonts.inriaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: const Color(0xFFDFDFDF)),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Container(
          height: 40,
          width: MediaQuery.of(context).size.width - 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBottomButton("Open", () {
                print("open");
              }),
              _buildBottomButton("Save", () {
                print("save");
              }),
              Expanded(child: Container()),
              RunButton()
            ],
          )),
    );
  }
}

class ExecutorWindow extends StatelessWidget {
  const ExecutorWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height - 105,
            child: ExecutorMain(shadowRPC: shadowRPC),
          ),
          const BottomBar()
        ],
      ),
    );
  }
}
