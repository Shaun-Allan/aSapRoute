import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:route/components/sign_in_button.dart';

import '../model/user_model.dart';
import '../services/store_user_model.dart';

class EmailVerificationPage extends StatefulWidget {
  final UserModel userModel;
  const EmailVerificationPage({Key? key, required this.userModel}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late User? _user;
  late bool _isEmailVerified;
  Timer? _timer;

  final userRepo = Get.put(UserRepository());

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _isEmailVerified = _user!.emailVerified;

    // Periodically check if the email is verified
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _user!.reload();
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

  Future<void> _navigateBack() async{
    // Navigate back to previous screen (assuming it's SignUpWithEmail)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 36, 9, 27)));
      },
    );
    await userRepo.createUser(widget.userModel);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_isEmailVerified)
                Column(
                  children: [
                    Text(
                      'Verify your email to continue.',
                      style: GoogleFonts.lato(fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    SignInButton(
                        text: "Didn't receive an email? Resend",
                        textColor: Colors.black,
                        color: Colors.white,
                        onPressed:  (){
                          _user!.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Verification email sent. Check your inbox.'),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        },
                    )
                  ],
                ),
              if (_isEmailVerified)
                Column(
                  children: [
                    Text(
                      'Email Verified!',
                      style: GoogleFonts.lato(fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    SignInButton(
                        text: "Continue to aSapRoute",
                        textColor: Colors.white,
                        color: Color.fromARGB(200, 34, 139, 34),
                        onPressed: _navigateBack,
                    )
                  ],
                ),
              SizedBox(height: 90,)
            ],
          ),
        ),
      ),
    );
  }
}
