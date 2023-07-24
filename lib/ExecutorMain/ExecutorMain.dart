import 'dart:convert';
import 'dart:math';

import 'package:blossom_tabs/blossom_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/lua.dart';
import 'package:flutter_highlight/themes/monokai.dart';

final controller = CodeController(
  text: '', // Initial code
  language: lua,
);

class ExecutorMain extends StatelessWidget {
  const ExecutorMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tabs();
  }
}

Widget buildTab(
  BuildContext context, {
  required bool isActive,
  bool useRow = true,
  Widget? icon,
  Widget? activeIcon,
  String? title,
  TextStyle? style,
  TextStyle? activeStyle,
}) {
  var children = [
    (isActive ? activeIcon ?? icon : icon) ??
        const SizedBox(
          width: 10,
        ),
    if (title != null)
      Flexible(
        child: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: isActive ? activeStyle ?? style : style,
        ),
      ),
  ];
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: useRow
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: children),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ],
          ),
  );
}

class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  State<Tabs> createState() => _TabState();
}

class _TabState extends State<Tabs> {
  var _controller = BlossomTabController<int>(tabs: []);
  var _tabs = <BlossomTab<int>>[];

  BlossomTab<int> _getTab(String e) => BlossomTab<int>(
        id: e,
        data: int.parse(e.codeUnits.join()),
        title: e.toUpperCase(),
        isSticky: e == 'd',
      );

  @override
  void initState() {
    _tabs = ['a', 'b', 'c', 'd', 'e']
        .map(
          (e) => _getTab(e),
          //     BlossomTab.fromJson<int>(
          //   {
          //     "id": e,
          //     "data": {"value": int.parse(e.codeUnits.join())},
          //     "title": e.toUpperCase(),
          //     "isSticky": e == 'd' ? true : false,
          //     "maxWidth": 200.0,
          //     "stickyWidth": 50.0
          //   },
          //   (map) => map['value'],
          // ),
        )
        .toList();
    _controller = BlossomTabController<int>(currentTab: 'b', tabs: _tabs);
    super.initState();
  }

  var tabIndex = [];
  @override
  Widget build(BuildContext context) {
    return BlossomTabControllerScope(
      controller: _controller,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Stack(
            children: [
              BlossomTabBar<int>(
                height: 40,
                bottomBarHeight: 0,
                selectedColor: const Color(0xFF222735),
                dragColor: const Color(0xFF222735),
                stickyColor: Colors.white,
                dividerColor: const Color(0xFF13141A),
                bottomColor: const Color(0xFF222735),
                margin: const EdgeInsets.only(left: 4, top: 0, right: 140),
                tabBarMargin: 0,
                tabBuilder: (context, tab, isActive) => buildTab(
                  context,
                  isActive: isActive,
                  title: tab.id,
                  activeStyle: tab.id == 'd'
                      ? null
                      : const TextStyle(color: Colors.white),
                  /*
                          I may make D a sort of script "overview". Not completely sure yet, but seems like a cool idea.
                        */
                  icon: tab.id == 'd'
                      ? null
                      : const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.ac_unit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                  activeIcon: tab.id == 'd'
                      ? null
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.ac_unit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                ),
                tabActions: (context, tab) => [
                  if (tab.id != 'd')
                    Listener(
                      onPointerDown: (_) {
                        _controller.removeTabById(tab.id);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
                bottomBar: BlossomTabControllerScopeDescendant<int>(
                    builder: (context, controller) {
                  // Future.delayed(Duration.zero)
                  //     .then((_) => print(jsonEncode(controller.toJson())));
                  return Container(
                    color: controller.currentTab == 'd' ? Colors.white : null,
                  );
                }),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: NewTabBtn(
                      onTap: () {
                        final z = _controller.tabs.map((e) => e.id).toList()
                          ..sort();
                        var c = z.isEmpty ? 'a' : z.last;
                        final lastCharacter =
                            String.fromCharCode(c.codeUnitAt(c.length - 1) + 1);
                        c = c.substring(0, c.length - 1) + lastCharacter;
                        _controller.addTab(_getTab(c));
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        body: BlossomTabView<int>(
                builder: (tab) => CodeTheme(
                  data: CodeThemeData(styles: monokaiTheme),
                  child: SingleChildScrollView(
                    child: CodeField(
                      background: const Color(0xff13141A),
                      controller: controller,
                    ),
                  ),
                ),
            
        ),
      ),
    );
  }
}

class NewTabBtn extends StatefulWidget {
  const NewTabBtn({
    Key? key,
    required this.onTap,
  }) : super(key: key);
  final void Function() onTap;

  @override
  State<NewTabBtn> createState() => _NewTabBtnState();
}

class _NewTabBtnState extends State<NewTabBtn> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: const Icon(
          Icons.add,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ColorBox extends StatefulWidget {
  const ColorBox({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  _ColorBoxState createState() => _ColorBoxState();
}

class _ColorBoxState extends State<ColorBox> {
  Color? _color;

  _randomColor() => Color(0xFF000000 + Random().nextInt(0x00FFFFFF));

  @override
  void initState() {
    _color = _randomColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = _randomColor();
        });
      },
      child: Container(
          width: 150, height: 150, color: _color, child: widget.child),
    );
  }
}
