import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onPressed;
  final String? imagePath;
  final double? imageWidth;
  final double? imageHeight;
  final bool centerText;

  const SignInButton({
    Key? key,
    required this.text,
    required this.textColor,
    required this.color,
    required this.onPressed,
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.centerText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          side: color == Colors.white ? BorderSide(color: Colors.grey) : BorderSide.none,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (imagePath != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  imagePath!,
                  width: imageWidth,
                  height: imageHeight,
                ),
              ),
            Row(
              mainAxisAlignment: centerText ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                if (imagePath != null) SizedBox(width: imageWidth! + 8),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 15,
                  ),
                  textAlign: centerText ? TextAlign.center : TextAlign.start,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
