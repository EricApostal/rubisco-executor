import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rubisco_one/ExecutorMain/ExecutorMain.dart';
import 'package:rubisco_one/ScriptSearch/ScriptSearch.dart';
import 'package:rubisco_one/Settings.dart';

void main() async {
  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(700, 400);
    const minSize = Size(550, 350);
    appWindow.minSize = minSize;
    appWindow.size = initialSize; // default size
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rubisco',
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF13141A)),
        primaryColor: const Color(0xFF13141A),
        scaffoldBackgroundColor: const Color(0xFF13141A),
        useMaterial3: true,
      ),
      home: const MainWindow(),
    );
  }
}

class MainWindow extends StatelessWidget {
  const MainWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RubiscoFrame(),
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
    widget.setPage(newPage); // Call the function with the newPage parameter to navigate
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: MediaQuery.of(context).size.height - 60,
      decoration: const BoxDecoration(color: Color(0xFF13141A)),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      padding: const EdgeInsets.only(top: 10),
      child: TextButton(
        style: const ButtonStyle(
          splashFactory: NoSplash.splashFactory,),
        onPressed: () {
          setPage(pageIndex);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: _selectedPage == pageIndex ? Color.fromARGB(255, 11, 96, 214) : const Color(0xFF222735),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              asset,
              colorFilter: const ColorFilter.mode(Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn),
              semanticsLabel: semanticsLabel,
            ),
          ),
        ),
      ),
    );
  }
}

class RubiscoFrame extends StatefulWidget {
  const RubiscoFrame({Key? key}) : super(key: key);

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
            height: 50,
            color: const Color(0xFF13141A),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    "RUBISCO",
                    style: GoogleFonts.istokWeb(
                      fontSize: 24,
                      color: const Color(0xFFA1A1A1),
                    ),
                  ),
                ),
                Expanded(child: MoveWindow()),
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
                  // Text("TODO: Text can go here, but\nit goes on other\npages too.\nOther method causes\nrenderflex error"),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 58, // Set the desired height here
                      width: MediaQuery.of(context).size.width,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExecutorWindow(),
                              Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 4),
                                child: OutputConsole(),
                              ),
                            ],
                          ),
                          ScriptSearch(),
                          Settings(),
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

class ExecutorWindow extends StatelessWidget {
  const ExecutorWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 89,
      height: MediaQuery.of(context).size.height - 200,
      child: ExecutorMain(), // Replace with your ExecutorMain widget
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
        height: 130,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: Color(0xFF222735),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "[4:20:69] Rubisco has injected!",
            style: GoogleFonts.robotoMono(color: Color(0xFFF7F7F7), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
