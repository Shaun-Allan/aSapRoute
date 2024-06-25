import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'; // new
import 'package:flutter/material.dart';

import 'package:route/pages/home.dart';
import 'package:google_fonts/google_fonts.dart';
class MyAppColors {
  static final darkBlue = Color(0xFF1E1E2C);
  static final lightBlue = Color(0xFF2D2D44);
}
class MyAppThemes {
  static final lightTheme = ThemeData(
    primaryColor: MyAppColors.lightBlue,
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    primaryColor: MyAppColors.darkBlue,
    brightness: Brightness.dark,
  );
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SignInScreen(
                providers: [
                  EmailAuthProvider(),
                  GoogleProvider(clientId: "789625081686-iou50bc3ojf6gqnn1amrl7caopdlu54c.apps.googleusercontent.com"),  // new
                ],
                // headerBuilder: (context, constraints, shrinkOffset) {
                //   return Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: SizedBox(
                //       width: 500, // Set desired width
                //       height: 500, // Set desired height
                //       child: AspectRatio(
                //         aspectRatio: 1,
                //         child: Image.asset('assets/logo.png'),
                //       ),
                //     ),
                //   );
                // },
                // subtitleBuilder: (context, action) {
                //   return Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                //     child: action == AuthAction.signIn
                //         ? const Text('Welcome to FlutterFire, please sign in!')
                //         : const Text('Welcome to Flutterfire, please sign up!'),
                //   );
                // },
                // footerBuilder: (context, action) {
                //   return const Padding(
                //     padding: EdgeInsets.only(top: 16),
                //     child: Text(
                //       'By signing in, you agree to our terms and conditions.',
                //       style: TextStyle(color: Colors.grey),
                //     ),
                //   );
                // },
                // sideBuilder: (context, shrinkOffset) {
                //   return Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: AspectRatio(
                //       aspectRatio: 1,
                //       child: Image.asset('flutterfire_300x.png'),
                //     ),
                //   );
                // },
              );
            }

            return const Home();
          },
        );
  }
}