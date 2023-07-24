import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:rubisco_one/ExecutorMain/ExecutorMain.dart';


void main() {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rubisco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primaryColor: const Color(0XFF13141A),
        scaffoldBackgroundColor: const Color(0XFF13141A),
        useMaterial3: true,
      ),
      home: const MainWindow(),
    );
  }
}

final buttonColors = WindowButtonColors(
  iconNormal: const Color.fromARGB(255, 255, 255, 255),
  // mouseOver: const Color.fromARGB(255, 37, 211, 255),
  // mouseDown: const Color.fromARGB(255, 37, 211, 255),
  // iconMouseOver: Color.fromARGB(255, 37, 211, 255),
  // iconMouseDown: Color.fromARGB(255, 37, 211, 255),
);

final closeButtonColors = WindowButtonColors(
  iconNormal: const Color.fromARGB(255, 255, 255, 255),
  mouseOver: const Color.fromARGB(255, 220, 54, 54),
  // mouseDown: Color.fromARGB(255, 159, 3, 3),
  // iconMouseOver: Color.fromARGB(255, 159, 3, 3),
);

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
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    "RUBISCO",
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                Expanded(child: MoveWindow()),
                const WindowButtons(),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            // Sidebar
            Container(
              width: 80, // SIDEBAR WIDTH
              height: MediaQuery.of(context).size.height - 50,
              decoration: const BoxDecoration(color: Color(0xFF13141A)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // Executor Window
                  width: MediaQuery.of(context).size.width - 90, // 90 = sidebar width + margin
                  height: MediaQuery.of(context).size.height - 250,
                  child: const ExecutorMain(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 90, // 90 = sidebar width + margin
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF222735),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ),
                ),
              ],
            ),

            //
          ])
        ],
      ),
    );
  }
}