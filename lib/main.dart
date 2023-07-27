import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:rubisco_one/ExecutorMain/ExecutorMain.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rubisco_one/Misc/utils.dart';
import 'package:csharp_rpc/csharp_rpc.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(800, 400);
    const minSize = Size(650, 350);
    appWindow.minSize = minSize;
    appWindow.size = initialSize; //default size

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF13141A)),
        primaryColor: const Color(0xFF13141A),
        scaffoldBackgroundColor: const Color(0xFF13141A),
        useMaterial3: true,
      ),
      home: const MainWindow(),
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

class MainWindow extends StatelessWidget {
  const MainWindow({Key? key}) : super(key: key);

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Sidebar(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExecutorWindow(),
                  Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: ButtonSection(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

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
              padding: const EdgeInsets.only(top:10),
              child: TextButton(
                onPressed: () {},
                child: Container(
                    height: 55,
                    width: 55,
                    decoration:
                        BoxDecoration(color: const Color(0xFF222735),
                        borderRadius: BorderRadius.circular( 8 )
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset("assets/code_editor.svg",
                            colorFilter: const ColorFilter.mode(
                                Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn),
                            semanticsLabel: 'Run script'),
                    )
                        ),
              ),
            ), Padding(
              padding: const EdgeInsets.only(top:10),
              child: TextButton(
                onPressed: () {},
                child: Container(
                    height: 55,
                    width: 55,
                    decoration:
                        BoxDecoration(color: const Color(0xFF222735),
                        borderRadius: BorderRadius.circular( 8 )
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset("assets/cloud.svg",
                            colorFilter: const ColorFilter.mode(
                                Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn),
                            semanticsLabel: 'Run script'),
                    )
                        ),
              ),
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(bottom:10, top: 10),
              child: TextButton(
                onPressed: () {},
                child: Container(
                    height: 55,
                    width: 55,
                    decoration:
                        BoxDecoration(color: const Color(0xFF222735),
                        borderRadius: BorderRadius.circular( 8 )
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset("assets/settings.svg",
                            colorFilter: const ColorFilter.mode(
                                Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn),
                            semanticsLabel: 'Run script'),
                    )
                        ),
              ),
            ),
          ],
        ));
  }
}

class ExecutorWindow extends StatelessWidget {
  const ExecutorWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 89,
      height: MediaQuery.of(context).size.height - 200,
      child: const ExecutorMain(),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pathToCsharpExecutableFile =
        "C:/Users/Eric/source/repos/DartDLL/DartDLL/bin/Release/net7.0/DartDLL.exe";

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Container(
          width: MediaQuery.of(context).size.width - 90 - 32,
          height: 130,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: Color(0xFF222735)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("[4:20:69] Rubisco has injected!",
                style: GoogleFonts.robotoMono(
                    color: Color(0xFFF7F7F7), fontSize: 14)),
          )),
    );
  }
}
