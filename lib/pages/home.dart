import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:route/bloc/bottom_nav_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/model/user_model.dart';
import 'package:route/services/store_user_model.dart';
import 'package:route/theme/theme_constraints.dart';
import 'package:route/pages/route.dart';
import 'package:route/pages/report.dart';
import 'package:route/pages/settings.dart' as settings;
import 'package:google_fonts/google_fonts.dart';

import '../inheritance/data_hub.dart';


class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController pageController;

  @override
  void initState(){
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final List<Widget> topLevelPages = const [
    Reroute(),
    Report(),
    settings.Settings(),
  ];

  final List<String> appBarTitles = [
    "aSapRoute",
    "Report",
    "Settings",
  ];

  void onPageChanged(int page){
    BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
  }

  Future<UserModel?> fetchUserProfile() async {
    DocumentSnapshot? userProfileSnapshot;
    try {
      // Get current user from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch user data from Firestore using user.uid (user ID)
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(user.uid).get();

        // Update userProfileSnapshot state with fetched data
        UserModel userModel = UserModel(
            id: user.uid,
            Email: snapshot!["Email"],
            Name: snapshot!["Name"],
            Password: snapshot!["Password"]
        );
        return userModel;
      } else {
        print("User not signed in.");
        // Handle case where user is not signed in
        return null;
      }

    } catch (e) {
      print("Error fetching user profile: $e");
      // Handle error fetching data
      return null;
    }
  }


  void setUserModel() async{
    final provider = DataInheritance.of(context);
    UserModel? userModel = await fetchUserProfile();
    print("\n\n\n\n\n\n\n\n\n\n\n\n\nhello\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    print("dsbsbg" + userModel!.Name);

    provider?.setUserModel(userModel!);
  }




  @override
  Widget build(BuildContext context) {

    setUserModel();
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: _mainWrapperAppBar(),
      body: _mainWrapperBody(),
      bottomNavigationBar: _mainWrapperBottomNavBar(context),
    );
  }


  PageView _mainWrapperBody() {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: (int page) => onPageChanged(page),
      controller: pageController,
      children: topLevelPages,
    );
  }

  AppBar _mainWrapperAppBar() {
    return AppBar(
      // backgroundColor: Colors.white,
      title: BlocBuilder<BottomNavCubit, int>(
        builder: (context, state) {
          return Text(
            appBarTitles[state],
            style: appBarTitles[state] == "aSapRoute" ? GoogleFonts.oxygen(fontWeight: FontWeight.w700) : GoogleFonts.poppins(fontWeight: FontWeight.w400),
          );
        },
      ),
    );
  }

  Widget _bottomAppBarItem(
      BuildContext context, {
        required defaultIcon,
        required page,
        required label,
        required filledIcon,
  }) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
        pageController.animateToPage(page, duration: Duration(milliseconds: 800), curve: Curves.fastLinearToSlowEaseIn);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              context.watch<BottomNavCubit>().state == page ? filledIcon : defaultIcon,
              size: 26,
              color: context.watch<BottomNavCubit>().state == page ? Color.fromARGB(200, 34, 139, 34) : Colors.grey,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              style: GoogleFonts.aBeeZee(
                color: context.watch<BottomNavCubit>().state == page ? Color.fromARGB(200, 34, 139, 34) : Colors.grey,
                fontSize: 13,
                fontWeight: context.watch<BottomNavCubit>().state == page ? FontWeight.w600 : FontWeight.w400,
              )
            )
          ],
        )
      ),
    );
  }


  BottomAppBar _mainWrapperBottomNavBar(BuildContext context) {

    return BottomAppBar(
      color: Color.fromARGB(30, 206, 243, 206),
      child: Row (
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomAppBarItem(context, defaultIcon: CupertinoIcons.map, page: 0, label: "Route", filledIcon: CupertinoIcons.map_fill),
          _bottomAppBarItem(context, defaultIcon: CupertinoIcons.exclamationmark_octagon, page: 1, label: "Report", filledIcon: CupertinoIcons.exclamationmark_octagon_fill),
          _bottomAppBarItem(context, defaultIcon: CupertinoIcons.settings, page: 2, label: "Settings", filledIcon: CupertinoIcons.settings_solid),
        ],
      )
    );
  }
}

