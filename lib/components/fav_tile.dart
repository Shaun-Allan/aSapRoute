import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const FavoriteTile({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tileWidth = screenWidth / 4; // One-fourth of screen width

    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide.none, // No border needed here, as it's handled by Card
          padding: EdgeInsets.zero, // Remove padding around the button
        ),
        child: Container(
          width: tileWidth,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Color.fromARGB(200, 0, 0, 0),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
