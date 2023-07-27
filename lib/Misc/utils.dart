import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonContainer extends StatelessWidget {
  const ButtonContainer({
    Key? key,
    required this.color,
    required this.label,
    required this.onPressed,
    this.height = 40,
    this.width = 100,
  }) : super(key: key);

  final Color color;
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Railway',
              color: Color(0xFF212122),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}