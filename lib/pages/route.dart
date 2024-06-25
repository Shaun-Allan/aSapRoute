  import 'dart:async';
  import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
  import 'package:geocoding/geocoding.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:route/inheritance/coordinateState.dart';
import 'package:route/inheritance/core_state.dart';
  import 'package:route/pages/map_input.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:route/inheritance/coordinateState.dart';

  class Reroute extends StatefulWidget {


    const  Reroute({super.key});


    @override
    State<Reroute> createState() => _RerouteState();
  }

  class _RerouteState extends State<Reroute> {
    Completer<GoogleMapController> _controller = Completer();

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

    @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }


    @override
    Widget build(BuildContext context) {
      // final coordinates = CoordinateInheritance.of(context);
      final destString = CoordinateInheritance.of(context)?.coreState.destString;
      final sourceString = CoordinateInheritance.of(context)?.coreState.sourceString;
      final destCoordinates = CoordinateInheritance.of(context)?.coreState.destCoordinates;
      final sourceCoordinates = CoordinateInheritance.of(context)?.coreState.sourceCoordinates;
      List<Marker> _markers = <Marker>[];
      Set<Polyline> _polyline = {};

      if(destCoordinates!=null && sourceCoordinates!=null){
        _markers = <Marker>[
          Marker(markerId: MarkerId('source'), position: sourceCoordinates, icon: BitmapDescriptor.defaultMarker),
          Marker(markerId: MarkerId('destination'), position: destCoordinates, icon: BitmapDescriptor.defaultMarker),
        ];
        _polyline = {
          Polyline(
            polylineId: PolylineId('main_route'),
            points: [sourceCoordinates, destCoordinates]
          )
        };
      }



      print(sourceCoordinates);
      print(sourceString);

      return Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: true,
              initialCameraPosition: CameraPosition(
                target: sourceCoordinates!=null ? sourceCoordinates! : LatLng(12.752059035456769, 80.20327134232357),
                zoom: 14,
              ),
              markers: Set<Marker>.of(_markers),
              polylines: _polyline,
              compassEnabled: true,
              // myLocationEnabled: true,
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
                                  offset: Offset(0, 3), // changes position of shadow
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
                                  Icon(CupertinoIcons.location_solid, color:  destString!=null ? Colors.red : Colors.grey,)
                                  ,
                                  SizedBox(width: 10,),
                                  destString != null ?
                                  Text(
                                    '$destString',
                                    style: GoogleFonts.lato(
                                            fontSize: 17.5,
                                                fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                            ),
                                  )
                                      :
                                  Text(
                                      'Enter destination',
                                      style:
                                      GoogleFonts.lato(
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
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black.withOpacity(0.1),
                              //     spreadRadius: 2,
                              //     blurRadius: 5,
                              //     offset: Offset(0, 3), // changes position of shadow
                              //   ),
                              // ],
                            ),
                            // child: TextField(
                            //   enabled: false,
                            //   controller: destController,
                            //   decoration: InputDecoration(
                            //     hintText: 'Enter destination',
                            //     hintStyle: GoogleFonts.roboto(
                            //       fontSize: 17.5,
                            //       fontWeight: FontWeight.w400,
                            //       color: Colors.grey,
                            //     ),
                            //     border: InputBorder.none,
                            //     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            //     prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
