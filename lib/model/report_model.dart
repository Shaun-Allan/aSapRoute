import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportModel {
  final String uid;
  final LatLng location;
  final String locName;
  final String locDesc;
  final Timestamp timestamp;
  final String cause;
  final String eventDesc;
  GeoFirePoint? geoFirePoint;
  final bool valid; // New field


  ReportModel({
    required this.uid,
    required this.location,
    required this.locName,
    required this.locDesc,
    required this.timestamp,
    required this.cause,
    required this.eventDesc,
    this.valid = false,
  }) {
    geoFirePoint = GeoFirePoint(GeoPoint(location.latitude, location.longitude));
  }

  factory ReportModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final geoPoint = data['geo']['geopoint'] as GeoPoint;

    return ReportModel(
      uid: data['uid'],
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      locName: data['locName'],
      locDesc: data['locDesc'],
      cause: data['cause'],
      timestamp: data['timestamp'],
      eventDesc: data['eventDesc'],
      valid: data['valid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "geo": geoFirePoint!.data,
      "locName": locName,
      "locDesc": locDesc,
      "cause": cause,
      "eventDesc": eventDesc,
      "timestamp": timestamp,
      "valid": valid,
    };
  }
}
