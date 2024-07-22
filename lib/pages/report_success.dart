import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportSuccess extends StatefulWidget {
  @override
  _ReportSuccessState createState() => _ReportSuccessState();
}

class _ReportSuccessState extends State<ReportSuccess> {
  @override
  void initState() {
    super.initState();
    // Add a delay to automatically navigate after 2 seconds
    // Timer(Duration(milliseconds: 2000), () {
    //   Navigator.pop(context); // Navigate back to previous screen
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.xmark),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: Color.fromARGB(200, 34, 139, 34),
              size: 150,
            ),
            SizedBox(height: 30),
            Text(
              'Landslide Successfully Reported',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text(
              'Thank you for contributing by providing information',
              style: GoogleFonts.lato(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
