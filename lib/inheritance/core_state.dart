import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CoreState {
  final LatLng? sourceCoordinates;
  final LatLng? destCoordinates;
  final String? sourceString;
  final String? destString;

  const CoreState({
    this.sourceCoordinates,
    this.destCoordinates,
    this.sourceString,
    this.destString
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoreState &&
        runtimeType == other.runtimeType &&
        sourceCoordinates == other.sourceCoordinates &&
        destCoordinates == other.destCoordinates &&
        sourceString == other.sourceString &&
        destString == other.destString;

  CoreState copy({
    LatLng? sourceCoordinates,
    LatLng? destCoordinates,
    String? sourceString,
    String? destString,
  }) =>
      CoreState(
        sourceCoordinates: sourceCoordinates ?? this.sourceCoordinates,
        destCoordinates:  destCoordinates ?? this.destCoordinates,
        sourceString: sourceString ?? this.sourceString,
        destString: destString ?? this.destString
      );

  @override
  int get hashCode => sourceString.hashCode ^ destCoordinates.hashCode ^ sourceString.hashCode ^ destString.hashCode;
}