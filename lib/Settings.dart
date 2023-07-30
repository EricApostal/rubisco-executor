import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:google_fonts/google_fonts.dart';

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
      width: 150,
      height: MediaQuery.of(context).size.height - 63,
      // decoration: const BoxDecoration(color: Color(0xFF13141A)),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextButton("Look", 'Go to Code Editor', 0),
              _buildTextButton("Behavior", 'Go to Script Search', 1),
              // _buildTextButton("assets/settings.svg", 'Run script', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(String buttonText, String semanticsLabel, int pageIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 3, right: 3),
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
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Text(buttonText,
                style: GoogleFonts.lato(
                  color: Colors.white
                ),
                ),
              ),
            )),
      ),
    );
  }
}

class SettingsFrame extends StatefulWidget {
  const SettingsFrame({Key? key}) : super(key: key);

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
    print(newPage);
    _pageController.jumpToPage(newPage);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SettingsSidebar(setPage: setPage),
          Expanded(
              child: SizedBox(
                width: 100,
                height: 200,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Text("sfghsdhtsrthsrhrhhth",
                    style: TextStyle(
                      color: Colors.white
                    ),),
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
        ],
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Container(
          width: MediaQuery.of(context).size.width - 80,
          height: MediaQuery.of(context).size.height - 60,
          decoration: const BoxDecoration(color: Color(0xFF13141A)),
          child: Row(
            children: [
              Container(
                  width: 150,
                  decoration: const BoxDecoration(
                      color: Color(0xff222735),
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: SettingsFrame()
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Container(
                    width: 150,
                    decoration: const BoxDecoration(
                        color: Color(0xff222735),
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
