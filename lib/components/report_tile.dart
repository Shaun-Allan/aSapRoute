import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:route/model/report_model.dart';

import '../pages/settings/report_details.dart';

class ReportTile extends StatefulWidget {
  final ReportModel report;

  ReportTile({required this.report});

  @override
  _ReportTileState createState() => _ReportTileState();
}

class _ReportTileState extends State<ReportTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    // Format date and time
    final formattedDate = DateFormat('yyyy-MM-dd').format(report.timestamp.toDate());
    final formattedTime = DateFormat('hh:mm a').format(report.timestamp.toDate());

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
        ),
      ),
      elevation: 1.5,
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              // Handle onTap event if needed
              Navigator.push(context, _createRoute(report));
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Landslide reported at ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 3,),
                      Column(
                        children: [
                          Text(
                            report.locName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.5,),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Report date : ",
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Report time : ",
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Cause : ",
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        report.cause,
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    report.eventDesc,
                    maxLines: _isExpanded ? null : 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      color: Color.fromARGB(120, 0, 0, 0)
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Show more...",
                      style: GoogleFonts.openSans(
                        color: Color.fromARGB(100, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute(ReportModel report) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ReportDetailsPage(report: report),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
