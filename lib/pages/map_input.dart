import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route/inheritance/coordinateState.dart';
import 'package:location/location.dart' as location;
import 'package:route/pages/route.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'package:route/inheritance/coordinateInheritance.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final locationController = location.Location();
  TextEditingController sourceController = TextEditingController();
  TextEditingController destController = TextEditingController();
  FocusNode sourceFocusNode = FocusNode();
  FocusNode destFocusNode = FocusNode();
  FocusScopeNode _focusScopeNode = FocusScopeNode();

  var uuid = Uuid();
  String _sessionToken = '123456';
  List<dynamic> _placesList = [];


  @override
  void initState() {
    super.initState();
    _focusScopeNode.attach(context); // Attach the FocusScopeNode to the context
    _focusScopeNode.requestFocus(sourceFocusNode);
    sourceController.addListener(() {
      onChange(sourceController);
    });
    destController.addListener(() {
      onChange(destController);
    });
    sourceFocusNode.addListener(() {
      if (sourceFocusNode.hasFocus) {
        setState(() {
          _placesList = [];
        });
      }
    });
    destFocusNode.addListener(() {
      if (destFocusNode.hasFocus) {
        setState(() {
          _placesList = [];
        });
      }
    });


    WidgetsBinding.instance.addPostFrameCallback((_) async => await fetchLocationUpdates());



  }

  void _setAddress(TextEditingController controller, String address) {
    setState(() {
      controller.text = address;
    });
  }

  void onChange(TextEditingController _controller) {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyDFRYFYWQ5Q12KnevFyxKJMgiu7Rui-mF8";
    String groundURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$groundURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      print('Error: ${response.reasonPhrase}');
      throw Exception("Failed to load data");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access inherited widget here...
    final destString = CoordinateInheritance.of(context)?.coreState.destString;
    final sourceString = CoordinateInheritance.of(context)?.coreState.sourceString;
    if (sourceString != null) {
      sourceController.text = sourceString;
    }
    if (destString != null) {
      destController.text = destString;
    }
  }


  @override
  void dispose() {
    sourceFocusNode.dispose();
    destFocusNode.dispose();
    _focusScopeNode.dispose(); // Dispose the FocusScopeNode
    super.dispose();
  }

  LatLng? sourceCoordinates;
  LatLng? destCoordinates;


  void setCoordinate(LatLng sc, LatLng dc, String ss, String ds){
    final provider = CoordinateInheritance.of(context);
    provider?.setSource(sc, ss);
    provider?.setDestination(dc, ds);

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final destString = CoordinateInheritance.of(context)?.coreState.destString;
    final sourceString = CoordinateInheritance.of(context)?.coreState.sourceString;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          children: [
            SizedBox(height: 50), // To push the input fields down
            Hero(
              tag: 'inputField',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  height: 45,
                  margin: EdgeInsets.only(bottom: 16.0),
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
                  child: Center(
                    child: Row(
                      children: [

                        Expanded(
                          child: TextField(
                            focusNode: sourceFocusNode,
                            controller: sourceController,
                            style: GoogleFonts.roboto(
                              fontSize: 17.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            // autofocus: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Color.fromARGB(30, 0, 0, 0), // Change border color here
                                ),
                              ),
                              prefixIcon: IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.grey),
                                onPressed: () {
                                  Navigator.pop(context); // Navigate back to previous screen
                                },
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Color.fromARGB(255, 0, 0, 0), // Change border color here
                                ),
                              ),
                              hintText: 'Enter source',
                              hintStyle: GoogleFonts.lato(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 0),
                            ),
                          ),
                        ),
                      ],
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
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: destFocusNode,
                            style: GoogleFonts.roboto(
                              fontSize: 17.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            controller: destController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Color.fromARGB(255, 0, 0, 0), // Change border color here
                                ),
                              ),
                              hintText: 'Enter destination',
                              hintStyle: GoogleFonts.lato(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Color.fromARGB(30, 0, 0, 0), // Change border color here
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              prefixIcon:
                              Icon(Icons.location_on, color: destString!=null ? Colors.red : Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Spacer between destination field and "Your Location" box
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: Color.fromARGB(200, 34, 139, 34),
                        ),
                        SizedBox(width: 10), // Space between icon and text
                        Text(
                          'Your Location',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(200, 34, 139, 34),
                          ),
                        ),
                      ],
                    ),
                ),
              ),
              ],
            ),
            SizedBox(
              height: 0,
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: _placesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Colors.white,
                    onTap: () async {
                      List<Location> locations = await locationFromAddress(_placesList[index]['description']);
                      _setAddress(sourceFocusNode.hasFocus ? sourceController : destController, _placesList[index]['structured_formatting']['main_text']);
                      if(sourceController.text.isNotEmpty && destController.text.isNotEmpty){
                          List<Location> slocations = await locationFromAddress(sourceController.text);
                          List<Location> dlocations = await locationFromAddress(destController.text);
                          setCoordinate(LatLng(slocations.first.latitude, slocations.first.longitude),
                                        LatLng(dlocations.first.latitude, dlocations.first.longitude),
                                        sourceController.text,
                                        destController.text
                                        );
                      }
                    },
                    title: Text(
                      _placesList[index]['structured_formatting']['main_text'],
                      style: GoogleFonts.lato(
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _placesList[index]['description'],
                      style: GoogleFonts.lato(
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }


  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    location.PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if(serviceEnabled){
      serviceEnabled = await locationController.requestService();
    }
    else{
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if(permissionGranted == location.PermissionStatus.denied){
      permissionGranted = await locationController.requestPermission();
    }
    if(permissionGranted != location.PermissionStatus.denied){
      return;
    }

    locationController.onLocationChanged.listen((currentLocation){
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    });
  }

}