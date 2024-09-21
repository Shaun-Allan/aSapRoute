import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class ResourcePage extends StatefulWidget {
  const ResourcePage({Key? key}) : super(key: key);

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _resources = [];
  List<Map<String, dynamic>> _filteredResources = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchResources();
    _searchController.addListener(_searchResources);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchResources);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchResources() async {
    try {
      final snapshot = await _databaseReference.get();

      if (snapshot.value == null) {
        print('No data available');
        setState(() {
          _resources = [];
          _filteredResources = [];
        });
        return;
      }

      // Use safe casting to handle unexpected types
      final data = Map<String, dynamic>.from(
        snapshot.value as Map<dynamic, dynamic>? ?? {},
      );

      final resources = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        print('Processing key: $key'); // Debugging statement
        final sheet = value['Sheet1'] ?? [];
        for (var item in sheet) {
          try {
            print('Processing item: $item'); // Debugging statement
            final resource = Map<String, dynamic>.from(item);

            // Filter out resources where essential fields are empty or S NO is missing
            if (_isValidResource(resource)) {
              resources.add(resource);
            } else {
              print('Invalid resource: $resource'); // Debugging statement
            }
          } catch (e) {
            print('Error processing item: $item'); // Debugging statement
            print('Exception: $e'); // Debugging statement
          }
        }
      });

      setState(() {
        _resources = resources;
        _filteredResources = resources;
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _resources = [];
        _filteredResources = [];
      });
    }
  }

  bool _isValidResource(Map<String, dynamic> resource) {
    return resource['S NO'] != null &&
        resource['S NO'].toString().trim().isNotEmpty &&
        resource['RESOURCE NAME']?.toString().trim().isNotEmpty == true &&
        resource['QTY']?.toString().trim().isNotEmpty == true &&
        resource['STATE & DISTRICT']?.toString().trim().isNotEmpty == true;
  }

  void _searchResources() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResources = _resources.where((resource) {
        final district = resource['STATE & DISTRICT']?.toString().toLowerCase() ?? '';
        return district.contains(query);
      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by district',
                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: _filteredResources.isEmpty
                    ? Center(
                  child: Text(
                    'No resources found',
                    style: GoogleFonts.lato(fontSize: 16.0, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredResources.length,
                  itemBuilder: (context, index) {
                    final resource = _filteredResources[index];
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.0),
                        title: Text(
                          _getItemName(resource['RESOURCE NAME']),
                          style: GoogleFonts.lato(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (resource['QTY'] != null)
                              Text('Qty: ${resource['QTY']}', style: GoogleFonts.lato(fontSize: 14.0)),
                            if (resource['STATE & DISTRICT'] != null)
                              Text('District: ${_getDistrict(resource['STATE & DISTRICT'])}', style: GoogleFonts.lato(fontSize: 14.0)),
                            if (resource['DEPARTMENT AGENCY DETAILS'] != null) ...[
                              Text('Contact Person: ${_extractField(resource['DEPARTMENT AGENCY DETAILS'], 'CONTACT PERSON : ')}', style: GoogleFonts.lato(fontSize: 14.0)),
                              Text('Contact No: ${_extractField(resource['DEPARTMENT AGENCY DETAILS'], 'CONTACT NO. : ')}', style: GoogleFonts.lato(fontSize: 14.0)),
                              Text('Email ID: ${_extractField(resource['DEPARTMENT AGENCY DETAILS'], 'EMAIL ID : ')}', style: GoogleFonts.lato(fontSize: 14.0)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }

  String _getItemName(String? resourceName) {
    if (resourceName == null) return 'Unknown';
    final parts = resourceName.split('ITEM : ');
    return parts.length > 1 ? parts.last.trim() : 'Unknown';
  }

  String _getDistrict(String stateAndDistrict) {
    final parts = stateAndDistrict.split('DISTRICT : ');
    return parts.length > 1 ? parts.last.trim() : 'N/A';
  }

  String _extractField(String details, String field) {
    final startIndex = details.indexOf(field);
    if (startIndex == -1) return 'N/A';
    final start = startIndex + field.length;
    final endIndex = details.indexOf('\n', start);
    return endIndex == -1 ? details.substring(start).trim() : details.substring(start, endIndex).trim();
  }
}
