import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route/components/sign_in_button.dart';
import 'package:route/model/report_model.dart';
import 'package:route/pages/report_success.dart';
import 'package:route/services/report_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../inheritance/data_hub.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

enum CauseLabel {
  HeavyRainfall,
  Earthquake,
  ConstructionActivity,
  Deforestation,
  MiningActivity,
  Other,
  Unknown
}

extension CauseLabelExtension on CauseLabel {
  String get name {
    switch (this) {
      case CauseLabel.HeavyRainfall:
        return 'Heavy Rainfall';
      case CauseLabel.Earthquake:
        return 'Earthquake';
      case CauseLabel.ConstructionActivity:
        return 'Construction Activity';
      case CauseLabel.Deforestation:
        return 'Deforestation';
      case CauseLabel.MiningActivity:
        return 'Mining Activity';
      case CauseLabel.Other:
        return 'Other';
      case CauseLabel.Unknown:
        return 'Unknown';
      default:
        return '';
    }
  }
}

class _ReportState extends State<Report> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _causeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  String _selectedCause = "";
  final int _maxChars = 500;

  final List<String> _causes = [
    'Heavy Rainfall',
    'Earthquake',
    'Construction Activity',
    'Deforestation',
    'Mining Activity',
    'Other',
    'Unknown'
  ];
  var uuid = Uuid();
  String _sessionToken = '123456';
  List<dynamic> _placesList = [];

  void onChange(TextEditingController _controller) {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    if(_controller.text.isEmpty){
      contentNeeded= false;
    }
    else {
      contentNeeded = true;
    }
    getSuggestion(_controller.text);
  }

  void _setAddress(TextEditingController controller, String address) {
    setState(() {
      controller.text = address;
    });
    contentNeeded = false;
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyCYHi0alROcEdEIV97imNAvkSKUEMvI4dA";
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

  bool contentNeeded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationFocusNode.addListener(() {
      if (_locationFocusNode.hasFocus) {
        setState(() {
          _placesList = [];
        });
      }
    });
    _locationController.addListener(() {
      onChange(_locationController);
    });
  }

  bool causeError = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  final TextEditingController colorController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  CauseLabel selectedCause = CauseLabel.HeavyRainfall;
  LatLng? location;
  String? locName;
  String? locDesc;

  void _updateCharCount(String text) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Colors.black,
          secondary: Colors.black,
          brightness: Brightness.light,
          onPrimary: Colors.yellow,
          onSecondary: Colors.yellow,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.redAccent,
          onError: Colors.red,
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            outlineBorder: BorderSide(
              color: Colors.red,
            ),
            fillColor: Colors.red,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                // color: causeError ? Colors.black : Colors.red,
                color: Colors.red,
              )
            ),
          ),
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
              child: Column(
                children: [
                  // Location Field
                  TextFormField(
                    focusNode: _locationFocusNode,
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelStyle: GoogleFonts.openSans(
                        fontSize: 16
                      ),
                      labelText: 'Location',
                      prefixIcon: Icon(CupertinoIcons.location_solid, size: 25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the location';
                      }
                      return null;
                    },
                  ),
                  (contentNeeded)
                      ?
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    height: MediaQuery.of(context).size.height-295,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 2, // Increase spread radius for a more lifted shadow effect
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _placesList.isEmpty
                        ?
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 7, // Number of skeleton items to show
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                                  title: Container(
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey[400]!), // Border color and width
                                      borderRadius: BorderRadius.circular(8), // Rounded corners for the border
                                    ),
                                  ),
                                  subtitle: Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey[400]!), // Border color and width
                                      borderRadius: BorderRadius.circular(8), // Rounded corners for the border
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        :
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _placesList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              tileColor: Colors.white,
                              onTap: () async {
                                List<Location> locations = await locationFromAddress(_placesList[index]['description']);
                                _setAddress(_locationController, _placesList[index]['structured_formatting']['main_text']);
                                print(_placesList[index]);
                                setState(() {
                                  location = LatLng(locations.first.latitude, locations.first.longitude);
                                  locName = _placesList[index]['structured_formatting']['main_text'];
                                  locDesc = _placesList[index]['description'];
                                });
                              },
                              title: Text(
                                _placesList[index]['structured_formatting']['main_text'],
                                style: GoogleFonts.notoSans(fontWeight: FontWeight.w400, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _placesList[index]['description'],
                                style: GoogleFonts.lato(color: Color.fromARGB(150, 0, 0, 0), fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (index < _placesList.length - 1) // Add divider conditionally
                              Container(
                                height: 0,
                                margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                                child: const Divider(
                                  color: Color.fromARGB(50, 0, 0, 0),
                                  height: 36,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  )
                      :
                  Column(
                    children: [
                      SizedBox(height: 25.0),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Color.fromARGB(255, 0, 80, 0), // header background color
                                    onPrimary: Colors.white, // header text color
                                    onSurface: Colors.black, // body text color
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black // button text color
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            style: GoogleFonts.openSans(fontSize: 16),
                            controller: _dateController,
                            readOnly: true, // Prevent direct editing
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.openSans(
                                  fontSize: 16
                              ),
                              labelText: 'Landslide Occur Date',
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: Icon(CupertinoIcons.calendar, size: 25,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25.0),

                      // Time Field
                      GestureDetector(
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                      primaryContainer: Colors.black,
                                      onPrimaryContainer: Colors.white,
                                      primary: Color.fromARGB(255, 34, 139, 34), // header background color
                                      onPrimary: Colors.white, // header text color
                                      onSurface: Colors.black,
                                      onSecondary: Colors.white,
                                      secondary: Color.fromARGB(255, 0, 80, 0) // body text color
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black // button text color
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _timeController.text = '${pickedTime.hour}:${pickedTime.minute}';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _timeController,
                            readOnly: true, // Prevent direct editing
                            style: GoogleFonts.openSans(fontSize: 16),
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.openSans(
                                  fontSize: 16
                              ),
                              labelText: 'Landslide Occur Time',
                              hintText: 'HH:MM',
                              prefixIcon: Icon(CupertinoIcons.clock, size: 25,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the time';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25.0),

                      // Cause Dropdown
                      DropdownMenu<CauseLabel>(
                        width: MediaQuery.of(context).size.width - 32,
                        controller: _causeController,
                        leadingIcon: Icon(CupertinoIcons.exclamationmark_triangle, size: 25,),
                        label: Text('Cause', style: GoogleFonts.openSans(
                            fontSize: 16
                        ),),
                        onSelected: (CauseLabel? cause) {
                          setState(() {
                            selectedCause = cause!;
                          });
                        },
                        initialSelection: CauseLabel.HeavyRainfall,
                        dropdownMenuEntries: CauseLabel.values
                            .map<DropdownMenuEntry<CauseLabel>>((CauseLabel cause) {
                          return DropdownMenuEntry<CauseLabel>(
                            value: cause,
                            label: cause.name,
                            style: MenuItemButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                      // if(causeError)
                      //   Container(
                      //     width: double.infinity,
                      //     padding: EdgeInsets.only(left: 13, top: 8),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: [
                      //         Text("Please enter the cause", style: TextStyle(color: Colors.red, fontSize: 12),),
                      //       ],
                      //     ),
                      //   ),
                      const SizedBox(height: 25),

                      // General Description Field
                      Stack(
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelStyle: GoogleFonts.openSans(
                                  fontSize: 16
                              ),
                              labelText: 'Description of Landslide',
                              prefixIcon: Icon(CupertinoIcons.square_list, size: 25,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            style: GoogleFonts.openSans(fontSize: 16),
                            maxLines: 5,
                            onChanged: _updateCharCount,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              } else if (value.length > _maxChars) {
                                return 'Description should not exceed $_maxChars characters';
                              }
                              return null;
                            },
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Text(
                              '${_maxChars - _descriptionController.text.length} characters remaining',
                              style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),

                      // Submit Button
                      SignInButton(
                        onPressed: () async{
                          await _submitReport();
                        },
                        text: "Report Landslide",
                        textColor: Colors.white,
                        color: Colors.black,
                        centerText: true,
                      ),
                    ],
                  ),

                  // Date Field

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final reportsRepo = Get.put(ReportsRepository());



  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Convert date and time to DateTime object
        final DateTime date = DateTime.parse(_dateController.text);
        final TimeOfDay time = TimeOfDay(
          hour: int.parse(_timeController.text.split(":")[0]),
          minute: int.parse(_timeController.text.split(":")[1]),
        );

        // Combine date and time to create a DateTime
        final DateTime dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Convert DateTime to Timestamp
        final Timestamp timestamp = Timestamp.fromDate(dateTime);
        final uid = DataInheritance
            .of(context)
            ?.coreState
            .userModel
            ?.id;

        // Get values from text fields and controllers
        final eventDesc = _descriptionController.text;

        print(location);
        print("jdjd" + locName.toString());


        // Construct report data
        ReportModel reportModel = ReportModel(
          uid: uid!,
          location: location!,
          locName: locName!,
          locDesc: locDesc!,
          timestamp: timestamp,
          cause: selectedCause.name,
          eventDesc: eventDesc,
        );

        // Save report to Firestore
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 36, 9, 27)));
          },
        );
        await reportsRepo.saveReport(uid, reportModel);
        Navigator.pop(context);

        // Show success message or navigate to another screen
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200), // Set the duration of the transition
            pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
              opacity: animation,
              child: ReportSuccess(),
            ),
          ),
        );
        _locationController.text = "";
        _dateController.text = "";
        _timeController.text = "";
        _causeController.text = "";
        _descriptionController.text = "";
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    }
  }


}
