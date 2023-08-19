import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class FileItem {
  final String name;
  final bool isFolder;
  final FileSystemEntity entity;

  FileItem({required this.name, required this.isFolder, required this.entity});
}

class FolderIcon extends StatefulWidget {
  const FolderIcon(
      {Key? key, required this.fileItem, required this.onDoubleTap})
      : super(key: key);

  final FileItem fileItem;
  final VoidCallback onDoubleTap;

  @override
  State<FolderIcon> createState() => _FolderIconState();
}

class _FolderIconState extends State<FolderIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.fileItem.isFolder ? widget.onDoubleTap : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color:
                _isHovered ? const Color(0xFF222735) : const Color(0xFF13141A),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
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
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    semanticsLabel:
                        widget.fileItem.isFolder ? 'Folder' : 'Document',
                  ),
                ),
              ),
              Text(
                widget.fileItem.name,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              ),
            ],
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

  @override
  void initState() {
    super.initState();
    _initCurrentDirectory();
  }

  Future<void> _initCurrentDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      currentDirectory = directory;
      files = directory.listSync();
    });
  }

  void _updateFiles(Directory directory) {
    setState(() {
      currentDirectory = directory;
      files = directory.listSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              currentDirectory.path,
              textAlign: TextAlign.start,
              style: GoogleFonts.inter(
                  color: const Color.fromARGB(255, 198, 198, 198),
                  fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final fileEntity = files[index];
                final isFolder = fileEntity is Directory;
                return FolderIcon(
                  fileItem: FileItem(
                    name: fileEntity.uri.pathSegments.last,
                    isFolder: isFolder,
                    entity: fileEntity,
                  ),
                  onDoubleTap: () {
                    if (isFolder) {
                      _updateFiles(fileEntity as Directory);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
