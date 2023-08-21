import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rubisco/session/globals.dart';

class HoverableContainer extends StatefulWidget {
  const HoverableContainer({super.key});

  @override
  HoverableContainerState createState() => HoverableContainerState();
}

class HoverableContainerState extends State<HoverableContainer> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isHovered,
      builder: (BuildContext context, bool isHovered, Widget? child) {
        return MouseRegion(
          onEnter: (_) => _isHovered.value = true,
          onExit: (_) => _isHovered.value = false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 75),
            curve: Curves.easeInOut,
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color:
                  isHovered ? const Color(0xFF13141A) : const Color(0xFF222735),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}

class CustomTab extends StatefulWidget {
  final bool isActive;
  final String title;
  final VoidCallback onClose;
  final String tabId;

  const CustomTab({
    required this.isActive,
    required this.title,
    required this.onClose,
    required this.tabId,
  });

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  late TextEditingController _titleController;
  bool _isEditing = false;
  String title = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(color: Color(0xff13141A), width: 2),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isActive ? const Color(0xff222735) : Color(0xFF13141A),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              _buildIcon(),
              _buildTitleOrTextField(),
              if (widget.isActive) _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Positioned(
      left: 4,
      top: 8,
      child: SizedBox(
        width: 23,
        height: 23,
        child: SvgPicture.asset(
          "assets/document.svg",
          key: const ValueKey<String>("assets/folder.svg"),
          colorFilter: ColorFilter.mode(
            widget.isActive
                ? Colors.white
                : const Color.fromARGB(255, 189, 189, 189),
            BlendMode.srcIn,
          ),
          semanticsLabel: "Script",
        ),
      ),
    );
  }

  Widget _buildTitleOrTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _isEditing ? _buildTextField() : _buildTitleText(),
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 38),
      child: TextField(
        controller: _titleController,
        style: TextStyle(
          color: widget.isActive
              ? Colors.white
              : const Color.fromARGB(255, 189, 189, 189),
          fontSize: 15,
        ),
        onSubmitted: (value) {
          setState(() {
            // Use appropriate way to get g['tabData']
            g['tabData'][widget.tabId]['name'] = value;
            title = value;
            _isEditing = false;
          });
        },
      ),
    );
  }

  Widget _buildTitleText() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: Text(
        title,
        softWrap: false,
        style: TextStyle(
          overflow: TextOverflow.fade,
          color: widget.isActive
              ? Colors.white
              : const Color.fromARGB(255, 189, 189, 189),
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      right: 0,
      top: 6,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: GestureDetector(
          onTap: widget.onClose,
          child: HoverableContainer(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
