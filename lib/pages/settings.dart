import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route/pages/settings/plans_and_subscriptions.dart';
import 'package:route/pages/settings/profile.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            ProfileContent(),
            SettingTile(
              title: 'My Reports',
              icon: Icon(CupertinoIcons.exclamationmark_octagon, color: Colors.red,),
              onTapFunction: () {
                // Navigate to profile screen or perform some action
              },
            ),
            SettingTile(
              title: 'Plans & Subscriptions',
              icon: Icon(CupertinoIcons.sparkles, color: Color.fromARGB(255, 112, 210, 255),),
              onTapFunction: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => PlansAndSubscriptions(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            SettingTile(
              title: 'Help',
              icon: Icon(FontAwesomeIcons.lifeRing, color: Colors.orange,),
              onTapFunction: () {
                // Navigate to profile screen or perform some action
              },
            ),
            SettingTile(
              title: 'Logout',
              icon: Icon(Icons.logout, color: Colors.redAccent,),
              onTapFunction: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('No', style: TextStyle(fontSize: 16, color: Color.fromARGB(200, 34, 139, 34)),),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop(); // Close the dialog
                          // Navigate to login screen or another screen after logout
                        },
                        child: Text('Yes', style: TextStyle(fontSize: 16, color: Colors.red),),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Icon icon;
  final VoidCallback onTapFunction;

  const SettingTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTapFunction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
      ),
      child: ListTile(
        leading: icon,
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16.0, color: Color.fromARGB(50, 0, 0, 0)),
        onTap: onTapFunction,
      ),
    );
  }
}



class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        width: double.infinity,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image(
                        image: AssetImage("assets/default_profile.jpg"),
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    "Profile Name",
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 17.0,
                    color: Color.fromARGB(30, 0, 0, 0),
                  ),
                  SizedBox(width: 20.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
