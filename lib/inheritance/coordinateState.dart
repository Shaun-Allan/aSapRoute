import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route/inheritance/core_state.dart';

class CoordinateState extends StatefulWidget {
  final Widget? child;

  const CoordinateState({
    Key? key,
    @required this.child,
  }) : super(key: key);

  @override
  State<CoordinateState> createState() => _CoordinateStateState();
}

class _CoordinateStateState extends State<CoordinateState> {
  CoreState coreState = CoreState();

  void setSource(LatLng coordinate, String desc) {
    final newState = coreState.copy(
      sourceCoordinates: coordinate,
      sourceString: desc,
    );
    setState(() {
      coreState = newState;
    });
  }

  void setDestination(LatLng coordinate, String desc) {
    final newState = coreState.copy(
      destCoordinates: coordinate,
      destString: desc,
    );
    setState(() {
      coreState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CoordinateInheritance(
      child: widget.child!,
      coreState: coreState,
      stateWidget: this,
    );
  }
}

class CoordinateInheritance extends InheritedWidget {
  final CoreState? coreState;
  final _CoordinateStateState? stateWidget;

  const CoordinateInheritance({
    Key? key,
    @required Widget? child,
    @required this.coreState,
    @required this.stateWidget,
  }) : super(key: key, child: child ?? const Placeholder());

  static _CoordinateStateState? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CoordinateInheritance>()
      ?.stateWidget;

  @override
  bool updateShouldNotify(CoordinateInheritance old) {
    return old.coreState != coreState;
  }
}
