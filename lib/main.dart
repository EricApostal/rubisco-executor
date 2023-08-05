import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Rubisco/ExecutorMain/ExecutorMain.dart';
import 'package:Rubisco/ScriptSearch/ScriptSearch.dart';
import 'package:Rubisco/Settings.dart';
import 'package:Rubisco/Misc/datastore.dart';
import 'package:window_manager/window_manager.dart';
import 'package:Rubisco/globals.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:csharp_rpc/csharp_rpc.dart';

void main() async {
  initRPC();

  WidgetsFlutterBinding.ensureInitialized();
  windowManager.ensureInitialized();
  Window.initialize();

  Window.setEffect(effect: WindowEffect.transparent);

  windowManager.waitUntilReadyToShow().then((_) async {
    // await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    // await windowManager.setAsFrameless();
    // await windowManager.setHasShadow(false);
    windowManager.show();
  });

  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(700, 400);
    const minSize = Size(500, 300);
    appWindow.minSize = minSize;
    appWindow.size = initialSize; // default size
    appWindow.show();
  });
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
      */
    });
  }

  @override
  Widget build(BuildContext context) {
    getData().then((value) {
      g = value ?? g;

      // Start initial states
      windowManager.setAlwaysOnTop(g['topMost'] ?? false);
    });

    return Opacity(
      // opacity: ((g["transparent"] ?? false) & !windowFocused) ? .6 : 1,

      // Can't use the windowFocused thing since it updates the entire state, thus you can't click the text but / stuff breaks
      opacity: (g["transparent"] ?? false) ? .6 : 1,
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(12),
        borderRadius: BorderRadius.circular(0),
        child: MaterialApp(
          color: Colors.transparent,
          debugShowCheckedModeBanner: false,
          title: 'Rubisco',
          theme: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF13141A)),
            primaryColor: const Color(0xFF13141A),
            scaffoldBackgroundColor: const Color(0xFF13141A),
            useMaterial3: true,
          ),
          home: MainWindow(updateOpacity: updateOpacity),
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
      width: 50,
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
            Expanded(child: Container()),
            _buildTextButton("assets/settings.svg", 'Run script', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String asset, String semanticsLabel, int pageIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: _selectedPage == pageIndex
                  ? const Color.fromARGB(255, 11, 96, 214)
                  : const Color(0xFF222735),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                setPage(pageIndex);
              },
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: SvgPicture.asset(
                  asset,
                  colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn),
                  semanticsLabel: semanticsLabel,
                ),
              ),
            )),
      ),
    );
  }
}

class RubiscoFrame extends StatefulWidget {
  RubiscoFrame({Key? key, required this.updateOpacity}) : super(key: key);

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
                            height: MediaQuery.of(context).size.height - 200,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ExecutorWindow(),
                                // if (MediaQuery.of(context).size.height > 350)
                                //   Padding(
                                //     padding: EdgeInsets.only(
                                //         top: 8, bottom: 4, left: 16),
                                //     child: OutputConsole(),
                                //   ),
                              ],
                            ),
                          ),
                          ScriptSearch(),
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
  const RunButton({super.key});

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
      var isAttachedRealtime = await csharpRpc.invoke(method: "IsAttached");
      if (isAttachedRealtime != isAttached) {
        isAttached = isAttachedRealtime;
        updateButtonState(isAttachedRealtime ? 3 : 1);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
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
            csharpRpc.invoke(method: "IsAttached").then((isAttached) async {
              if (!isAttached) {
                updateButtonState(1);
                csharpRpc.invoke(method: "Attach");
                while (!await csharpRpc.invoke(method: "IsAttached")) {
                  updateButtonState(2);
                  await Future.delayed(const Duration(milliseconds: 50));
                }
                updateButtonState(3);
                isAttached = true;
              } else {
                updateButtonState(3);
                isAttached = true;
              }
              stateChangeListen();
              states["editorCallback"]();
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

class ExecutorWindow extends StatelessWidget {
  const ExecutorWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(children: [const ExecutorMain(), RunButton()]),
    );
  }
}

class OutputConsole extends StatelessWidget {
  const OutputConsole({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100, // height: 100,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: Color(0xFF222735),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "[4:20:69] Rubisco has injected!",
            style: GoogleFonts.robotoMono(
                color: const Color(0xFFF7F7F7), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
