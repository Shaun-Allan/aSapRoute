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
  final bool? makeRoute;
  final bool? clearPolyline;
  final bool calculatingOrgRoute;
  final bool calculatedOrgRoute;
  final bool calculatingAlternateRoute;
  final bool calculatedAlternateRoute;
  final bool checkingRouteHasLS;
  final bool checkedRouteHasLS;
  final bool needAlternateRoute;

  const CoreState({
    this.sourceCoordinates,
    this.destCoordinates,
    this.sourceString,
    this.destString,
    this.yourLocationCoordinates,
    this.userModel,
    this.showDustbin = false,
    this.makeRoute,
    this.clearPolyline,
    this.calculatingOrgRoute = false,
    this.calculatedOrgRoute = false,
    this.calculatingAlternateRoute = false,
    this.calculatedAlternateRoute = false,
    this.checkingRouteHasLS = true,
    this.checkedRouteHasLS = false,
    this.needAlternateRoute = false,
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
              showDustbin == other.showDustbin &&
              makeRoute == other.makeRoute &&
              clearPolyline == other.clearPolyline &&
              calculatingOrgRoute == other.calculatingOrgRoute &&
              calculatedOrgRoute == other.calculatedOrgRoute &&
              calculatingAlternateRoute == other.calculatingAlternateRoute &&
              calculatedAlternateRoute == other.calculatedAlternateRoute &&
              checkingRouteHasLS == other.checkingRouteHasLS &&
              checkedRouteHasLS == other.checkedRouteHasLS &&
              needAlternateRoute == other.needAlternateRoute;

  @override
  int get hashCode => sourceCoordinates.hashCode ^
  destCoordinates.hashCode ^
  sourceString.hashCode ^
  destString.hashCode ^
  yourLocationCoordinates.hashCode ^
  userModel.hashCode ^
  showDustbin.hashCode ^
  makeRoute.hashCode ^
  clearPolyline.hashCode ^
  calculatingOrgRoute.hashCode ^
  calculatedOrgRoute.hashCode ^
  calculatingAlternateRoute.hashCode ^
  calculatedAlternateRoute.hashCode ^
  checkingRouteHasLS.hashCode ^
  checkedRouteHasLS.hashCode ^
  needAlternateRoute.hashCode;

  CoreState copy({
    LatLng? sourceCoordinates,
    LatLng? destCoordinates,
    String? sourceString,
    String? destString,
    LatLng? yourLocationCoordinates,
    UserModel? userModel,
    bool? showDustbin,
    bool? makeRoute,
    bool? clearPolyline,
    bool? calculatingOrgRoute,
    bool? calculatedOrgRoute,
    bool? calculatingAlternateRoute,
    bool? calculatedAlternateRoute,
    bool? checkingRouteHasLS,
    bool? checkedRouteHasLS,
    bool? needAlternateRoute,
  }) =>
      CoreState(
        sourceCoordinates: sourceCoordinates ?? this.sourceCoordinates,
        destCoordinates: destCoordinates ?? this.destCoordinates,
        sourceString: sourceString ?? this.sourceString,
        destString: destString ?? this.destString,
        yourLocationCoordinates: yourLocationCoordinates ?? this.yourLocationCoordinates,
        userModel: userModel ?? this.userModel,
        showDustbin: showDustbin ?? this.showDustbin,
        makeRoute: makeRoute ?? this.makeRoute,
        clearPolyline: clearPolyline ?? this.clearPolyline,
        calculatingOrgRoute: calculatingOrgRoute ?? this.calculatingOrgRoute,
        calculatedOrgRoute: calculatedOrgRoute ?? this.calculatedOrgRoute,
        calculatingAlternateRoute: calculatingAlternateRoute ?? this.calculatingAlternateRoute,
        calculatedAlternateRoute: calculatedAlternateRoute ?? this.calculatedAlternateRoute,
        checkingRouteHasLS: checkingRouteHasLS ?? this.checkingRouteHasLS,
        checkedRouteHasLS: checkedRouteHasLS ?? this.checkedRouteHasLS,
        needAlternateRoute: needAlternateRoute ?? this.needAlternateRoute,
      );
}
