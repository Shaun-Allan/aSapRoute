import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route/components/add_fav_panel.dart';
import 'package:route/inheritance/data_hub.dart';
import 'package:location/location.dart' as location;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route/components/fav_tile.dart';
import 'package:route/model/fav_model.dart';
import 'package:route/model/recents_model.dart';
import 'package:route/pages/route.dart';
import 'package:route/services/recents_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import 'package:route/inheritance/data_hub.dart';

import '../services/fav_repository.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final panelController = SlidingUpPanelController(); // Define panel controller
  final scrollController = ScrollController();
  final locationController = location.Location();
  TextEditingController sourceController = TextEditingController();
  TextEditingController destController = TextEditingController();
  FocusNode sourceFocusNode = FocusNode();
  FocusNode destFocusNode = FocusNode();
  FocusScopeNode _focusScopeNode = FocusScopeNode();
  FocusNode favFocus = FocusNode();
  FocusNode titleFocus = FocusNode();
  TextEditingController favController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  LatLng? yourLocation;

  var uuid = Uuid();
  String _sessionToken = '123456';
  List<dynamic> _placesList = [];

  int initialized = 0;

  final recentsRepo = Get.put(RecentsRepository());
  final favRepo = Get.put(FavoritesRepository());


  @override
  void initState() {
    super.initState();
    panelController.hide();
    _focusScopeNode.attach(context); // Attach the FocusScopeNode to the context
    _focusScopeNode.requestFocus(sourceFocusNode);
    sourceController.addListener(() {
      onChange(sourceController);
    });
    destController.addListener(() {
      onChange(destController);
    });
    favController.addListener(() {
      onChange(favController);
    });
    titleController.addListener(() {
      onChange(titleController);
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

    initialized = 1;
    showAddToFavoritesPanel = false;
    setState(() {
      favPaneGenerated = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((
        _) async => await fetchLocationUpdates());
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
    String kPLACES_API_KEY = "AIzaSyAg3BKDZdxhvGE6Mu_AQnroyagbG0FKLjE";
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


  // @override
  // void dispose() {
  //   sourceFocusNode.dispose();
  //   destFocusNode.dispose();
  //   _focusScopeNode.dispose(); // Dispose the FocusScopeNode
  //   super.dispose();
  // }

  LatLng? sourceCoordinates;
  LatLng? destCoordinates;


  void setClearPolyline(bool clearPolyline) async{
    final provider = DataInheritance.of(context);

    provider?.setClearPolyline(clearPolyline);
  }



  void setCoordinate(LatLng sc, LatLng dc, String ss, String ds, String ddesc) async{
    final provider = DataInheritance.of(context);

    provider?.setSource(sc, ss);
    provider?.setDestination(dc, ds);

    setBooleans();

    setMakeRoute(true);


    Navigator.pop(context);

    if(ds != "Your location") {
      print("sdkbfkbanaad\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n------------------------------");
      final uid = DataInheritance.of(context)?.coreState.userModel?.id;
      final recentsModel = RecentsModel(location: dc, name: ds, desc: ddesc);
      await recentsRepo.saveRecentSearches(uid!, recentsModel);
      print("added");
    }
  }

  void setYourLocation(LatLng c) {
    final provider = DataInheritance.of(context);
    provider?.setYourLocation(c);
  }

  void setBooleans() {
    // final provider = DataInheritance.of(context);
    // provider?.setCalculatedAlternateRoute(false);
    // provider?.setCalculatingAlternateRoute(false);
    // provider?.setCalculatedOrgRoute(false);
    // provider?.setCalculatingOrgRoute(false);
    // provider?.setCheckedRouteHasLS(false);
    // provider?.setCheckingRouteHasLS(true);
    // provider?.setNeedAlternateRoute(false);
  }

  void setMakeRoute(bool makeRoute) async{
    final provider = DataInheritance.of(context);

    provider?.setMakeRoute(makeRoute);
    setClearPolyline(true);
  }


  void checkAndSetLocation(TextEditingController sourceController, TextEditingController destController, LatLng? yourLocationCoordinates, String mainDest) async {
    if (sourceController.text.isNotEmpty && destController.text.isNotEmpty) {
      LatLng sourceLocation;
      LatLng destLocation;
      String yourLocationString = "";

      if (sourceController.text == 'Your location') {
        if (yourLocationCoordinates != null) {
          sourceLocation = yourLocationCoordinates;
          List<Placemark> placemarks = await placemarkFromCoordinates(sourceLocation.latitude, sourceLocation.longitude);
          yourLocationString = placemarks.isNotEmpty ? placemarks.reversed.last.subLocality ?? '' : '';
        } else {
          // Handle case where yourLocationCoordinates is null
          return;
        }
      } else {
        List<Location> slocations = await locationFromAddress(sourceController.text);
        sourceLocation = LatLng(slocations.first.latitude, slocations.first.longitude);
      }

      if (destController.text == 'Your location') {
        if (yourLocationCoordinates != null) {
          destLocation = yourLocationCoordinates;
          List<Placemark> placemarks = await placemarkFromCoordinates(destLocation.latitude, destLocation.longitude);
          yourLocationString = placemarks.isNotEmpty ? placemarks.reversed.last.subLocality ?? '' : '';
        } else {
          // Handle case where yourLocationCoordinates is null
          return;
        }
      } else {
        List<Location> dlocations = await locationFromAddress(destController.text);
        destLocation = LatLng(dlocations.first.latitude, dlocations.first.longitude);
      }

      print(yourLocationString);

      // if (mounted) {
        setCoordinate(
          sourceLocation,
          destLocation,
          sourceController.text,
          destController.text,
          mainDest
        );
      // }
    }
  }

  List<RecentsModel> recentlySearched = [];

  void getRecents(String uid) async{
    recentlySearched = await recentsRepo.getRecentlySearched(uid!);
    setState(() {
      _loadingRecents = false;
    });
  }

  List<FavoriteModel> favorites = [];

  void getFavorites(String uid) async{
    favorites = await favRepo.getFavorites(uid);
    setState(() {
      _loadingFavorite = false;
    });
  }

  bool showDustbin = false;



  bool showAddToFavoritesPanel = false;
  bool favPaneGenerated = false;
  bool dustbinSeen = false;

  SlidingUpPanelController panelControllerD = SlidingUpPanelController();

  String favDesc = "";

  bool _loadingRecents = true;
  bool _loadingRecentsFavorites = true;
  bool _nothingRecents = false;
  bool _loadingFavorite = true;



  @override
  Widget build(BuildContext context) {
    final uid = DataInheritance.of(context)?.coreState.userModel?.id;
    if(initialized == 1){
      final destString = DataInheritance.of(context)?.coreState.destString;
      final sourceString = DataInheritance.of(context)?.coreState.sourceString;
      final yourLocationCoordinates = DataInheritance.of(context)?.coreState.yourLocationCoordinates;
      if (sourceString != null) {
        sourceController.text = sourceString;
      }
      else{
        if(yourLocationCoordinates != null){
          sourceController.text = "Your location";
        }
      }
      if (destString != null) {
        destController.text = destString;
      }
      getRecents(uid!);

      initialized = 0;
    }


    getFavorites(uid!);
    // setShowDustbin(false);

    print("fav" + favorites.length.toString());




    final destString = DataInheritance.of(context)?.coreState.destString;
    // final yourLocationString = CoordinateInheritance.of(context)?.coreState.yourLocationString;
    final yourLocationCoordinates = DataInheritance.of(context)?.coreState.yourLocationCoordinates;
    final sourceString = DataInheritance.of(context)?.coreState.sourceString;
    double screenWidth = MediaQuery.of(context).size.width;
    double tileWidth = screenWidth / 4;




    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // statusBarColor: Color.fromARGB(255, 34, 139, 34), // Change status bar color here
      statusBarIconBrightness: Brightness.dark,
    ));





    final screen = MediaQuery.of(context).size.width;


    print("show");
    print(showDustbin);

    return Scaffold(
      resizeToAvoidBottomInset: showAddToFavoritesPanel || dustbinSeen ? true : false,
      body: Container(
        child: Scaffold(
          resizeToAvoidBottomInset: showAddToFavoritesPanel || dustbinSeen? true : false,
          body: Stack(
            children: [
              Padding(
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
                                          vertical: 10, horizontal: 16),
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
                                      Icon(Icons.location_on, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15), // Spacer between destination field and "Your Location" box
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            await fetchLocationUpdates();
                            if (sourceFocusNode.hasFocus && yourLocationCoordinates != null) {
                              sourceController.text = "Your location";
                            }
                            if (destFocusNode.hasFocus && yourLocationCoordinates != null) {
                              destController.text = "Your location";
                            }
                            checkAndSetLocation(sourceController, destController, yourLocationCoordinates, "Your location");
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            side: BorderSide(color: Color.fromARGB(200, 34, 139, 34)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.locationCrosshairs,
                                color: Color.fromARGB(200, 34, 139, 34),
                              ),
                              SizedBox(width: 10), // Space between icon and text
                              Text(
                                'Your location',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(200, 34, 139, 34),
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                        ),
                        SizedBox(width: 20), // Space between buttons
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle start trip action
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              side: BorderSide(color: Color.fromARGB(200, 34, 139, 34)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              backgroundColor: Color.fromARGB(200, 34, 139, 34),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  // Replace with your start trip icon
                                  Icons.directions_car,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10), // Space between icon and text
                                Text(
                                  'Start trip',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white.withOpacity(0.8),
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end, // Align to the end of the row
                                  children: [
                                    Text(
                                      'Favorites',
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color.fromARGB(180, 0, 0, 0),
                                      ),
                                    ),
                                    Spacer(),
                                    if(!_loadingFavorite && favorites.length!=0)// Spacer to push the button to the end
                                    GestureDetector(
                                      onTap: () {
                                        // setState(() {
                                        //   showAddToFavoritesPanel = true;
                                        // });
                                        setState(() {
                                          showAddToFavoritesPanel = true;
                                        });
                                        panelController.expand();

                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                              "Add to favorites",
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          Icon(CupertinoIcons.add_circled, size: 18, color: Colors.grey,),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                _loadingFavorite
                                    ?
                                Container(
                                  height: 40,
                                  margin: EdgeInsets.only(top: 5),
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 5, // Number of shimmer placeholders
                                      itemBuilder: (context, index) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: tileWidth,
                                            // Adjust according to your item width
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(
                                                  8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(
                                                      0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                )

                            :
                                    favorites.length == 0?
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              showAddToFavoritesPanel = true;
                                            });
                                            panelController.expand();
                                          },
                                          child: Container(
                                            height: 50,
                                            width: tileWidth,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color.fromARGB(30, 0, 0, 0), // Outline color
                                                width: 1, // Outline width
                                              ),
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Icon(CupertinoIcons.add_circled, color: Color.fromARGB(60, 0, 0, 0),),
                                          ),
                                        )
                                        :
                                Container(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal, // Ensure the list scrolls horizontally
                                    itemCount: favorites.length,
                                    itemBuilder: (context, index) {
                                      final favorite = favorites[index];
                                      return LongPressDraggable<FavoriteModel>(
                                        onDragCompleted: (){
                                          Vibrate.feedback(FeedbackType.medium); // Feedback without expecting return
                                        },
                                        onDragStarted: (){
                                          Vibrate.feedback(FeedbackType.medium); // Feedback without expecting return
                                          setState(() {
                                            showDustbin = true;
                                            dustbinSeen = true;
                                          });
                                          panelControllerD.expand();
                                        },
                                        onDragEnd: (_){
                                          setState(() {
                                            showDustbin = false;
                                            dustbinSeen = false;
                                          });
                                          panelControllerD.hide();
                                        },
                                        data: FavoriteModel(
                                          location: favorites[index].location,
                                          title: favorites[index].title,
                                          desc: favorites[index].desc,
                                          locName: favorites[index].locName
                                        ),
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: tileWidth,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Color.fromARGB(30, 0, 0, 0), // Outline color
                                                width: 1, // Outline width
                                              ),
                                              borderRadius: BorderRadius.circular(8),
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
                                              child: Text(
                                                favorites[index].title,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                  color: Color.fromARGB(200, 0, 0, 0),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.0,
                                          child: buildTile((){}, tileWidth, favorites[index].title),
                                        ),
                                        child: buildTile((){}, tileWidth, favorites[index].title)

                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Recently Searched',
                                  style: GoogleFonts.lato(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(180, 0, 0, 0),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
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
                                    child: _loadingRecents
                                        ?
                                    ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: 5, // Number of skeleton items to show
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
                                    recentlySearched.isNotEmpty?
                                    ListView.builder(
                                      padding: EdgeInsets.zero, // Ensure no padding around the ListView
                                      itemCount: recentlySearched.length,
                                      itemBuilder: (context, index) {
                                        final recent = recentlySearched[index];
                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0), // Adjust the vertical padding
                                              title: Text(
                                                recent.name,
                                                style: GoogleFonts.notoSans(fontWeight: FontWeight.w400, fontSize: 15),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                recent.desc,
                                                style: GoogleFonts.lato(color: Color.fromARGB(150, 0, 0, 0), fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              onTap: () {
                                                sourceController.text = "Your location";
                                                destController.text = recent.name;
                                                checkAndSetLocation(sourceController, destController, yourLocationCoordinates, recent.desc);
                                              },
                                            ),
                                            if (index < recentlySearched.length - 1) // Add divider conditionally
                                              Container(
                                                height: 0,
                                                margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                child: const Divider(
                                                  color: Color.fromARGB(50, 0, 0, 0),
                                                  height: 36,
                                                ),
                                              ), // Divider between items
                                          ],
                                        );
                                      },
                                    )
                                        :
                                    Container(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.route_outlined, color: Color.fromARGB(50, 0, 0, 0), size: 40),
                                          SizedBox(height: 20,),
                                          Text(
                                            "Your recent searches will appear here",
                                            style: GoogleFonts.lato(
                                              color: Colors.grey,
                                            )
                                          ),
                                          SizedBox(height: 40,),
                                        ],
                                      ),
                                    )
                                  ),
                                ),


                              ],
                            ),

                          ),
                  DeleteDustbin(),


                          if((sourceFocusNode.hasFocus && sourceController.text.isNotEmpty) || (destFocusNode.hasFocus && destController.text.isNotEmpty) )
                          Expanded(
                            child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
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
                                        _setAddress(sourceFocusNode.hasFocus ? sourceController : destController, _placesList[index]['structured_formatting']['main_text']);
                                        checkAndSetLocation(sourceController, destController, yourLocationCoordinates, _placesList[index]['description']);
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
                          ),
                        ]
                      ),
                    )
                  ],
                ),
              ),
              if(!favPaneGenerated)
                AddFavPanel(),
            ],
          ),
        ),
      ),
    );


  }




  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    location.PermissionStatus permissionGranted;

    // Check if service is enabled
    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        // Service is not enabled, handle it appropriately (show a message, etc.)
        print('Location service is not enabled.');
        return;
      }
    }

    // Check for location permissions
    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == location.PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != location.PermissionStatus.granted) {
        // Permissions are not granted, handle it appropriately (show a message, etc.)
        print('Location permission is not granted.');
        return;
      }
    }

    // Start listening to location changes
    locationController.onLocationChanged.listen((currentLocation) {

      setState(() {
        LatLng yourLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        setYourLocation(yourLocation);
      });
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    });
  }







  Future<void> addFavorite(String locName, String title, String desc) async{

  }

  Widget buildTile(VoidCallback onTap, double tileWidth, String title) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide.none, // No border needed here, as it's handled by Card
          padding: EdgeInsets.zero, // Remove padding around the button
        ),
        child: Container(
          width: tileWidth,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.openSans(
                fontSize: 13,
                color: Color.fromARGB(200, 0, 0, 0),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }








  Widget DeleteDustbin() {
    final screen = MediaQuery.of(context).size.height;
    return SlidingUpPanelWidget(
      controlHeight: 100.0,
      anchor: 0.4,
      panelController: panelControllerD,
      onTap: () {
        // if (panelController.status == SlidingUpPanelStatus.expanded) {
        //   panelController.collapse();
        // } else {
        //   panelController.expand();
        // }
      },
      enableOnTap: true,
      dragDown: (details) {
        print('dragDown');
      },
      dragStart: (details) {
        print('dragStart');
      },
      dragCancel: () {
        print('dragCancel');
      },
      dragUpdate: (details) {
        print('dragUpdate, ${panelController.status ==
            SlidingUpPanelStatus.dragging ? 'dragging' : ''}');
      },
      dragEnd: (details) {
        print('dragEnd');
        panelControllerD.hide();
        setState(() {
          dustbinSeen = false;
        });
      },

      child: DragTarget<FavoriteModel>(
        onWillAccept: (data) {
          // When the draggable object is dragged over the dustbin
          Vibrate.feedback(FeedbackType.medium); // Vibration feedback
          return true; // Accept the drag
        },
        onAccept: (data) {
          print("title");
          print(data.title);
            // Perform actions when the object is dropped on the dustbin
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit report: ')),
          );
          setState(() {
            // Example action: Hide the dustbin and update state

          });
        },
        builder: (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
            ) {
          return Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 400),
            child: Container(
              margin: EdgeInsets.only(top: 00),
              width: double.infinity,
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(CupertinoIcons.trash_fill, size: 40, color: Colors.red),
                    onPressed: () {

                    },
                  ),
                ],
              ),
            ),
          );
        },

      ),
    );
  }












  Widget AddFavPanel() {
    final screen = MediaQuery.of(context).size.height;
    return SlidingUpPanelWidget(
      controlHeight: 100.0,
      anchor: 0.4,
      panelController: panelController,
      onTap: () {
        // if (panelController.status == SlidingUpPanelStatus.expanded) {
        //   panelController.collapse();
        // } else {
        //   panelController.expand();
        // }
      },
      enableOnTap: true,
      dragDown: (details) {
        print('dragDown');
      },
      dragStart: (details) {
        print('dragStart');
      },
      dragCancel: () {
        print('dragCancel');
      },
      dragUpdate: (details) {
        print('dragUpdate, ${panelController.status ==
            SlidingUpPanelStatus.dragging ? 'dragging' : ''}');
      },
      dragEnd: (details) {
        print('dragEnd');
        panelController.hide();
        setState(() {
          showAddToFavoritesPanel = false;
        });
      },






      child: Container(
        margin: EdgeInsets.only(top: 228),
        decoration: ShapeDecoration(
          color: Colors.white,
          shadows: [
            BoxShadow(
              blurRadius: 5.0,
              spreadRadius: 2.0,
              color: const Color(0x11000000),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
              ),
              // height: 200.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20,),
                    Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    SizedBox(height: 20,),
                    Material(
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
                                  focusNode: favFocus,
                                  style: GoogleFonts.roboto(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  controller: favController,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        width: 1,
                                        style: BorderStyle.solid,
                                        color: Color.fromARGB(255, 0, 0, 0), // Change border color here
                                      ),
                                    ),
                                    hintText: 'Enter location',
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
                                    Icon(CupertinoIcons.heart_fill, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              height: 45,
                              // width: 40,
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
                                        focusNode: titleFocus,
                                        style: GoogleFonts.roboto(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        controller: titleController,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(50),
                                            borderSide: BorderSide(
                                              width: 1,
                                              style: BorderStyle.solid,
                                              color: Color.fromARGB(255, 0, 0, 0), // Change border color here
                                            ),
                                          ),
                                          hintText: 'Enter title',
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
                                          Icon(CupertinoIcons.home),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () async{
                              // panelController.hide();
                              // await addFavorite(favController.text, titleController.text, favDesc);
                              panelController.hide();
                              showAddToFavoritesPanel = false;
                              final uid = DataInheritance.of(context)?.coreState.userModel?.id;

                              List<Location> flocations = await locationFromAddress(favDesc!);
                              final favLocation = LatLng(flocations.first.latitude, flocations.first.longitude);
                              final favModel = FavoriteModel(location: favLocation, locName: favController.text!, title: titleController.text!, desc: favDesc);
                              await favRepo.saveFavorite(uid!, favModel);
                              getFavorites(uid);
                              print("Added");
                            },
                            icon: Icon(CupertinoIcons.add_circled_solid, size:38,))
                      ],
                    ),

                    SizedBox(height: 5,),


                    Stack(
                        children: [
                          Container(
                            height: screen - 444,
                            color: Colors.white.withOpacity(0.8),
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
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
                                    child: _loadingRecents
                                        ?
                                    ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: 5, // Number of skeleton items to show
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
                                      (recentlySearched.length == 0)?
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.route_outlined, color: Color.fromARGB(50, 0, 0, 0), size: 40),
                                            SizedBox(height: 20,),
                                            Text(
                                                "Your recent searches will appear here",
                                                style: GoogleFonts.lato(
                                                  color: Colors.grey,
                                                )
                                            ),
                                            SizedBox(height: 40,),
                                          ],
                                        ),
                                      )
                                        :
                                    ListView.builder(
                                      padding: EdgeInsets.zero, // Ensure no padding around the ListView
                                      itemCount: recentlySearched.length,
                                      itemBuilder: (context, index) {
                                        final recent = recentlySearched[index];
                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0), // Adjust the vertical padding
                                              title: Text(
                                                recent.name,
                                                style: GoogleFonts.notoSans(fontWeight: FontWeight.w400, fontSize: 15),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                recent.desc,
                                                style: GoogleFonts.lato(color: Color.fromARGB(150, 0, 0, 0), fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              onTap: () {
                                                favController.text = recent.name;
                                                setState(() {
                                                  favDesc = recentlySearched[index].desc;
                                                });
                                                print(recentlySearched[index].desc);
                                                print(favDesc);
                                              },
                                            ),
                                            if (index < recentlySearched.length - 1) // Add divider conditionally
                                              Container(
                                                height: 0,
                                                margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                child: const Divider(
                                                  color: Color.fromARGB(50, 0, 0, 0),
                                                  height: 36,
                                                ),
                                              ), // Divider between items
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                          //
                          //
                          //
                              ],
                            ),
                          ),
                          if(favFocus.hasFocus && favController.text.isNotEmpty)
                            Container(
                              height: screen - 464,
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                                          _setAddress(favController, _placesList[index]['structured_formatting']['main_text']);
                                          favDesc = _placesList[index]['description'];
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
                            ),
                        ]
                    )



                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}






