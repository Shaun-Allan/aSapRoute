import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../model/report_model.dart';

class ReportDetailsPage extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white], // Set gradient to white
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationCard(report),
                const SizedBox(height: 20),
                _buildDetailsCard(report),
                const SizedBox(height: 20),
                _buildAdditionalInfo(report),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(ReportModel report) {
    return Card(
      color: Colors.white, // Ensure the background is white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Landslide Reported At",
              style: GoogleFonts.lato(
                color: Colors.grey[600],
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.redAccent,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  report.locName,
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ReportModel report) {
    return Card(
      color: Colors.white, // Ensure the background is white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Report Details",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(color: Colors.blueAccent, thickness: 1.5),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 10),
                Text(
                  DateFormat.yMMMd().format(report.timestamp.toDate()),
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 10),
                Text(
                  DateFormat.Hm().format(report.timestamp.toDate()),
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(ReportModel report) {
    return Card(
      color: Colors.white, // Ensure the background is white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Additional Information",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(color: Colors.blueAccent, thickness: 1.5),
            const SizedBox(height: 10),
            Text(
              "Cause: ${report.cause}",
              style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              "Event Description: ${report.eventDesc}",
              style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
