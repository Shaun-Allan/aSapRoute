import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'api.dart'; // Import the API page here

class PlansAndSubscriptions extends StatefulWidget {
  const PlansAndSubscriptions({Key? key}) : super(key: key);

  @override
  State<PlansAndSubscriptions> createState() => _PlansAndSubscriptionsState();
}

class _PlansAndSubscriptionsState extends State<PlansAndSubscriptions> {
  String? expandedPlan;

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
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Section with Arrow Mark and Navigation
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "API",
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Details about API usage and integration...",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                ),
                onTap: () {
                  // Navigate to the API page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => APIPage()),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Advertisement Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Advertisements",
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your advertisement content or banners go here...",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Subscription Plans Section
            Text(
              "Current Plan",
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 10),
            PlanCard(
              title: "Free Plan",
              monthlyPrice: '\u{20B9}0',
              yearlyPrice: '\u{20B9}0',
              features: [
                "Supported up to 1 device",
                "Basic features included",
                "Feature 3",
                "Feature 4"
              ],
              onTap: () {
                setState(() {
                  expandedPlan = "free";
                });
              },
              isExpanded: expandedPlan == "free",
            ),
            Divider(
              thickness: 2,
              height: 60,
            ),

            // Upgrade your plan Section
            Text(
              "Upgrade your plan",
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 20),
            PlanCard(
              title: "Wholesale",
              monthlyPrice: '\u{20B9}200',
              yearlyPrice: '\u{20B9}2000',
              features: [
                "Supported up to 15 devices",
                "Ideal for fleet managements",
                "Feature 3",
                "Feature 4"
              ],
              onTap: () {
                setState(() {
                  expandedPlan = "wholesale";
                });
              },
              isExpanded: expandedPlan == "wholesale",
            ),
            SizedBox(height: 20),
            PlanCard(
              title: "Regular",
              monthlyPrice: '\u{20B9}50',
              yearlyPrice: '\u{20B9}500',
              features: [
                "Supported up to 5 devices",
                "Ideal for tourists and families",
                "Feature 3",
                "Feature 4"
              ],
              onTap: () {
                setState(() {
                  expandedPlan = "regular";
                });
              },
              isExpanded: expandedPlan == "regular",
            ),
            SizedBox(height: 20),
            PlanCard(
              title: "Individual",
              monthlyPrice: '\u{20B9}30',
              yearlyPrice: '\u{20B9}300',
              features: [
                "Supported up to 1 device",
                "Ideal for individuals",
                "Feature 3",
                "Feature 4"
              ],
              onTap: () {
                setState(() {
                  expandedPlan = "individual";
                });
              },
              isExpanded: expandedPlan == "individual",
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
    final VoidCallback onTap;
    final bool isExpanded;

    const PlanCard({
      required this.title,
      required this.monthlyPrice,
      required this.yearlyPrice,
      required this.features,
      required this.onTap,
      required this.isExpanded,
    });

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Monthly: $monthlyPrice",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                Text(
                  "Yearly: $yearlyPrice",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 10),
                if (isExpanded)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features.map((feature) => Text("- $feature")).toList(),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
