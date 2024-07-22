import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/report_model.dart';

class ReportDetailsPage extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details', style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
              ),
              elevation: 1.5,
              child: Container(
                // padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                height: 150,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // Handle onTap event if needed
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Landslide reported at ",
                            style: GoogleFonts.lato(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Center the row's children horizontally
                            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically center
                            children: [
                              // Spacer to push the text to the center
                              Spacer(),
                              // Icon positioned 20 pixels to the left of the text
                              Padding(
                                padding: const EdgeInsets.only(right: 10), // Space between icon and text
                                child: Icon(
                                  CupertinoIcons.location_solid,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                              Text(
                                report.locName,
                                style: GoogleFonts.openSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("sdjf"),
                Text("sdljbf"),
                Card(

                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  elevation: 1.5,
                  child: Container(
                    // padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  //   height: 10,
                  //   child: Material(
                  //     color: Colors.white,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: InkWell(
                  //       borderRadius: BorderRadius.circular(20),
                  //       onTap: () {
                  //         // Handle onTap event if needed
                  //       },
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               "Date",
                  //               style: GoogleFonts.lato(
                  //                 color: Colors.grey,
                  //                 fontSize: 13,
                  //               ),
                  //             ),
                  //             // Spacer(),
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.center, // Center the row's children horizontally
                  //               crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically center
                  //               children: [
                  //                 // Spacer to push the text to the center
                  //                 // Spacer(),
                  //                 // Icon positioned 20 pixels to the left of the text
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(right: 10), // Space between icon and text
                  //                   child: Icon(
                  //                     CupertinoIcons.location_solid,
                  //                     color: Colors.red,
                  //                     size: 40,
                  //                   ),
                  //                 ),
                  //                 Text(
                  //                   report.locName,
                  //                   style: GoogleFonts.openSans(
                  //                     fontSize: 20,
                  //                     fontWeight: FontWeight.w700,
                  //                   ),
                  //                 ),
                  //                 Spacer(),
                  //               ],
                  //             ),
                  //             // Spacer(),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  ),
                ),
              ],
            )
            //cause,
            //description
          ],
        ),
      ),
    );
  }
}
