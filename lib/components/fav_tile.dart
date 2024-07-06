import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/model/fav_model.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../inheritance/data_hub.dart';

class FavoriteTile extends StatefulWidget {
  final FavoriteModel favModel;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const FavoriteTile({
    Key? key,
    required this.favModel,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  }) : super(key: key);

  @override
  State<FavoriteTile> createState() => _FavoriteTileState();
}

class _FavoriteTileState extends State<FavoriteTile> {
  void _setShowDustbin(bool showDustbin) {
    final provider = DataInheritance.of(context);
    provider?.setShowDustbin(showDustbin);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tileWidth = screenWidth / 4; // One-fourth of screen width

    return GestureDetector(
      onLongPressStart: (_) {
        widget.onLongPressStart(); // Trigger start callback
        Vibrate.feedback(FeedbackType.medium); // Feedback without expecting return
        _setShowDustbin(true);
      },
      onLongPressEnd: (_) {
        widget.onLongPressEnd(); // Trigger end callback
      },
      child: LongPressDraggable<FavoriteModel>(
        data: widget.favModel,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: tileWidth,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.favModel.title,
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  color: Color.fromARGB(200, 0, 0, 0),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.0,
          child: buildTile(context, tileWidth),
        ),
        child: buildTile(context, tileWidth),
      ),
    );
  }

  Widget buildTile(BuildContext context, double tileWidth) {
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
        onPressed: widget.onTap,
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
              widget.favModel.title,
              style: GoogleFonts.openSans(
                fontSize: 13,
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
