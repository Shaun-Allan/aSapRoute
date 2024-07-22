import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/inheritance/core_state.dart'; // Import your CoreState class
import 'package:route/inheritance/data_hub.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage> {
  SlidingUpPanelController panelController = SlidingUpPanelController();
  bool showEditPanel = false;
  bool editEmail = false;
  bool editGender = false;
  bool editPhone = false;
  bool editPanelGenerated = false;

  @override
  Widget build(BuildContext context) {
    // Accessing CoreState from the nearest DataInheritance ancestor widget
    CoreState coreState = DataInheritance.of(context)!.coreState!;

    // Access user information from coreState.userModel
    String userName = coreState.userModel?.Name ?? "Loading...";
    String userEmail = coreState.userModel?.Email ?? "";
    String userGender = "Male"; // Replace with actual gender
    String userPhoneNumber = "+1234567890"; // Replace with actual phone number

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, // Change color of the back button here
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 00,),
                // Profile Pic and Name
                        Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/default_profile.jpg",
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                        ),

                        SizedBox(height: 40),
                // Other Details
                _buildDetailRow(userEmail, "Email"),
                SizedBox(height: 25),
                _buildDetailRow(userGender, "Gender"),
                SizedBox(height: 25),
                _buildDetailRow(userPhoneNumber, "Phone Number"),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Implement sign out functionality here
                    // Example: FirebaseAuth.instance.signsOut();
                  },
                  child: Text('Sign Out'),
                ),
              ],
            ),
          ),
          if(editPanelGenerated)
            AddFavPanel(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: Color.fromARGB(150, 0, 0, 0)),),
        SizedBox(height: 10,),
        InkWell(
          onTap: (){
            setState(() {
              if(label == "Email"){
                editEmail = true;
              }
              else if(label == "Gender"){
                editGender = true;
              }
              else if(label == "Phone Number"){
                editPhone = true;
              }
              editPanelGenerated = true;
              panelController.expand();
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
                ),
                Spacer(),
                Icon(CupertinoIcons.pencil, color: Colors.grey,),
              ],
            ),
          ),
        ),
      ],
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
          showEditPanel = false;
        });
      },






      child: Container(
        margin: EdgeInsets.only(top: 0),
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
