import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlansAndSubscriptions extends StatefulWidget {
  const PlansAndSubscriptions({super.key});

  @override
  State<PlansAndSubscriptions> createState() => _PlansAndSubscriptionsState();
}

class _PlansAndSubscriptionsState extends State<PlansAndSubscriptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Plans & Subscriptions",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // For back button color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Section
            Text(
              "Current Plan",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 10),
            FreePlanCard(
              title: "Free Plan",
              monthlyPrice: '\u{20B9}0',
              yearlyPrice: '\u{20B9}0',
              features: ["Supported up to 1 device", "Basic features included", "Feature 3", "Feature 4"],
              trialsRemaining: 3,
            ),
            Divider(
              thickness: 2,
              height: 40,
            ),
            // Upgrade your plan Section
            Text(
              "Upgrade your plan",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            PlanCard(
              title: "Wholesale",
              monthlyPrice: '\u{20B9}200',
              yearlyPrice: '\u{20B9}2000',
              features: ["Supported up to 15 devices", "Ideal for fleet management and logistics", "Feature 3", "Feature 4"],
            ),
            SizedBox(height: 20),
            PlanCard(
              title: "Regular",
              monthlyPrice: '\u{20B9}50',
              yearlyPrice: '\u{20B9}500',
              features: ["Supported up to 5 devices", "Ideal for tourists and families", "Feature 3", "Feature 4"],
            ),
            SizedBox(height: 20),
            PlanCard(
              title: "Individual",
              monthlyPrice: '\u{20B9}30',
              yearlyPrice: '\u{20B9}300',
              features: ["Supported up to 1 device", "Ideal for individuals", "Feature 3", "Feature 4"],
            ),
          ],
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String monthlyPrice;
  final String yearlyPrice;
  final List<String> features;

  const PlanCard({
    required this.title,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: (){},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "$monthlyPrice/month",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    "$yearlyPrice/year",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features
                    .map((feature) => Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                  ],
                ))
                    .toList(),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class FreePlanCard extends StatelessWidget {
  final String title;
  final String monthlyPrice;
  final String yearlyPrice;
  final List<String> features;
  final int trialsRemaining;

  const FreePlanCard({
    required this.title,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.trialsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        color: Colors.blueGrey[50],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Number of trials remaining: $trialsRemaining",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
