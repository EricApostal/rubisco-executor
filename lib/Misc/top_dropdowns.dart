import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';

class DropDown extends StatefulWidget {
  const DropDown({Key? key, required this.name, required this.options})
      : super(key: key);

  final String name;
  final Map<String, Function> options;

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: Container(
              width: 175,
              height: 75,
              decoration: const BoxDecoration(
                  color: Color(0xFF222735),
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Center(
                  child: Text(
                widget.name,
                style: GoogleFonts.content(
                    color: Colors.white, fontWeight: FontWeight.normal, fontSize: 14),
              )),
            ),
            items: widget.options.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && widget.options.containsKey(value)) {
                widget.options[value]!();
              }
            },
            dropdownStyleData: DropdownStyleData(
              width: 160,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF222735),
              ),
              offset: const Offset(0, 8),
              openInterval: const Interval(0,0)
            ),
            menuItemStyleData: MenuItemStyleData(
              customHeights: [
                ...List<double>.filled(widget.options.length, 35),
              ],
              padding: const EdgeInsets.only(left: 16, right: 16),
            ),
          ),
        ),
      ),
    );
  }
}
