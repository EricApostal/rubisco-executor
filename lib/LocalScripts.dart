import 'dart:io';
import 'dart:io' as io;
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'package:rubisco/ExecutorMain/ExecutorMain.dart';

const unLen = 256;

String getUsername() {
  return using<String>((arena) {
    final buffer = arena.allocate<Utf16>(sizeOf<Uint16>() * (unLen + 1));
    final bufferSize = arena.allocate<Uint32>(sizeOf<Uint32>());
    bufferSize.value = unLen + 1;
    final result = GetUserName(buffer, bufferSize);
    if (result == 0) {
      GetLastError();
      throw Exception(
          'Failed to get win32 username: error 0x${result.toRadixString(16)}');
    }
    return buffer.toDartString();
  });
}

class FileItem {
  final String name;
  final bool isFolder;
  final FileSystemEntity entity;

  FileItem({required this.name, required this.isFolder, required this.entity});
}

class SpecialFolder {
  final String name;
  final Directory path;
  final Color color;

  SpecialFolder({required this.name, required this.path, required this.color});
}

class FolderIcon extends StatefulWidget {
  const FolderIcon(
      {Key? key,
      required this.fileItem,
      required this.onDoubleTap,
      required this.iconColor,
      required this.textColor})
      : super(key: key);

  final FileItem fileItem;
  final VoidCallback onDoubleTap;
  final Color iconColor;
  final Color textColor;

  @override
  State<FolderIcon> createState() => _FolderIconState();
}

class _FolderIconState extends State<FolderIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.fileItem.isFolder
          ? widget.onDoubleTap
          : () async {
              // print("content: ");
              // print(File(widget.fileItem.entity.path).readAsStringSync());
              addTabWithContent(
                  await File(widget.fileItem.entity.path).readAsString());
            },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color:
                _isHovered ? const Color(0xFF222735) : const Color(0xFF13141A),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SizedBox(
                    width: 23,
                    height: 23,
                    child: SvgPicture.asset(
                      widget.fileItem.isFolder
                          ? "assets/folder.svg"
                          : "assets/document.svg",
                      key: const ValueKey<String>("assets/folder.svg"),
                      colorFilter:
                          ColorFilter.mode(widget.iconColor, BlendMode.srcIn),
                      semanticsLabel:
                          widget.fileItem.isFolder ? 'Folder' : 'Document',
                    ),
                  ),
                ),
                Text(
                  widget.fileItem.name,
                  style:
                      GoogleFonts.inter(color: widget.textColor, fontSize: 16),
                  overflow: TextOverflow
                      .clip, // Ensure the text doesn't visually overflow
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocalScripts extends StatefulWidget {
  @override
  _LocalScriptsState createState() => _LocalScriptsState();
}

class _LocalScriptsState extends State<LocalScripts> {
  late Directory currentDirectory;
  List<FileSystemEntity> files = [];
  final List<Directory> navigationHistory = [];
  ScrollController _scrollController = ScrollController();
  String basePath = Platform.environment['USERPROFILE'] ?? 'C:\\Users\\Default';

  final List<SpecialFolder> specialFolders = [
    SpecialFolder(
        name: 'Workspace',
        path: Directory(
            'C:\\Users\\${getUsername()}\\AppData\\Local\\Packages\\ROBLOXCORPORATION.ROBLOX_55nm5eh3cm0pr\\AC\\workspace'),
        color: const Color(0xFFFFF968)),
    SpecialFolder(
        name: 'AutoExec',
        color: const Color(0xFF77EF91),
        path: Directory(
            'C:\\Users\\${getUsername()}\\AppData\\Local\\Packages\\ROBLOXCORPORATION.ROBLOX_55nm5eh3cm0pr\\AC\\autoexec')),
    SpecialFolder(
        name: 'Scripts',
        color: const Color(0xFF37C3FF),
        path: Directory(r'scripts'))
  ];

  bool isInSpecialView = true;

  @override
  void initState() {
    super.initState();
    _initCurrentDirectory();
  }

  Future<void> _initCurrentDirectory() async {
    setState(() {
      files = specialFolders.map((f) => f.path).toList();
    });
  }

  void _updateFiles(Directory directory, {bool initialSetup = false}) {
    setState(() {
      currentDirectory = directory;
      files = directory.listSync();
      isInSpecialView = false;
      if (!initialSetup) {
        navigationHistory.add(directory);
      }
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _goBack() {
    if (navigationHistory.isEmpty || isInSpecialView) {
      setState(() {
        isInSpecialView = true;
        files = specialFolders.map((f) => f.path).toList();
      });
    } else {
      navigationHistory.removeLast();
      if (navigationHistory.isEmpty) {
        setState(() {
          isInSpecialView = true;
          files = specialFolders.map((f) => f.path).toList();
        });
      } else {
        _updateFiles(navigationHistory.last, initialSetup: true);
      }
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  double getTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  @override
  void didUpdateWidget(LocalScripts oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
        color: const Color.fromARGB(255, 198, 198, 198), fontSize: 16);

    final displayText = isInSpecialView
        ? '~'
        : '~\\${currentDirectory.path.replaceAll("C:\\Users\\${getUsername()}\\AppData\\Local\\Packages\\ROBLOXCORPORATION.ROBLOX_55nm5eh3cm0pr\\AC\\", "")}';
    final double textWidth = getTextWidth(displayText, style);
    final double maxWidth = MediaQuery.of(context)
        .size
        .width; // Get the screen width or adjust as required
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back), onPressed: _goBack),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: textWidth > maxWidth
                                ? maxWidth - textWidth
                                : 0),
                        child: Text(
                          displayText,
                          textAlign: TextAlign.left, // Set to left
                          style: style,
                          softWrap: false,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final fileEntity = files[index];
                    final isFolder = fileEntity is Directory;

                    String displayName = isInSpecialView
                        ? specialFolders[index].name
                        : path.basename(fileEntity.path);

                    return FolderIcon(
                      fileItem: FileItem(
                        name: displayName,
                        isFolder: isFolder,
                        entity: fileEntity,
                      ),
                      textColor: isInSpecialView
                          ? specialFolders[index].color
                          : Colors.white,
                      iconColor: isInSpecialView
                          ? specialFolders[index].color
                          : isFolder
                              ? const Color(0xFFFFF968)
                              : const Color.fromARGB(255, 30, 128, 248),
                      onDoubleTap: () {
                        if (isInSpecialView) {
                          _updateFiles(specialFolders[index].path);
                        } else if (isFolder) {
                          _updateFiles(fileEntity as Directory);
                        } else {}
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFF222735)),
        )
      ],
    );
  }
}
