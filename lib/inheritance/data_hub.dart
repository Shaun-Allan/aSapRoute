import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route/inheritance/core_state.dart';

import '../model/user_model.dart';

class DataState extends StatefulWidget {
  final Widget? child;

  const DataState({
    Key? key,
    @required this.child,
  }) : super(key: key);

  @override
  State<DataState> createState() => _DataStateState();
}

class _DataStateState extends State<DataState> {
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


  void setYourLocation(LatLng coordinate) {
    final newState = coreState.copy(
      yourLocationCoordinates: coordinate,
      // yourLocationString: desc,
    );
    setState(() {
      coreState = newState;
    });
  }

  void setUserModel(UserModel userModel) {
    final newState = coreState.copy(
      userModel: userModel,
      // yourLocationString: desc,
    );
    setState(() {
      coreState = newState;
    });
  }

  void setShowDustbin(bool showDustbin) {
    final newState = coreState.copy(
      showDustbin: showDustbin,
      // yourLocationString: desc,
    );
    setState(() {
      print("inside");
      coreState = newState;
    });
    print("done");
  }


  void setMakeRoute(bool makeRoute) {
    final newState = coreState.copy(
      makeRoute: makeRoute,
      // yourLocationString: desc,
    );
    setState(() {
      print("inside");
      coreState = newState;
    });
    print("done");
  }



  void setClearPolyline(bool clearPolyline) {
    final newState = coreState.copy(
      clearPolyline: clearPolyline,
      // yourLocationString: desc,
    );
    setState(() {
      print("inside");
      coreState = newState;
    });
    print("done");
  }


  @override
  Widget build(BuildContext context) {
    return DataInheritance(
      child: widget.child!,
      coreState: coreState,
      stateWidget: this,
    );
  }
}

class DataInheritance extends InheritedWidget {
  final CoreState? coreState;
  final _DataStateState? stateWidget;

  const DataInheritance({
    Key? key,
    @required Widget? child,
    @required this.coreState,
    @required this.stateWidget,
  }) : super(key: key, child: child ?? const Placeholder());

  static _DataStateState? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DataInheritance>()
      ?.stateWidget;

  @override
  bool updateShouldNotify(DataInheritance old) {
    return old.coreState != coreState;
  }
}
