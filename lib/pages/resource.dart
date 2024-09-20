import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ngo_repository.dart';
import '../model/ngo_model.dart';

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
          title: const Text('Helplines'),
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
      appBar: AppBar(
        title: const Text('NGO Resources'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Search bar to input city name
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by City',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterNgos(value);
              },
            ),
            const SizedBox(height: 20),

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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredNgos.length,
                        itemBuilder: (context, index) {
                          final ngo = _filteredNgos[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ngo.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.redAccent),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _openMap(ngo.address),
                                            child: Text(
                                              ngo.address,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, color: Colors.green),
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
        onPressed: _showHelplineDialog,
        child: const Icon(Icons.phone),
      ),
    );
  }

  Widget _helplineTile(String title, String phoneNumber) {
    return ListTile(
      title: Text(title),
      trailing: GestureDetector(
        onTap: () => _makePhoneCall(phoneNumber),
        child: const Icon(Icons.call, color: Colors.blue),
      ),
    );
  }
}
