import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/inheritance/coordinateState.dart';
import 'package:route/inheritance/core_state.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:route/pages/map_input.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:iconly/iconly.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route/services/compass_marker.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';


class Reroute extends StatefulWidget {
  const Reroute({super.key});

  @override
  State<Reroute> createState() => _RerouteState();
}

class _RerouteState extends State<Reroute> {
  Completer<GoogleMapController> _controller = Completer();
  final locationController = location.Location();
  List<Marker> _markers = <Marker>[];
  Map<PolylineId, Polyline> polylines = {};

  void _openInputPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 250),
        reverseTransitionDuration: Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => InputPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  int? bounded;
  int routeGenerated = 0;

  @override
  void initState() {
    super.initState();
    bounded = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) async => await fetchLocationUpdates());
  }


  void makeRoute(sourceCoordinates, destCoordinates) async{
    final coordinates = await fetchPolylinePoints(sourceCoordinates!, destCoordinates!);
    generatePolylineFromPoints(coordinates);
  }

  void adjustCameraForRoute() async{
    LatLngBounds bounds = getBoundsForPolylines(polylines.values);
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }



  @override
  Widget build(BuildContext context) {
    final destString = CoordinateInheritance.of(context)?.coreState.destString;
    final sourceString = CoordinateInheritance.of(context)?.coreState.sourceString;
    final destCoordinates = CoordinateInheritance.of(context)?.coreState.destCoordinates;
    final sourceCoordinates = CoordinateInheritance.of(context)?.coreState.sourceCoordinates;
    final yourLocationCoordinates = CoordinateInheritance.of(context)?.coreState.yourLocationCoordinates;

    if (destCoordinates != null && sourceCoordinates != null) {
      _markers = <Marker>[
        Marker(markerId: MarkerId('source'), position: sourceCoordinates, icon: BitmapDescriptor.defaultMarker),
        Marker(markerId: MarkerId('destination'), position: destCoordinates, icon: BitmapDescriptor.defaultMarker),
      ];
      makeRoute(sourceCoordinates, destCoordinates);
      if (polylines.isNotEmpty && bounded != 1) {
        adjustCameraForRoute();
        setState(() {
          bounded = 1;
        });
      }
      // _polyline = {
      //   Polyline(
      //     polylineId: PolylineId('main_route'),
      //     points: [sourceCoordinates, destCoordinates],
      //   ),
      // };
    }


    if (yourLocationCoordinates != null) {
      _markers.add(Marker(
        markerId: MarkerId('your_location'),
        position: yourLocationCoordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(255),
      ));
    }



    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: yourLocationCoordinates ?? LatLng(12.752059035456769, 80.20327134232357),
              zoom: 14,
            ),
            markers: Set<Marker>.of(_markers),
            polylines: Set<Polyline>.of(polylines.values),
            compassEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 16.5,
            left: 10,
            right: 10,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => _openInputPage(context),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'inputField',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Enter location',
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'destinationField',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          height: 45,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.location_solid, color: Colors.red),
                                SizedBox(width: 10),
                                destString != null
                                    ? Text(
                                  '$destString',
                                  style: GoogleFonts.lato(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                )
                                    : Text(
                                  'Enter destination',
                                  style: GoogleFonts.lato(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(FontAwesomeIcons.locationCrosshairs, color: Colors.black,),
        backgroundColor: Colors.white,
        onPressed: () async{
          if(yourLocationCoordinates == null) {
            await fetchLocationUpdates();
          }
          final controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(yourLocationCoordinates!, 17.5));
        },
      ),
    );
  }

  void setYourLocation(LatLng c) {
    final provider = CoordinateInheritance.of(context);
    provider?.setYourLocation(c);
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    location.PermissionStatus permissionGranted;

    // Check if service is enabled
    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        print('Location service is not enabled.');
        return;
      }
    }

    // Check for location permissions
    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == location.PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != location.PermissionStatus.granted) {
        print('Location permission is not granted.');
        return;
      }
    }

    // Get the current location
    final currentLocation = await locationController.getLocation();
    final yourLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);

    // Update the state with the current location
    setState(() {
      setYourLocation(yourLocation);
      _markers.add(Marker(
        markerId: MarkerId('your_location'),
        position: yourLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });

    // Move the camera to the current location
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(yourLocation));

    // Start listening to location changes
    locationController.onLocationChanged.listen((currentLocation) {
      final yourLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      setState(() {
        setYourLocation(yourLocation);
        _markers.add(Marker(
          markerId: MarkerId('your_location'),
          position: yourLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
      print(currentLocation.latitude);
      print(currentLocation.longitude);


    });
  }


  LatLngBounds getBoundsForPolylines(Iterable<Polyline> polylines) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (Polyline polyline in polylines) {
      for (LatLng point in polyline.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }





  Future<List<List<LatLng>>> fetchPolylinePoints(LatLng source, LatLng dest) async{
    String googleAPIKey = "AIzaSyDFRYFYWQ5Q12KnevFyxKJMgiu7Rui-mF8";
    PolylinePoints polylinePoints = PolylinePoints();
    // List<LatLng> polylineCoordinates = [];

    List<PolylineResult> result = await polylinePoints.getRouteWithAlternatives(
      googleApiKey: googleAPIKey,
      request: PolylineRequest(origin: PointLatLng(source.latitude, source.longitude),
          destination: PointLatLng(dest.latitude, dest.longitude),
          mode: TravelMode.driving,
        alternatives: true,
      )
    );

    List<List<LatLng>> finalResult = [];

    for(int i=0; i<result.length; i++) {
      if (result[i].points.isNotEmpty) {
        finalResult.add(result[i].points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList()
        );
      }
      else {
        debugPrint(result[i].errorMessage);
        continue;
      }
    }

    return finalResult;
  }



  Future<void> generatePolylineFromPoints(List<List<LatLng>> polylineCoordinates) async{
    setState(() {
      polylines.clear();
      bounded = 0;
    });
    for(int k=0; k<polylineCoordinates.length; k++){
      Polyline polyline = Polyline(
          polylineId: PolylineId('polyline' + k.toString()),
          color: Colors.blueAccent,
          points: polylineCoordinates[k],
          width: 4
      );
      setState(() => polylines[PolylineId('polyline' + k.toString())] = polyline);
    }

    for(int i=0; i<polylines.length; i++){
      print(i);
    }
  }
}
