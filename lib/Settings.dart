import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:rubisco_one/globals.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:rubisco_one/Misc/datastore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsSidebar extends StatefulWidget {
  final void Function(int) setPage;

  const SettingsSidebar({required this.setPage});

  @override
  _SettingsSidebarState createState() => _SettingsSidebarState();
}

class _SettingsSidebarState extends State<SettingsSidebar> {
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
      width: 120,
      height: MediaQuery.of(context).size.height - 63,
      // decoration: const BoxDecoration(color: Color(0xFF13141A)),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextButton("Appearance", "assets/appearance.svg",
                  'Go to Code Editor', 0),
              _buildTextButton("Behavior", "assets/appearance.svg",
                  'Go to Script Search', 1),
              // _buildTextButton("assets/settings.svg", 'Run script', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(
      String buttonText, String svgPath, String semanticsLabel, int pageIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 0, right: 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            height: 35,
            width: 200,
            decoration: BoxDecoration(
              color: _selectedPage == pageIndex
                  ? const Color.fromARGB(255, 11, 96, 214)
                  : const Color(0xFF222735),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                setPage(pageIndex);
              },
              style: ButtonStyle(splashFactory: NoSplash.splashFactory),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: SvgPicture.asset(
                        svgPath,
                        colorFilter: const ColorFilter.mode(
                            Color.fromARGB(255, 229, 229, 229),
                            BlendMode.srcIn),
                        semanticsLabel: buttonText,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      buttonText,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class SettingsCard extends StatefulWidget {
  SettingsCard(
      {super.key,
      required this.title,
      required this.tooltip,
      required this.initialState,
      required this.callback});
  final String title;
  final String tooltip;
  bool initialState;
  Function callback;

  @override
  State<SettingsCard> createState() => _SettingsCardsState();
}

class _SettingsCardsState extends State<SettingsCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xff222735),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 4, left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.start,
                      style:
                          GoogleFonts.lato(color: Colors.white, fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.tooltip,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.lato(
                            color: Color(0xffB8B3B3), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 50,
                  child: AnimatedToggleSwitch<bool>.dual(
                    current: widget.initialState,
                    first: false,
                    second: true,
                    dif: 10,
                    borderColor: Colors.transparent,
                    borderWidth: 5.0,
                    height: 25,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(66, 255, 255, 255),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 0))
                    ],
                    onChanged: (b) {
                      setState(() => widget.initialState = b);
                      // print(b);
                      widget.callback(b);
                    },
                    colorBuilder: (b) => b
                        ? const Color.fromARGB(255, 123, 255, 127)
                        : const Color.fromARGB(255, 244, 54, 114),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.updateOpacity});

  final Function updateOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            color: Color(0xff13141A),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: ListView(
          children: [
            const SizedBox(
              height: 8,
            ),
            SettingsCard(
                title: 'Top Most',
                tooltip: 'Keeps Rubisco on top of all other applications.',
                callback: (newState) {
                  saveData(g);
                  g['topMost'] = newState;
                  windowManager.setAlwaysOnTop(g['topMost'] ?? true);
                },
                initialState: g['topMost'] ?? false),
            SettingsCard(
                title: 'Transparent Window',
                tooltip: 'Makes Rubisco transparent.',
                callback: (newState) {
                  saveData(g);
                  g['transparent'] = newState;
                  updateOpacity();
                },
                initialState: g['transparent'] ?? false),
          ],
        ));
  }
}

class SettingsFrame extends StatefulWidget {
  const SettingsFrame({Key? key, required this.updateOpacity})
      : super(key: key);
  final Function updateOpacity;

  @override
  State<SettingsFrame> createState() => _SettingsFrameState();
}

class _SettingsFrameState extends State<SettingsFrame> {
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
    return Container(
      decoration: BoxDecoration(color: Color(0xFF13141A)),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SettingsSidebar(setPage: setPage),
            Container(
              width: 10,
            ),
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 65,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SettingsPage(updateOpacity: widget.updateOpacity),
                      Text("sfghsdhtsrthsrhrhhth")
                    ],
                    onPageChanged: (page) {
                      setState(() {
                        selectedPage = page;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({Key? key, required this.updateOpacity}) : super(key: key);

  final Function updateOpacity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Container(
          width: MediaQuery.of(context).size.width - 80,
          height: MediaQuery.of(context).size.height - 60,
          decoration: const BoxDecoration(color: Color(0xFF13141A)),
          child: SettingsFrame(updateOpacity: updateOpacity)),
    );
  }
}
