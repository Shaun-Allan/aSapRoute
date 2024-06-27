import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onPressed;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final bool centerText;

  const SignInButton({
    Key? key,
    required this.text,
    required this.textColor,
    required this.color,
    required this.onPressed,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    this.centerText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50, // Adjust the height as needed
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          side: color == Colors.white ? BorderSide(color: Colors.grey) : BorderSide.none,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                imagePath,
                width: imageWidth, // Use provided image width
                height: imageHeight, // Use provided image height
              ),
            ),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: textColor, // Use provided text color
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
