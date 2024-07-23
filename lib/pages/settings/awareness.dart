import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AwarenessPage extends StatelessWidget {
  const AwarenessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Landslide Awareness', style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Text(
              'Understanding Landslides',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'A landslide is the movement of rock, earth, or debris down a sloped section of land. '
                  'Landslides are caused by rain, earthquakes, volcanoes, or other factors that make the slope unstable.',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Causes of Landslides',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Landslides can be triggered by natural events like heavy rainfall, earthquakes, volcanic activity, '
                  'or human activities such as deforestation, construction, and mining.',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'How to Stay Safe',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'To stay safe during a landslide, follow these guidelines:\n'
                  '- Stay alert and listen to emergency alerts.\n'
                  '- Move away from the path of a landslide quickly.\n'
                  '- If escape is not possible, curl into a tight ball and protect your head.\n'
                  '- After the landslide, avoid the area as it may still be unstable.',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'For more information, visit these resources:',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildLink('National Geographic: Landslides', 'https://www.nationalgeographic.com/environment/natural-disasters/landslides/'),
            _buildLink('FEMA: Landslide Preparedness', 'https://www.fema.gov/press-release/20210318/landslide-preparedness'),
            _buildLink('USGS: Landslides', 'https://www.usgs.gov/natural-hazards/landslide-hazards'),
          ],
        ),
      ),
    );
  }

  Widget _buildLink(String text, String url) {
    return InkWell(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Text(
        text,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 16,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
