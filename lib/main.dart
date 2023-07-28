import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rubisco_one/ExecutorMain/ExecutorMain.dart';
import 'package:rubisco_one/ScriptSearch/ScriptSearch.dart';

void main() async {
  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(800, 400);
    const minSize = Size(650, 350);
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
    return Scaffold(
      body: RubiscoFrame(),
    );
  }
}

class RubiscoFrame extends StatefulWidget {
  const RubiscoFrame({Key? key}) : super(key: key);

  @override
  State<RubiscoFrame> createState() => _RubiscoFrameState();
}

class _RubiscoFrameState extends State<RubiscoFrame>{
  var currentPage = 1;

  void setPage(int newPage) {
    setState(() => currentPage = newPage);
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
                      color: Color(0xFFA1A1A1),
                    ),
                  ),
                ),
                Expanded(child: MoveWindow()),
                const WindowButtons(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Sidebar(setPage: setPage),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentPage == 1) ...[
                    ExecutorWindow(),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 4),
                      child: ButtonSection(),
                    ),
                  ] else if (currentPage == 2) ...[
                    ScriptSearchWidget()
                  ],
                ],
              ),
            ],
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

class Sidebar extends StatefulWidget {
  final void Function(int) setPage;

  const Sidebar({required this.setPage});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedPage = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: MediaQuery.of(context).size.height - 50,
      decoration: const BoxDecoration(color: Color(0xFF13141A)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedPage = 1;
                });
                widget.setPage(1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _selectedPage == 1
                      ? Color.fromARGB(255, 77, 180, 232)
                      : Color(0xFF222735),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    "assets/code_editor.svg",
                    colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 255, 255, 255),
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: 'Go to Code Editor',
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedPage = 2;
                });
                widget.setPage(2);
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _selectedPage == 2
                      ? Color.fromARGB(255, 77, 180, 232)
                      : Color(0xFF222735),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    "assets/cloud.svg",
                    colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 255, 255, 255),
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: 'Go to Script Search',
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: TextButton(
              onPressed: () {},
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: const Color(0xFF222735),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset("assets/settings.svg",
                        colorFilter: const ColorFilter.mode(
                            Color.fromARGB(255, 255, 255, 255),
                            BlendMode.srcIn),
                        semanticsLabel: 'Run script')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExecutorWindow extends StatefulWidget {
  const ExecutorWindow({Key? key});

  State<ExecutorWindow> createState() => _ExecutorWindowState();

}

class _ExecutorWindowState extends State<ExecutorWindow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build(context) here.
    return Container(
        width: MediaQuery.of(context).size.width - 89,
        height: MediaQuery.of(context).size.height - 200,
        child: ExecutorMain(), // Replace with your ExecutorMain widget
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Container(
        width: MediaQuery.of(context).size.width - 90 - 32,
        height: 130,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: Color(0xFF222735),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "[4:20:69] Rubisco has injected!",
            style:
                GoogleFonts.robotoMono(color: Color(0xFFF7F7F7), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
