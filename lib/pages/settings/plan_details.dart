import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanDetails extends StatelessWidget {
  final String title;
  final String monthlyPrice;
  final String yearlyPrice;
  final List<String> features;

  const PlanDetails({
    Key? key,
    required this.title,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Price: $monthlyPrice",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Yearly Price: $yearlyPrice",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Features",
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 10),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
