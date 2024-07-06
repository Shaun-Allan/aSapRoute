import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/components/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:route/pages/email_verification.dart';
import 'package:route/services/store_user_model.dart';

import '../model/user_model.dart';

class SignUpWithEmail extends StatefulWidget {
  const SignUpWithEmail({Key? key}) : super(key: key);

  @override
  _SignUpWithEmailState createState() => _SignUpWithEmailState();
}

class _SignUpWithEmailState extends State<SignUpWithEmail> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();

  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  bool _isNameFocused = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
      });
    });
    _nameFocusNode.addListener(() {
      setState(() {
        _isNameFocused = _nameFocusNode.hasFocus;
      });
    });
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  Future<void> _signUpWithEmailAndPassword() async {
    setState(() {
      // Reset any previous errors
      _emailError = _emailController.text.trim().isEmpty
          ? 'Email field is empty'
          : !_isEmailValid(_emailController.text.trim())
          ? 'Invalid email format'
          : null;
      _passwordError = _passwordController.text.trim().isEmpty ? 'Password field is empty' : null;
      _confirmPasswordError = _confirmPasswordController.text.trim().isEmpty
          ? 'Confirm password field is empty'
          : !_isPasswordMatch(
          _passwordController.text.trim(), _confirmPasswordController.text.trim())
          ? 'Passwords do not match'
          : null;
      _nameError = _nameController.text.trim().isEmpty ? 'Name field is empty' : null;
    });

    if (_emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _nameError == null) {
      // Validating all fields before proceeding
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 36, 9, 27)));
        },
      );

      try {
        // Create user with email and password
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Send verification email with Firebase Auth
        await userCredential.user!.sendEmailVerification();

        // Navigate to EmailVerificationPage with slide left animation
        Navigator.pop(context); // Close the loading indicator
        UserModel userModel = UserModel(
          id: userCredential.user!.uid,
          Email: _emailController.text.trim(),
          Password: _passwordController.text.trim(),
          Name: _nameController.text.trim()
        );
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => EmailVerificationPage(userModel: userModel,),
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
      } catch (e) {
        Navigator.pop(context); // Close the loading indicator
        setState(() {
          if (e is FirebaseAuthException) {
            if (e.code == 'email-already-in-use') {
              _emailError = 'Email already in use';
              _passwordError = null;
              _confirmPasswordError = null;
            } else {
              _emailError = formatString(e.code);
              _passwordError = null;
              _confirmPasswordError = null;
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to sign up')),
            );
          }
        });
      }
    }
  }


  String formatString(String input) {
    String replaced = input.replaceAll('-', ' ');
    List<String> words = replaced.split(' ');
    List<String> capitalizedWords = words.map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();
    return capitalizedWords.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    double screen = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "aSapRoute",
            style: GoogleFonts.oxygen(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screen*0.04,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Container(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        border: Border(
                          bottom: BorderSide(
                            color: _isNameFocused ? Colors.green : Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          style: GoogleFonts.lato(),
                          decoration: InputDecoration(
                            labelText: "Enter your name",
                            labelStyle: GoogleFonts.lato(
                              color: _isNameFocused ? Colors.green : Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    if (_nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              _nameError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20.0),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        border: Border(
                          bottom: BorderSide(
                            color: _isEmailFocused ? Colors.green : Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          style: GoogleFonts.lato(),
                          decoration: InputDecoration(
                            labelText: "Enter email",
                            labelStyle: GoogleFonts.lato(
                              color: _isEmailFocused ? Colors.green : Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              _emailError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20.0),
                    AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          border: Border(
                            bottom: BorderSide(
                              color: _isPasswordFocused ? Colors.green : Colors.grey,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: !_isPasswordVisible,
                            style: GoogleFonts.lato(),
                            decoration: InputDecoration(
                              labelText: "Enter password",
                              labelStyle: GoogleFonts.lato(
                                color: _isPasswordFocused ? Colors.green : Colors.grey,
                              ),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: _isPasswordFocused ? Colors.green : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                    ),
                        if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                      child: Row(
                        children: [
                          Text(
                            _passwordError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        border: Border(
                          bottom: BorderSide(
                            color: _isConfirmPasswordFocused ? Colors.green : Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: !_isConfirmPasswordVisible,
                          style: GoogleFonts.lato(),
                          decoration: InputDecoration(
                            labelText: "Confirm password",
                            labelStyle: GoogleFonts.lato(
                              color: _isConfirmPasswordFocused ? Colors.green : Colors.grey,
                            ),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: _isConfirmPasswordFocused ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_confirmPasswordError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              _confirmPasswordError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 50.0),
                    SignInButton(
                      text: "Sign up with Email",
                      textColor: Colors.white,
                      color: Color.fromARGB(200, 34, 139, 34),
                      onPressed: _signUpWithEmailAndPassword,
                      imagePath: 'assets/apple.png', // Replace with your actual image asset path
                      imageWidth: 60, // Provide desired image width
                      imageHeight: 50, // Provide desired image height
                      centerText: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50,),
              SizedBox(height: screen * 0.04,),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Already have an account? Sign In",
                  style: GoogleFonts.lato(
                    color: Colors.green,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}
