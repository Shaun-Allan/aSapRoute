import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:route/services/report_repository.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/report_tile.dart';
import '../../inheritance/data_hub.dart';
import '../../model/report_model.dart';

class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> {
  List<ReportModel> reports = [];
  final reportsRepo = Get.put(ReportsRepository());
  bool isLoading = true;

  void getReports(String uid) async {
    reports = await reportsRepo.getReportsOnUid(uid);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch reports when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    final uid = DataInheritance.of(context)?.coreState.userModel?.id;
    if (uid != null) {
      getReports(uid);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('User Reports', style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? _buildLoadingIndicator() // Show shimmer loading indicator
            : reports.isEmpty
            ? Center(child: Text('No reports found'))
            : ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            ReportModel report = reports[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(report.locDesc, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(report.timestamp.toDate())} at ${DateFormat.Hm().format(report.timestamp.toDate())}',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                    leading: Icon(
                      report.valid ? Icons.verified : Icons.warning,
                      color: report.valid ? Colors.green : Colors.red,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16.0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailsPage(report: report),
                        ),
                      );
                    },
                  ),
                  Divider(color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.red, size: 20.0),
                        SizedBox(width: 8.0),
                        Text(report.locName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.blue, size: 20.0),
                        SizedBox(width: 8.0),
                        Expanded(child: Text(report.eventDesc, style: GoogleFonts.poppins(fontSize: 16))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return ListView.builder(
      itemCount: 5, // Show 5 skeleton loaders
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 18),
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
            // height: 100,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            color: Colors.white,
                          ),
                          width: double.infinity,
                          height: 17,
                        ),
                        SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            color: Colors.white,
                          ),
                          width: 200,
                          height: 15,
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            color: Colors.white,
                          ),
                          width: 200,
                          height: 15,
                        ),
                        SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            color: Colors.white,
                          ),
                          width: 150,
                          height: 15,
                        ),
                        SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            color: Colors.white,
                          ),
                          width: double.infinity,
                          height: 12,
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            color: Colors.white,
                          ),
                          width: double.infinity,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReportDetailsPage extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsPage({required this.report, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details', style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              icon: Icons.description,
              iconColor: Colors.blue,
              title: 'Event Description',
              content: report.eventDesc,
            ),
            SizedBox(height: 16.0),
            _buildCard(
              icon: Icons.calendar_today,
              iconColor: Colors.grey,
              title: 'Date',
              content: DateFormat.yMMMMd().format(report.timestamp.toDate()),
            ),
            SizedBox(height: 16.0),
            _buildCard(
              icon: Icons.access_time,
              iconColor: Colors.grey,
              title: 'Time',
              content: DateFormat.Hm().format(report.timestamp.toDate()),
            ),
            SizedBox(height: 16.0),
            _buildCard(
              icon: Icons.location_pin,
              iconColor: Colors.red,
              title: 'Location Name',
              content: report.locName,
            ),
            SizedBox(height: 16.0),
            _buildCard(
              icon: Icons.place,
              iconColor: Colors.green,
              title: 'Location Description',
              content: report.locDesc,
            ),
            SizedBox(height: 16.0),
            _buildCard(
              icon: Icons.info,
              iconColor: Colors.green,
              title: 'Cause',
              content: report.cause,
            ),
            SizedBox(height: 16.0),
            _buildCard(
              icon: Icons.map,
              iconColor: Colors.purple,
              title: 'Coordinates',
              content: '${report.location.latitude}, ${report.location.longitude}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required Color iconColor, required String title, required String content}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30.0),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(content, style: GoogleFonts.poppins(fontSize: 14)),
      ),
    );
  }
}
