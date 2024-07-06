import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavoriteModel {
  final LatLng location;
  final String locName;
  final String title;
  final String desc;
  GeoFirePoint? geoFirePoint;

  FavoriteModel({
    required this.location,
    required this.locName,
    required this.title,
    required this.desc,
  }) {
    geoFirePoint = GeoFirePoint(GeoPoint(location.latitude, location.longitude));
  }

  factory FavoriteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final geoPoint = data['geo']['geopoint'] as GeoPoint;

    return FavoriteModel(
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      title: data['title'],
      locName: data['locName'],
      desc: data['desc'],
    );
  }
}

