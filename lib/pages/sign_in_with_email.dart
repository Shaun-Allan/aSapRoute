import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route/components/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:route/pages/sign_up.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({Key? key}) : super(key: key);

  @override
  _SignInWithEmailState createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isPasswordVisible = false;

  String? _emailError;
  String? _passwordError;

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
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? 'Email field is empty'
          : !_isEmailValid(_emailController.text.trim())
          ? 'Invalid email format'
          : null;
      _passwordError = _passwordController.text.trim().isEmpty ? 'Password field is empty' : null;
    });

    if (_emailError == null && _passwordError == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 36, 9, 27),));
        },
      );

      try {
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigate to the next screen on successful sign-in
        Navigator.pop(context);// Close the loading indicator
        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context); // Close the loading indicator
        setState(() {
          if (e is FirebaseAuthException) {
            if (e.code == 'user-not-found') {
              _emailError = 'User not found';
              _passwordError = null;
            } else if (e.code == 'wrong-password') {
              setState(() {

                _passwordError = 'Invalid password';
              });
              _emailError = null;
            } else {
              _passwordError = formatString(e.code);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Failed t sign in')),
              // );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to sign in')),
            );
          }
        });
      }
    }
  }

  String formatString(String input) {
    // Replace hyphens with spaces
    String replaced = input.replaceAll('-', ' ');

    // Split the string into words
    List<String> words = replaced.split(' ');

    // Capitalize the first letter of each word
    List<String> capitalizedWords = words.map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    // Join the words back into a single string
    return capitalizedWords.join(' ');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Sign in",
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
                    SizedBox(height: 30.0),
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
                    SizedBox(height: 50.0),
                    SignInButton(
                      text: "Sign in with Email",
                      textColor: Colors.white,
                      color: Color.fromARGB(200, 34, 139, 34),
                      onPressed: _signInWithEmailAndPassword,
                      imagePath: 'assets/apple.png', // Replace with your actual image asset path
                      imageWidth: 60, // Provide desired image width
                      imageHeight: 50,
                      centerText: true, // Provide desired image height
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50,),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 500), // Adjust the duration for a smoother animation
                      pageBuilder: (context, animation, secondaryAnimation) => SignUpWithEmail(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0, 1);
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
                child: Text(
                  "Don't have an account? Sign Up",
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
}
