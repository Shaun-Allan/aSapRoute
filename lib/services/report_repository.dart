import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:route/model/report_model.dart';

class ReportsRepository extends GetxController {
  static ReportsRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveReport(String userId, ReportModel report) async {
    final collectionRef = _db.collection("Reports");
    try {
      await collectionRef.add(report.toMap());
    } catch (e) {
      print("Error saving report: $e");
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }



  Future<List<ReportModel>> getReportsOnUid(String uid) async {
    final collectionRef = _db.collection("Reports");
    try {
      final snapshot = await collectionRef.where("uid", isEqualTo: uid).get();
      final reports = snapshot.docs.map((e) => ReportModel.fromSnapshot(e)).toList();
      return reports;
    } catch (e) {
      print("Error fetching reports: $e");
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }
}
