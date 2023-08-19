import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(home: LocalScripts()));
}

class FileItem {
  final String name;
  final bool isFolder;
  final Color color;

  FileItem({required this.name, required this.isFolder, required this.color});
}

class FolderIcon extends StatefulWidget {
  const FolderIcon({Key? key, required this.fileItem}) : super(key: key);

  final FileItem fileItem;

  @override
  State<FolderIcon> createState() => _FolderIconState();
}

class _FolderIconState extends State<FolderIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF222735) : const Color(0xFF13141A),
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
                      ColorFilter.mode(widget.fileItem.color, BlendMode.srcIn),
                  semanticsLabel:
                      widget.fileItem.isFolder ? 'Folder' : 'Document',
                ),
              ),
            ),
            Text(
              widget.fileItem.name,
              style:
                  GoogleFonts.inter(color: widget.fileItem.color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class LocalScripts extends StatelessWidget {
  const LocalScripts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Here's your mock data
    List<FileItem> files = [
      FileItem(name: "Scripts", isFolder: true, color: Color(0xFF23CAFF)),
      FileItem(name: "Workspace", isFolder: true, color: Color(0xFFFFF968)),
      FileItem(name: "AutoExec", isFolder: true, color: Color(0xFF77EF91)),
      FileItem(name: "readme.txt", isFolder: false, color: Color(0xFFD6D6D6)),
    ];

    return SizedBox(
        width: 120,
        child: Column(
          children: [
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "~/",
                textAlign: TextAlign.start,
                style: GoogleFonts.inter(
                    color: const Color.fromARGB(255, 198, 198, 198),
                    fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            ...files.map((file) => FolderIcon(fileItem: file)).toList(),
          ],
        ));
  }
}
