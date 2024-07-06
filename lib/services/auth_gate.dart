import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'; // new
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import 'package:route/components/sign_in_button.dart';
import 'package:route/pages/email_verification.dart';
import 'package:route/pages/home.dart';
import '../pages/sign_in_with_email.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late User? _user;
  late bool _isEmailVerified;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _isEmailVerified = _user?.emailVerified ?? false;

    // Periodically check if the email is verified
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _user?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        setState(() {
          _isEmailVerified = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 34, 139, 34), // Change status bar color here
    ));

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || (snapshot.hasData && !snapshot.data!.emailVerified && !_isEmailVerified)) {
          return SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Spacer(),
                    Text(
                      "aSapRoute",
                      style: GoogleFonts.oxygen(
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(200, 34, 139, 34),
                      ),
                    ),
                    const Spacer(), // Pushes the buttons to the center
                    Column(
                      children: [
                        SignInButton(
                          text: "Sign in with Google",
                          textColor: Colors.black,
                          color: Colors.white,
                          onPressed: () {
                            signInWithGoogle();
                          },
                          imagePath: 'assets/google.png', // Replace with your actual image asset path
                          imageWidth: 60, // Provide desired image width
                          imageHeight: 35, // Provide desired image height
                        ),
                        const SizedBox(height: 30.0),
                        SignInButton(
                          text: "Sign in with Facebook",
                          textColor: Colors.white,
                          color: Color.fromARGB(255, 59, 89, 152),
                          onPressed: () {
                            // Implement Facebook sign-in logic here
                          },
                          imagePath: 'assets/facebook.png', // Replace with your actual image asset path
                          imageWidth: 60, // Provide desired image width
                          imageHeight: 40, // Provide desired image height
                        ),
                        const SizedBox(height: 30.0),
                        SignInButton(
                          text: "Sign in with Apple",
                          textColor: Colors.white,
                          color: Colors.black,
                          onPressed: () {
                            // Implement Apple sign-in logic here
                          },
                          imagePath: 'assets/apple.png', // Replace with your actual image asset path
                          imageWidth: 60, // Provide desired image width
                          imageHeight: 50, // Provide desired image height
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20.0, right: 15.0),
                                child: const Divider(
                                  color: Color.fromARGB(50, 0, 0, 0),
                                  height: 36,
                                ),
                              ),
                            ),
                            Text(
                              "or",
                              style: GoogleFonts.lato(
                                color: Color.fromARGB(50, 0, 0, 0),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 15.0, right: 20.0),
                                child: const Divider(
                                  color: Color.fromARGB(50, 0, 0, 0),
                                  height: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SignInButton(
                          text: "Sign in with Email",
                          textColor: Colors.white,
                          color: Color.fromARGB(200, 34, 139, 34),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => SignInWithEmail(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          imagePath: 'assets/apple.png', // Replace with your actual image asset path
                          imageWidth: 60, // Provide desired image width
                          imageHeight: 50, // Provide desired image height
                        ),
                      ],
                    ),
                    SizedBox(height: 70,),
                    const Spacer(), // Pushes the buttons to the center
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Home();
        }
      },
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: "789625081686-iou50bc3ojf6gqnn1amrl7caopdlu54c.apps.googleusercontent.com", // Replace with your OAuth 2.0 client ID
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );

      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }
}
