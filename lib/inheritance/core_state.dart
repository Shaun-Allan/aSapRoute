import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/user_model.dart';

class CoreState {
  final LatLng? sourceCoordinates;
  final LatLng? destCoordinates;
  final String? sourceString;
  final String? destString;
  final LatLng? yourLocationCoordinates;
  final UserModel? userModel;
  final bool? showDustbin;
  // final String? yourLocationString;

  const CoreState({
    this.sourceCoordinates,
    this.destCoordinates,
    this.sourceString,
    this.destString,
    this.yourLocationCoordinates,
    this.userModel,
    this.showDustbin = false,
    // this.yourLocationString,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoreState &&
        runtimeType == other.runtimeType &&
        sourceCoordinates == other.sourceCoordinates &&
        destCoordinates == other.destCoordinates &&
        sourceString == other.sourceString &&
        destString == other.destString &&
        yourLocationCoordinates == other.yourLocationCoordinates &&
        userModel == other.userModel &&
        showDustbin == other.showDustbin;
        // yourLocationString == other.yourLocationString;

  CoreState copy({
    LatLng? sourceCoordinates,
    LatLng? destCoordinates,
    String? sourceString,
    String? destString,
    LatLng? yourLocationCoordinates,
    UserModel? userModel,
    bool? showDustbin,
    // String? yourLocationString,
  }) =>
      CoreState(
        sourceCoordinates: sourceCoordinates ?? this.sourceCoordinates,
        destCoordinates:  destCoordinates ?? this.destCoordinates,
        sourceString: sourceString ?? this.sourceString,
        destString: destString ?? this.destString,
        yourLocationCoordinates: yourLocationCoordinates ?? this.yourLocationCoordinates,
        userModel:  userModel ?? this.userModel,
        showDustbin: showDustbin ?? this.showDustbin,
        // yourLocationString: yourLocationString ?? this.yourLocationString
      );

  @override
  int get hashCode => sourceString.hashCode ^ destCoordinates.hashCode ^
                      sourceString.hashCode ^ destString.hashCode ^
                      yourLocationCoordinates.hashCode ^ userModel.hashCode ^ showDustbin.hashCode;
                      // ^ yourLocationString.hashCode;
}