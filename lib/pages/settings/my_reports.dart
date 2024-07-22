import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/pages/settings/report_details.dart';
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
            ? _buildLoadingIndicator()  // Show shimmer loading indicator
            : reports.isEmpty
            ? Center(child: Text('No reports found'))
            : ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            ReportModel report = reports[index];
            return Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(child: ReportTile(report: report)),
                    ],
                  ),
                  SizedBox(height: 8,)
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
