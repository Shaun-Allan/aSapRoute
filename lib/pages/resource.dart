import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ngo_repository.dart';
import '../model/ngo_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ResourcePage extends StatefulWidget {
  const ResourcePage({super.key});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  late Future<List<NgoModel>> _ngoFuture;
  List<NgoModel> _filteredNgos = [];
  String _searchCity = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ngoFuture = NgoRepository().getNgoDetails();
  }

  void _filterNgos(String city) {
    setState(() {
      _searchCity = city.toLowerCase();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _openMap(String address) async {
    final Uri launchUri = Uri(
      scheme: 'geo',
      path: '0,0',
      queryParameters: {'q': address},
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not open map for $address';
    }
  }

  void _showHelplineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Helplines',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _helplineTile('NATIONAL EMERGENCY NUMBER', '112'),
              _helplineTile('POLICE', '100'),
              _helplineTile('FIRE', '101'),
              _helplineTile('AMBULANCE', '102'),
              _helplineTile('Disaster Management Services', '108'),
              _helplineTile('N.D.M.A', '01126701728'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar to input city name
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by City',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) {
                _filterNgos(value);
              },
            ),
            const SizedBox(height: 20),

            // FutureBuilder for NGO data
            FutureBuilder<List<NgoModel>>(
              future: _ngoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final ngos = snapshot.data!;
                  _filteredNgos = ngos.where((ngo) {
                    return ngo.address.toLowerCase().contains(_searchCity);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NGOs',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredNgos.length,
                        itemBuilder: (context, index) {
                          final ngo = _filteredNgos[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0), // Space between cards
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.business, // You can choose an appropriate icon for NGOs
                                  color: Colors.blueAccent,
                                  size: 30, // Adjusted size for better visual appeal
                                ),
                                const SizedBox(width: 12.0), // Increased spacing
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ngo.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0), // Space between name and address
                                      GestureDetector(
                                        onTap: () => _openMap(ngo.address),
                                        child: Text(
                                          ngo.address,
                                          style: GoogleFonts.poppins(
                                            color: Colors.blue, // Make it visually indicate it's clickable
                                            fontSize: 14,
                                            decoration: TextDecoration.underline,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 6.0), // Space between address and phone
                                      Row(
                                        children: [
                                          Icon(Icons.phone, color: Colors.green),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => _makePhoneCall(ngo.phone),
                                            child: Text(
                                              ngo.phone,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8.0), // Space before the chevron

                              ],
                            ),
                          );
                        },
                      ),



                    ],
                  );
                } else {
                  return const Center(child: Text('No NGOs available'));
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _showHelplineDialog,
        child: const Icon(Icons.phone, color: Colors.white),
      ),
    );
  }

  Widget _helplineTile(String title, String phoneNumber) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: GestureDetector(
        onTap: () => _makePhoneCall(phoneNumber),
        child: const Icon(Icons.call, color: Colors.blue),
      ),
    );
  }
}
