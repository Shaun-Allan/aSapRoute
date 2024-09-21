import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class SignInButton extends StatefulWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onPressed;
  final String? imagePath;
  final double? imageWidth;
  final double? imageHeight;
  final bool centerText;

  const SignInButton({
    Key? key,
    required this.text,
    required this.textColor,
    required this.color,
    required this.onPressed,
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.centerText = false,
  }) : super(key: key);

  @override
  State<SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: widget.color,
          side: widget.color == Colors.white ? BorderSide(color: Colors.grey) : BorderSide.none,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.imagePath != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  widget.imagePath!,
                  width: widget.imageWidth,
                  height: widget.imageHeight,
                ),
              ),
            Row(
              mainAxisAlignment: widget.centerText ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                if (widget.imagePath != null) SizedBox(width: widget.imageWidth! + 8),
                Text(
                  widget.text,
                  style: GoogleFonts.poppins(
                    color: widget.textColor,
                    fontSize: 15,
                  ),
                  textAlign: widget.centerText ? TextAlign.center : TextAlign.start,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class APIPage extends StatefulWidget {
  const APIPage({Key? key}) : super(key: key);

  @override
  _APIPageState createState() => _APIPageState();
}

class _APIPageState extends State<APIPage> {
  void _generateApiKey() {
    // Example payload for JWT
    final payload = {
      'sub': 'user_id',  // Subject (user ID)
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,  // Issued at
      'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,  // Expiration
    };

    // Secret key for signing (make sure to keep this secure)
    const secret = 'your-256-bit-secret';

    // Create JWT token
    final jwt = JWT(payload);

    // Sign the token
    final token = jwt.sign(SecretKey(secret));

    // Show the generated token
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generated API Key: $token')),
    );
  }
  // State variables for Rerouting API
  double _reroutingRequestCount = 1000;
  double get _reroutingAmount => _reroutingRequestCount * 0.02;
  bool _isEditingRerouting = false;
  final TextEditingController _reroutingController = TextEditingController();

  // State variables for Crowdsourced Data API
  double _crowdsourcedRequestCount = 1000;
  double get _crowdsourcedAmount => _crowdsourcedRequestCount * 0.03;
  bool _isEditingCrowdsourced = false;
  final TextEditingController _crowdsourcedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reroutingController.text = _reroutingRequestCount.toInt().toString();
    _crowdsourcedController.text = _crowdsourcedRequestCount.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "API",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView( // Make the body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container for Rerouting API
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.lightBlue, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rerouting API",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "The Rerouting API provides real-time data for automatically rerouting your path in case of obstacles, traffic, or other disruptions.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Number of API Requests: ",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _isEditingRerouting
                          ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _reroutingController,
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) {
                            setState(() {
                              _reroutingRequestCount =
                                  double.tryParse(value) ??
                                      _reroutingRequestCount;
                              _reroutingController.text =
                                  _reroutingRequestCount
                                      .toInt()
                                      .toString();
                              _isEditingRerouting = false;
                            });
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      )
                          : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditingRerouting = true;
                          });
                        },
                        child: Text(
                          _reroutingRequestCount.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _reroutingRequestCount,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    label: _reroutingRequestCount.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _reroutingRequestCount = value;
                        _reroutingController.text =
                            _reroutingRequestCount.toInt().toString();
                      });
                    },
                  ),
                  Text(
                    "Amount: \$${_reroutingAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Container for Crowdsourced Data API
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Crowdsourced Data API",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "The Crowdsourced Data API collects and integrates data from users, helping improve navigation accuracy and providing up-to-date information.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Number of API Requests: ",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _isEditingCrowdsourced
                          ? SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _crowdsourcedController,
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) {
                            setState(() {
                              _crowdsourcedRequestCount =
                                  double.tryParse(value) ??
                                      _crowdsourcedRequestCount;
                              _crowdsourcedController.text =
                                  _crowdsourcedRequestCount
                                      .toInt()
                                      .toString();
                              _isEditingCrowdsourced = false;
                            });
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      )
                          : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditingCrowdsourced = true;
                          });
                        },
                        child: Text(
                          _crowdsourcedRequestCount
                              .toInt()
                              .toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _crowdsourcedRequestCount,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    label: _crowdsourcedRequestCount.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _crowdsourcedRequestCount = value;
                        _crowdsourcedController.text =
                            _crowdsourcedRequestCount
                                .toInt()
                                .toString();
                      });
                    },
                  ),
                  Text(
                    "Amount: \$${_crowdsourcedAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Get API Key Button
            SignInButton(
              text: "Get API Key",
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: _generateApiKey, // Use the function to generate the key
            ),
          ],
        ),
      ),
    );
  }
}
