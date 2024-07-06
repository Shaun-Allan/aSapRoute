import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
            // Current Plan Section
            Text(
              "Current Plan",
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 10),
            FreePlanCard(
              title: "Free Plan",
              monthlyPrice: '\u{20B9}0',
              yearlyPrice: '\u{20B9}0',
              features: [
                "Supported up to 1 device",
                "Basic features included",
                "Feature 3",
                "Feature 4"
              ],
              trialsRemaining: 3,
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

class PlanCard extends StatefulWidget {
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
  _PlanCardState createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  late Razorpay _razorpay;

  // void openCheckout(amount) async{
  //   amount = amount*100;
  //   var options = {
  //
  //   }
  // }

  String selectedDuration = 'monthly'; // Default to monthly
  bool monthlySelected = true;
  bool yearlySelected = false;
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: widget.isExpanded ? 440 : 250, // Adjust height as needed
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "${widget.monthlyPrice}/month",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "${widget.yearlyPrice}/year",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.features
                      .map((feature) => Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                    ],
                  ))
                      .toList(),
                ),
                SizedBox(height: 0),
                widget.isExpanded
                    ? Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedDuration = 'monthly';
                                  monthlySelected = true;
                                  yearlySelected = false;
                                });
                              },
                              child: Container(
                                width: sw/3,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: monthlySelected ? Color.fromARGB(255, 0, 80, 0) : Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly',
                                      style: GoogleFonts.montserrat(
                                        color: monthlySelected ? Color.fromARGB(255, 0, 35, 0) : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        "${widget.monthlyPrice}",
                                        style: GoogleFonts.poppins(
                                          color: monthlySelected ? Color.fromARGB(255, 0, 100, 0) : Colors.grey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedDuration = 'yearly';
                                  monthlySelected = false;
                                  yearlySelected = true;
                                });
                              },
                              child: Container(
                                width: sw/3,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: yearlySelected ? Color.fromARGB(255, 0, 80, 0) : Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Yearly',
                                      style: GoogleFonts.montserrat(
                                        color: yearlySelected ? Color.fromARGB(255, 0, 35, 0) : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        "${widget.yearlyPrice}",
                                        style: GoogleFonts.poppins(
                                            color: yearlySelected ? Color.fromARGB(255, 0, 100, 0) : Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 24
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: MediaQuery.of(context).size.width-100, // Set the desired width
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle Choose Plan button tap
                          },
                          child: Text(
                              'Payment',
                              style: GoogleFonts.poppins(
                                fontSize: 18
                              )
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: Color.fromARGB(200, 34, 139, 34), // Text color
                            foregroundColor: Colors.white,
                            side: BorderSide.none, // Border color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50), // Rounded borders
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FreePlanCard extends StatefulWidget {
  final String title;
  final String monthlyPrice;
  final String yearlyPrice;
  final List<String> features;
  final int trialsRemaining;
  final VoidCallback onTap;
  final bool isExpanded;

  const FreePlanCard({
    required this.title,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.trialsRemaining,
    required this.onTap,
    required this.isExpanded,
  });

  @override
  State<FreePlanCard> createState() => _FreePlanCardState();
}

class _FreePlanCardState extends State<FreePlanCard> {
  String selectedDuration = 'monthly'; // Default to monthly
  bool monthlySelected = true;
  bool yearlySelected = false;
  @override
  Widget build(BuildContext context) {

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: widget.isExpanded ? 100 : 100, // Adjust height as needed
      child: Container(
        width: double.infinity,
        child: Card(
          color: Colors.blueGrey[50],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Number of trials remaining: ${widget.trialsRemaining}",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
