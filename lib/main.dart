import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:rubisco_one/ExecutorMain/ExecutorMain.dart';

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(800, 400);
    const minSize = Size(650, 350);
    // final maxSize = Size(1200, 850);
    // appWindow.maxSize = maxSize;
    appWindow.minSize = minSize;
    appWindow.size = initialSize; //default size

    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rubisco One',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      home: MainWindow(),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color.fromARGB(255, 255, 255, 255),
    mouseOver: const Color.fromARGB(255, 255, 255, 255),
    mouseDown: const Color.fromARGB(255, 255, 255, 255),
    iconMouseOver: const Color.fromARGB(255, 255, 255, 255),
    iconMouseDown: const Color.fromARGB(255, 255, 255, 255));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color.fromARGB(255, 255, 255, 255),
    mouseDown: const Color.fromARGB(255, 255, 255, 255),
    iconNormal: const Color.fromARGB(255, 255, 255, 255),
    iconMouseOver: const Color.fromARGB(255, 255, 255, 255));

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

class MainWindow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      WindowTitleBarBox(
        child: Row(
          children: [
            const Text(
              "RUBISCO",
              style: TextStyle(
                  backgroundColor: Color.fromARGB(255, 255, 253, 253),
                  fontFamily: "Lexend"),
            ),
            Expanded(child: MoveWindow()),
            const WindowButtons()
          ],
        ),
      ),
      const Expanded(
        child: ExecutorMain(),
      )
    ]));
  }
}
