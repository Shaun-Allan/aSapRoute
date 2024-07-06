import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecentsModel {
  final LatLng location;
  final String name;
  final String desc;
  GeoFirePoint? geoFirePoint;

  RecentsModel({
    required this.location,
    required this.name,
    required this.desc,
  }) {
    geoFirePoint = GeoFirePoint(GeoPoint(location.latitude, location.longitude));
  }

  factory RecentsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final geoPoint = data['geo']['geopoint'] as GeoPoint;

    return RecentsModel(
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      name: data['name'],
      desc: data['desc'],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'recentSearches': recentSearches.map((key, value) =>
  //         MapEntry(key, {
  //           'latitude': value.latitude,
  //           'longitude': value.longitude,
  //         })),
  //   };
  // }

  // factory RecentsModel.fromJson(Map<String, dynamic> json) {
  //   Map<String, LatLng> searches = {};
  //   if (json['recentSearches'] != null) {
  //     json['recentSearches'].forEach((key, value) {
  //       searches[key] = LatLng(value['latitude'], value['longitude']);
  //     });
  //   }
  //   return RecentsModel(recentSearches: searches);
  // }
}
