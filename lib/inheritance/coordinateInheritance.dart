// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:route/inheritance/coordinateState.dart';
//
// class SourceInheritance extends InheritedWidget {
//   final LatLng? sourceCoordinates;
//   final _CoordinateStateState stateWidget;
//   // final LatLng destCoordinates;
//   const SourceInheritance({
//     Key? key, // Key parameter should be Key? key, not super.key
//     @required Widget? child,
//     // required this.destCoordinates,
//     this.sourceCoordinates,
//   }) : super(key: key, child: child ?? const Placeholder()); // Correct usage of super constructor
//
//   // static SourceInheritance of(BuildContext context) {
//   //   final SourceInheritance? result = context.dependOnInheritedWidgetOfExactType<SourceInheritance>();
//   //   assert(result != null, 'No CoordinateInheritance found in context');
//   //   return result!;
//   // }
//
//   static LatLng? of(BuildContext context) => context
//       .dependOnInheritedWidgetOfExactType<SourceInheritance>()
//       ?.sourceCoordinates;
//
//   @override
//   bool updateShouldNotify(SourceInheritance old) {
//     return old.sourceCoordinates != sourceCoordinates;
//   }
// }
//
