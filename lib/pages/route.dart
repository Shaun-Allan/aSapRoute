import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/inheritance/data_hub.dart';
import 'package:route/inheritance/core_state.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:route/pages/map_input.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:iconly/iconly.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route/services/compass_marker.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:http/http.dart' as http;


class Reroute extends StatefulWidget {
  const Reroute({super.key});

  @override
  State<Reroute> createState() => _RerouteState();
}

class _RerouteState extends State<Reroute> {
  Completer<GoogleMapController> _controller = Completer();
  final locationController = location.Location();
  List<Marker> _markers = <Marker>[];
  // Map<PolylineId, Polyline> polylines = {};
  Set<Polyline> polylines = {};

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
  int pid = 0;
  LatLng? sCo;
  LatLng? dCo;
  bool altGenerated = false;
  bool clearPolylineBool = false;
  Set<Polyline>? polylinesg;

  @override
  void initState() {
    super.initState();
    bounded = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) async => await fetchLocationUpdates());
  }


  void setClearPolyline(bool clearPolyline) async{
    final provider = DataInheritance.of(context);

    provider?.setClearPolyline(clearPolyline);
  }


  Future<void> makeRoute(sourceCoordinates, destCoordinates) async{
    setState(() {
      altGenerated = false;
    });
    final coordinates = await fetchPolylinePoints(sourceCoordinates!, destCoordinates!);
    await generatePolylineFromPoints(coordinates);
    // await generateRouteWithAvoidance(sourceCoordinates, destCoordinates);
  }


  void adjustCameraForRoute() async{
    LatLngBounds bounds = getBoundsForPolylines(polylines);
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Set<TileOverlay> _tileOverlays = {};

  void _addTileOverlay() {
    final TileOverlay tileOverlay = TileOverlay(
      tileOverlayId: TileOverlayId('tile_overlay_id'),
      tileProvider: UrlTileProvider(
        256,
        256,
            (x, y, zoom) {
          // Replace with your tile server URL pattern
          zoom = zoom;
          return 'http://192.168.1.13:8080/'+zoom.toString()+'/'+x.toString()+'/'+y.toString()+'.png';
        },
      ),
    );





    setState(() {
      _tileOverlays.add(tileOverlay);
    });
  }

  List<List<dynamic>>? _geotiffData;

  void setMakeRoute(bool makeRoute) async{
    final provider = DataInheritance.of(context);

    provider?.setMakeRoute(makeRoute);
  }


  void setAndAdjustRoute(LatLng sourceCoordinates, LatLng destCoordinates) async{
    await makeRoute(sourceCoordinates, destCoordinates);
    adjustCameraForRoute();
    // setMakeRoute(false);
  }

  final double pixelWidth = 43200;
  final double pixelHeight = 14400;

  List<LatLng>? boundaryPointsg = [];



  @override
  Widget build(BuildContext context) {
    final destString = DataInheritance.of(context)?.coreState.destString;
    final sourceString = DataInheritance.of(context)?.coreState.sourceString;
    final destCoordinates = DataInheritance.of(context)?.coreState.destCoordinates;
    final sourceCoordinates = DataInheritance.of(context)?.coreState.sourceCoordinates;
    final yourLocationCoordinates = DataInheritance.of(context)?.coreState.yourLocationCoordinates;
    final makeRouteBool = DataInheritance.of(context)?.coreState.makeRoute;
    final clearPolylineB = DataInheritance.of(context)?.coreState.clearPolyline;

    print("asdjbjjhmcclear");
    print(clearPolylineB);

    setState(() {
      // clearPolylineBool = clearPolylineB!;
    });

    if (destCoordinates != null && sourceCoordinates != null) {
      setState(() {
        sCo = sourceCoordinates;
        dCo = destCoordinates;
      });
      _markers = <Marker>[
        Marker(markerId: MarkerId('source'), position: sourceCoordinates, icon: BitmapDescriptor.defaultMarker),
        Marker(markerId: MarkerId('destination'), position: destCoordinates, icon: BitmapDescriptor.defaultMarker),
      ];

      if(makeRouteBool ?? false) {
        setAndAdjustRoute(sourceCoordinates, destCoordinates);
        setMakeRoute(false);
      }
      if (polylines.isNotEmpty && bounded != 1) {
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

    if(boundaryPointsg != null){
      int j = 1;
      for(var m in boundaryPointsg!){
        setState(() {
          _markers.add(
            Marker(markerId: MarkerId(j.toString()), position: m, icon: BitmapDescriptor.defaultMarkerWithHue(255)),
          );
          j++;
        });
      }
    }

    // if(polylinesg != null){
    //   for(var m in polylinesg!){
    //     setState(() {
    //       polylines.add(m);
    //     });
    //   }
    // }



    // if (yourLocationCoordinates != null) {
    //   _markers.add(Marker(
    //     markerId: MarkerId('your_location'),
    //     position: yourLocationCoordinates,
    //     icon: BitmapDescriptor.defaultMarkerWithHue(255),
    //   ));
    // }

    _addTileOverlay();
    print("hello");
    print("hello");





    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: yourLocationCoordinates ?? LatLng(12.752059035456769, 80.20327134232357),
              zoom: 16,
            ),
            markers: Set<Marker>.of(_markers),
            polylines: polylines,
            compassEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            tileOverlays: _tileOverlays,
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
          // _fetchGeoTIFFData();
          print("asdjbjjhmcclear");
          print(clearPolylineB);
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
    final provider = DataInheritance.of(context);
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
    });


    // Move the camera to the current location
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(yourLocation));

    // Start listening to location changes
    locationController.onLocationChanged.listen((currentLocation) {
      final yourLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      setState(() {
        setYourLocation(yourLocation);
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
      southwest: LatLng(minLat - 0.6, minLng- 0.6),
      northeast: LatLng(maxLat + 0.6, maxLng + 0.6),
    );
  }

  LatLngBounds getBounds(Iterable<Polyline> polylines) {
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
    String googleAPIKey = "AIzaSyCYHi0alROcEdEIV97imNAvkSKUEMvI4dA";
    PolylinePoints polylinePoints = PolylinePoints();
    // List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleAPIKey,
        request: PolylineRequest(origin: PointLatLng(source.latitude, source.longitude),
          destination: PointLatLng(dest.latitude, dest.longitude),
          mode: TravelMode.driving,
          // alternatives: true,
        )
    );

    List<List<LatLng>> finalResult = [];

    // for(int i=0; i<result.length; i++) {
    if (result.points.isNotEmpty) {
      finalResult.add(result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList()
      );
    }
    //   else {
    //     debugPrint(result[i].errorMessage);
    //     continue;
    //   }
    // }


    return finalResult;
  }

  Future<void> _fetchGeoTIFFData(int start_x, int start_y, int width, int height) async {
    print('geotiff');
    print(start_x);
    print(start_y);
    print(width);
    print(height);
    final response = await http.get(Uri.parse('https://optimal-harbor-429914-j2.el.r.appspot.com/geotiff-data?start_x=$start_x&start_y=$start_y&width=$width&height=$height'));

    if (response.statusCode == 200) {
      // _geotiffData = List<List<dynamic>>.from(json.decode(response.body));
      _geotiffData = List<List<dynamic>>.from(json.decode(response.body))
          .map((list) => list.map((e) => e?.toDouble()).toList())
          .toList();
      print(_geotiffData);

      print(_geotiffData!.length);
      print(_geotiffData![0].length);
      print('Data Type: ${_geotiffData.runtimeType}');
      setState(() {
        // _geotiffData = data;
      });
    } else {
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Failed to load data');
      throw Exception('Failed to load GeoTIFF data');
    }
  }





  Future<void> generatePolylineFromPoints(List<List<LatLng>> polylineCoordinates) async{
    if(clearPolylineBool || true) {
      setState(() {
        polylines.clear();
        bounded = 0;
      });
    }


    setClearPolyline(false);

    Map<PolylineId, Polyline> polylinesDummy = {};

    for(int k=0; k<polylineCoordinates.length; k++){
      Polyline polyline = Polyline(
          polylineId: PolylineId('polyline' + k.toString()),
          color: Colors.blueAccent,
          points: polylineCoordinates[k],
          width: 4
      );
      print('pid');
      print(pid);
      print(polylines.length);
      setState(() => polylinesDummy[PolylineId('polyline' + pid.toString())] = polyline);
      setState(() {
        pid++;
      });

    }

    LatLngBounds boundf = getBounds(polylinesDummy.values);
    Set<Polyline> pol = {};
    for(int i=0; i<polylines.length; i++){
      pol.add(polylines.elementAt(i));
    }
    // setState(() {
    //   polylines = pol;
    // });
    for(int i=0; i<polylinesDummy.length; i++){
      pol.add(polylinesDummy.values.elementAt(i));
    }


    setState(() {
      // for(int i=0; i<polylinesDummy.length; i++){
      //   polylindes[polylinesDummy[i]!.polylineId] = polylinesDummy[i]!;
      // }
      polylines = polylinesDummy.values.toSet();
    });

    LatLngBounds bounds_ = getBoundsForPolylines(polylinesDummy.values);
    LatLng northwest = LatLng(bounds_.northeast.latitude, bounds_.southwest.longitude);
    print(northwest);
    LatLng southeast = LatLng(bounds_.southwest.latitude, bounds_.northeast.longitude);
    print(southeast);
    int northwestY = _getGeoTIFFIndex(northwest.latitude, true);
    int northwestX = _getGeoTIFFIndex(northwest.longitude, false);
    int southeastY = _getGeoTIFFIndex(southeast.latitude, true);
    int southeastX = _getGeoTIFFIndex(southeast.longitude, false);
    int width = southeastX - northwestX;
    int height = -(northwestY - southeastY);

    print('Northwest corner indices: x=$northwestX, y=$northwestY');
    print('Southeast corner indices: x=$southeastX, y=$southeastY');
    print(width);
    print(height);





    for(int i=0; i<polylines.length; i++){
      print(i);
    }










    await _fetchGeoTIFFData(northwestX, northwestY, width, height);
    //
    //
    //
    print('\n\n\n\n\n\n\n\n\nkjbdkbfdsfsvfskfdsfkjbfjkvb');
    print(polylinesDummy.length);
    for(int i=0; i<polylinesDummy.length; i++){
      if(checkGeoTIFFValues(polylineCoordinates[i], northwestX, northwestY) && !altGenerated){
        setState(() {
          altGenerated = true;
        });
        print("yes");
        await generateRouteWithAvoidance(sCo!, dCo!, northwestX, northwestY, polylineCoordinates, boundf);
        print("generated");
      }
      else{
        print("no");
      }
    }

    // setState(() {
    //   polylines.addAll(polylinesDummy);
    // });
  }


  Future<List<LatLng>> generateWaypoints(List<LatLng> boundaryPoints, LatLng source, LatLng destination) async {
    List<Point> points = boundaryPoints.map((latlng) => Point(latlng.latitude, latlng.longitude)).toList();
    List<Point> hullPoints = convexHull(points);
    // List<Point> hullPoints = points;

    // Split hull points into two halves
    List<Point> half1 = [];
    List<Point> half2 = [];
    int splitIndex = hullPoints.length ~/ 2;

    for (int i = 0; i < hullPoints.length; i++) {
      if (i <= splitIndex) {
        half1.add(hullPoints[i]);
      } else {
        half2.add(hullPoints[i]);
      }
    }

    // Determine which half is closer to the line connecting source and destination
    double distanceToHalf1 = _totalDistanceToHalf(half1, source, destination);
    double distanceToHalf2 = _totalDistanceToHalf(half2, source, destination);

    List<Point> selectedHalf = distanceToHalf1 < distanceToHalf2 ? half1 : half2;

    // Convert selected half points back to LatLng
    List<LatLng> waypoints = selectedHalf.map((point) => LatLng(point.latitude, point.longitude)).toList();

    return waypoints;
  }

  double _totalDistanceToHalf(List<Point> half, LatLng source, LatLng destination) {
    // Compute total distance from source to each point in the half and then to destination
    double totalDistance = 0;
    LatLng prevPoint = source;

    for (Point point in half) {
      LatLng latLngPoint = LatLng(point.latitude, point.longitude);
      totalDistance += _distanceBetween(prevPoint, latLngPoint);
      prevPoint = latLngPoint;
    }

    totalDistance += _distanceBetween(prevPoint, destination);
    return totalDistance;
  }

  double _distanceBetween(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    double dLat = _degToRad(point2.latitude - point1.latitude);
    double dLng = _degToRad(point2.longitude - point1.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(point1.latitude)) * cos(_degToRad(point2.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degToRad(double degree) {
    return degree * (pi / 180);
  }



  Future<List<List<LatLng>>> fetchPolylinePointsWithWaypoints(LatLng source, LatLng dest, List<LatLng> waypoints) async {
    PolylinePoints polylinePoints = PolylinePoints();
    // waypoints = [LatLng(13.090280396661807, 80.1698543158802), LatLng(12.87920260782961, 79.74373128272246), LatLng(13.402502834604292, 79.66507824920056)];
    List<LatLng> fullRoute = [source, ...waypoints, dest];
    print(fullRoute);

      // _markers.add(Marker(markerId: MarkerId("123"), position: LatLng(0,0), icon: BitmapDescriptor.defaultMarker));
    // setState(() {
    //   for (int i = 0; i < waypoints.length; i++) {
    //     _markers.add(Marker(
    //       markerId: MarkerId('waypoint_$i'),
    //       position: waypoints[i],
    //         icon: BitmapDescriptor.defaultMarker
    //     ));
    //   }
    // });

    print(waypoints.length);
    print(_markers.length);


    print("markers added");

    // _markers.add(Marker(
    //   markerId: MarkerId('dest'),
    //   position: dest,
    //   infoWindow: InfoWindow(title: 'Destination'),
    // ));
    String googleAPIKey = "AIzaSyCYHi0alROcEdEIV97imNAvkSKUEMvI4dA";

    List<List<LatLng>> polylineCoordinates = [];
    for (int i = 0; i < fullRoute.length - 1; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleAPIKey,
        request: PolylineRequest(
          origin: PointLatLng(fullRoute[i].latitude, fullRoute[i].longitude),
          destination: PointLatLng(fullRoute[i + 1].latitude, fullRoute[i + 1].longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.add(result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList()
        );
      }
    }

    return polylineCoordinates;
  }

  List<LatLng> fetchBoundaryPoints(List<List<dynamic>> geotiffData, int pixelWidth, int pixelHeight, int res_x, int res_y, LatLngBounds routeBounds, List<List<LatLng>> pc) {
    List<LatLng> boundaryPoints = [];

    if (geotiffData.isNotEmpty) {
      List<List<bool>> visited = List.generate(geotiffData.length, (i) => List.generate(geotiffData[i].length, (j) => false));
      Set<LatLng> boundarySet = {};



      for (int y_ = 0; y_ < geotiffData.length; y_++) {
        for (int x_ = 0; x_ < geotiffData[y_].length; x_++) {
          double lat = _getLatitude(y_ + res_y, pixelHeight.toInt());
          double lng = _getLongitude(x_ + res_x, pixelWidth.toInt());
          double value = geotiffData[y_][x_] ?? 0.0;
          // for(var p in pc){
          //   if(!pc.contains(LatLng(lat, lng))){
          //     continue;
          //   }
          // }

          if (value > 0.3 && !visited[y_][x_]) {
            List<LatLng> clusterPoints = _floodFill(geotiffData, max(x_, 0), max(y_, 0), _geotiffData![0].length, _geotiffData!.length, 0.3, visited, res_x, res_y, pc, pixelHeight, pixelWidth);

            print('cluster');
            print(clusterPoints);
            setState(() {
              // if(boundaryPointsg == null){
              //   boundaryPointsg = clusterPoints;
              // }
              // else {
              //   boundaryPointsg!.addAll(clusterPoints);
              // }
            });
            print(clusterPoints.length);

            // Filter cluster points by route bounds
            // List<LatLng> filteredPoints = clusterPoints.where((point) => routeBounds.contains(point)).toList();

            if (clusterPoints.isNotEmpty) {
              // Compute convex hull for the filtered points
              Set<LatLng> clusterBoundary = _computeConvexHullSet(clusterPoints);
              boundarySet.addAll(clusterBoundary);
            }
          }
        }
      }

      boundaryPoints = boundarySet.toList();
    }

    boundaryPoints.sort((a, b) => b.longitude.compareTo(a.longitude));

// Get the top 3 points most to the east
    List<LatLng> top3EasternPoints = boundaryPoints.take(3).toList();
    boundaryPoints = top3EasternPoints;

    // Print boundary points for debugging
    print("Boundary Points:");
    boundaryPoints.forEach((point) => print("(${point.latitude}, ${point.longitude})"));
    setState(() {
      boundaryPointsg = boundaryPoints;
    });

    return boundaryPoints;
  }

  List<LatLng> _floodFill(List<List<dynamic>> data, int x, int y, int pixelWidth, int pixelHeight, double threshold, List<List<bool>> visited, int res_x, int res_y, List<List<LatLng>> pc, int pH, int pW) {
        List<List<double>> cluster = List.generate(data.length, (i) => List.generate(data[i].length, (j) => 0));
        List<LatLng> points = [];

        // double lat = _getLatitude(cy, pixelHeight);
        // double lng = _getLongitude(cx, pixelWidth);
        // points.add(LatLng(lat, lng));

        List<List<int>> directions = [
          [-1, 0], [1, 0], [0, -1], [0, 1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ];

        void dfs(List<List<double>> cluster, List<List<dynamic>> data, int x, int y, int pixelHeight, int pixelWidth, double threshold, List<List<bool>> visited){
          x = max(x, 0);
          y = max(y, 0);
          print("valus;");
          print(x);
          print(y);
          print(pixelWidth);
          print(pixelHeight);
          // print(data[y][x]);
          // print(visited[y][x]);
          // print(x<0);
          // print(x>=pixelWidth);
          // print(y<0);
          // print(y>=pixelHeight);
          // print(val <= threshold);
          // print(visited[y][x]);
          double val = 0;
          if(x >= 0 && x < pixelWidth && y >= 0 && y < pixelHeight){
            if(data[y][x] != null) {
              val = data[y][x];
            }
          }
          // double val = data[y][x] == null ? 0 : data[y][x];
          print(x < 0 || x >= pixelWidth || y < 0 || y >= pixelHeight || val <= threshold || visited[y][x]);
          double lat = _getLatitude(y + res_y, pH.toInt());
          double lng = _getLongitude(x + res_x, pW.toInt());
          print("hello");
          print(lat);
          print(sCo!.latitude);
          print(lat < sCo!.latitude);
          print(lat > dCo!.latitude);
          // if(lat < sCo!.latitude || lat > dCo!.latitude){
          //   visited[y][x] = true;
          //   return;
          // }
          if((sCo!.longitude - dCo!.longitude).abs() < (sCo!.latitude - dCo!.latitude).abs()){
            if(sCo!.latitude < dCo!.latitude){
              if(lat < sCo!.latitude || lat > dCo!.latitude){
                visited[y][x] = true;
                return;
              }
            }
            else{
              if(lat > sCo!.latitude || lat < dCo!.latitude){
                visited[y][x] = true;
                return;
              }
            }
          }
          else{
            if(sCo!.longitude < dCo!.longitude){
              if(lng < sCo!.longitude || lat > dCo!.longitude){
                visited[y][x] = true;
                return;
              }
            }
            else{
              if(lng > sCo!.longitude || lat < dCo!.longitude){
                visited[y][x] = true;
                return;
              }
            }
          }
          if(x < 0 || x >= pixelWidth || y < 0 || y >= pixelHeight || val <= threshold || visited[y][x]){
            return;
          }
          else{
            final double pixelW = 43200;
            final double pixelH = 14400;
            double lat = _getLatitude(y + res_y, pixelH.toInt());
            double lng = _getLongitude(x + res_x, pixelW.toInt());
            points.add(LatLng(lat, lng));
            print(points);
            cluster[y][x] = data[y][x];
            visited[y][x] = true;
            for(var d in directions){
              dfs(cluster, data, x+d[0], y+d[1], pixelHeight, pixelWidth, threshold, visited);
            }
          }
        }

        dfs(cluster, data, x, y, pixelHeight, pixelWidth, threshold, visited);


        print('reutrn');
        print(points);
    return points;




  }

  // List<LatLng> _floodFill(List<List<dynamic>> data, int x, int y, int pixelWidth, int pixelHeight, double threshold, List<List<bool>> visited) {
  //   Queue<List<int>> queue = Queue();
  //   queue.add([x, y]);
  //   List<LatLng> points = [];
  //
  //   while (queue.isNotEmpty) {
  //     var current = queue.removeFirst();
  //     int cx = current[0];
  //     int cy = current[1];
  //
  //     if (cx < 0 || cy < 0 || cx >= pixelWidth || cy >= pixelHeight || visited[cy][cx] || data[cy][cx] == null || data[cy][cx] <= threshold) {
  //       continue;
  //     }
  //
  //     visited[cy][cx] = true;
  //
  //     double lat = _getLatitude(cy, pixelHeight);
  //     double lng = _getLongitude(cx, pixelWidth);
  //     points.add(LatLng(lat, lng));
  //
  //     List<List<int>> directions = [
  //       [-1, 0], [1, 0], [0, -1], [0, 1],
  //       [-1, -1], [-1, 1], [1, -1], [1, 1]
  //     ];
  //
  //     for (var dir in directions) {
  //       int nx = cx + dir[0];
  //       int ny = cy + dir[1];
  //       queue.add([nx, ny]);
  //
  //     }
  //   }
  //
  //   return points;
  // }


  double _getLatitude(int y, int pixelHeight) {
    return 60 - (120 * y / (pixelHeight - 1));
  }

  double _getLongitude(int x, int pixelWidth) {
    return x / (pixelWidth - 1) * 360 - 180;
  }

  Set<LatLng> _computeConvexHullSet(List<LatLng> points) {
    if (points.length <= 1) return points.toSet();

    points.sort((a, b) => a.latitude.compareTo(b.latitude) == 0 ? a.longitude.compareTo(b.longitude) : a.latitude.compareTo(b.latitude));

    List<LatLng> lower = [];
    for (var p in points) {
      while (lower.length >= 2 && _crossProduct(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    List<LatLng> upper = [];
    for (var p in points.reversed) {
      while (upper.length >= 2 && _crossProduct(upper[upper.length - 2], upper.last, p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    lower.removeLast();
    upper.removeLast();

    return Set.from(lower)..addAll(upper);
  }


  List<LatLng> _computeConvexHull(List<LatLng> points) {
    // Andrew's monotone chain algorithm to compute convex hull
    if (points.length <= 1) return points;

    // Sort the points lexicographically (by x, then by y)
    points.sort((a, b) {
      int compare = a.longitude.compareTo(b.longitude);
      if (compare == 0) return a.latitude.compareTo(b.latitude);
      return compare;
    });

    // Build the lower hull
    List<LatLng> lower = [];
    for (var p in points) {
      while (lower.length >= 2 && _crossProduct(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    // Build the upper hull
    List<LatLng> upper = [];
    for (var p in points.reversed) {
      while (upper.length >= 2 && _crossProduct(upper[upper.length - 2], upper.last, p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    // Remove the last point of each half because it's repeated at the beginning of the other half
    lower.removeLast();
    upper.removeLast();

    return lower..addAll(upper);
  }

  double _crossProduct(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }

  Future<void> generateRouteWithAvoidance(LatLng source, LatLng dest, int res_x, res_y, List<List<LatLng>> pc, LatLngBounds boundf) async {
    // List<List<dynamic>> relevantClusterData = _identifyRelevantCluster(pc, res_x, res_y);

    List<LatLng> boundaryPoints = await fetchBoundaryPoints(_geotiffData!, pixelWidth.toInt(), pixelHeight.toInt(), res_x, res_y, boundf, pc);
    print('boundar');
    print(boundaryPoints);
    List<LatLng> waypoints = await generateWaypoints(boundaryPoints, dest, source);
    // List<LatLng> waypoints = boundaryPoints;
    print('waypoints');
    print(waypoints);

    List<List<LatLng>> polylineCoordinates = await fetchPolylinePointsWithWaypoints(source, dest, waypoints);
    print('polyline Coordinates');
    print(polylineCoordinates);
    await generatePolylineFromPoints(polylineCoordinates);
  }




  bool checkGeoTIFFValues(List<LatLng> polylineCoordinates, int nwx, int sey) {
    print(polylineCoordinates.length);
    for (LatLng point in polylineCoordinates) {
      int y = max(_getGeoTIFFIndex(point.latitude, true) - sey - 1, 0) ;
      int x = max(_getGeoTIFFIndex(point.longitude, false) - nwx - 1, 0);
      // print(_geotiffData);
      print("x = $x");
      print(_getGeoTIFFIndex(point.longitude, false));
      print(nwx);
      // print(_geotiffData!.length);
      print("y = $y");
      print(_getGeoTIFFIndex(point.latitude, true));
      print(sey);
      // print(_geotiffData![0].length);
      if ((x >= 0 && x < pixelWidth && y >= 0 && y < pixelHeight) || true ) {
        if(_geotiffData![y][x] != null){
          if(_geotiffData![y][x] > 0.3){
            return true;
          }
        }
      }
    }
    return false;
  }

  int _getGeoTIFFIndex(double coordinate, bool isLatitude) {
    if (isLatitude) {
      // Convert latitude to index
      double lat = ((60 - coordinate) / 120) * (pixelHeight - 1);
      return lat.toInt().clamp(0, pixelHeight.toInt() - 1);
    } else {
      // Convert longitude to index
      double lng = ((coordinate + 180) / 360) * (pixelWidth - 1);
      return lng.toInt().clamp(0, pixelWidth.toInt() - 1);
    }
  }












  List<Point> convexHull(List<Point> points) {
    // Sort points lexicographically (by latitude, then by longitude)
    points.sort((a, b) {
      if (a.latitude != b.latitude) {
        return a.latitude.compareTo(b.latitude);
      } else {
        return a.longitude.compareTo(b.longitude);
      }
    });

    // Build the lower hull
    List<Point> lower = [];
    for (Point p in points) {
      while (lower.length >= 2 && _cross(lower[lower.length - 2], lower[lower.length - 1], p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    // Build the upper hull
    List<Point> upper = [];
    for (int i = points.length - 1; i >= 0; i--) {
      Point p = points[i];
      while (upper.length >= 2 && _cross(upper[upper.length - 2], upper[upper.length - 1], p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    // Remove the last point of each half because it is repeated at the beginning of the other half
    lower.removeLast();
    upper.removeLast();

    // Combine lower and upper hull to make the convex hull
    return lower + upper;
  }


  double _cross(Point o, Point a, Point b) {
    return (a.latitude - o.latitude) * (b.longitude - o.longitude) - (a.longitude - o.longitude) * (b.latitude - o.latitude);
  }

  List<Point> halfConvexHull(List<Point> points) {
    // Sort points lexicographically (by latitude, then by longitude)
    points.sort((a, b) {
      if (a.latitude != b.latitude) {
        return a.latitude.compareTo(b.latitude);
      } else {
        return a.longitude.compareTo(b.longitude);
      }
    });

    // Choose to build either the lower or upper hull
    bool buildLowerHull = true; // Change this to false if you want to build the upper hull

    List<Point> hull = [];
    if (buildLowerHull) {
      // Build the lower hull
      for (Point p in points) {
        while (hull.length >= 2 && _cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
          hull.removeLast();
        }
        hull.add(p);
      }
    } else {
      // Build the upper hull
      for (int i = points.length - 1; i >= 0; i--) {
        Point p = points[i];
        while (hull.length >= 2 && _cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
          hull.removeLast();
        }
        hull.add(p);
      }
    }

    return hull;
  }

  List<List<dynamic>> _identifyRelevantCluster(List<List<LatLng>> polylineCoordinates, int nwx, int sey) {
    // Initialize a matrix to store the relevant cluster data
    List<List<dynamic>> clusterData = List.generate(pixelHeight.toInt(), (_) => List.filled(pixelWidth.toInt(), 0.0));

    // Iterate through the points of the polyline
    for (List<LatLng> polyline in polylineCoordinates) {
      for (LatLng point in polyline) {
        int y = max(_getGeoTIFFIndex(point.latitude, true) - sey - 1, 0);
        int x = max(_getGeoTIFFIndex(point.longitude, false) - nwx - 1, 0);

        if (x >= 0 && x < pixelWidth && y >= 0 && y < pixelHeight) {
          clusterData[y][x] = _geotiffData![y][x];
        }
      }
    }

    return clusterData;
  }







}



class UrlTileProvider extends TileProvider {
  final int tileWidth;
  final int tileHeight;
  final String Function(int x, int y, int zoom) tileUrlTemplate;

  UrlTileProvider(this.tileWidth, this.tileHeight, this.tileUrlTemplate);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    // Invert y coordinate if necessary
    y = (1 << zoom!) - y - 1;
    final String tileUrl = tileUrlTemplate(x, y, zoom); // Use the corrected y
    final response = await http.get(Uri.parse(tileUrl));

    if (response.statusCode == 200) {
      return Tile(tileWidth, tileHeight, response.bodyBytes);
    } else {
      throw Exception('Failed to load tile at $x, $y, zoom $zoom');
    }
  }


}

class Point {
  final double latitude;
  final double longitude;

  Point(this.latitude, this.longitude);

  @override
  String toString() => '($latitude, $longitude)';
}


