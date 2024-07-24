import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;

class Relief extends StatefulWidget {
  const Relief({super.key});

  @override
  State<Relief> createState() => _ReliefState();
}

class _ReliefState extends State<Relief> {
  late Future<String> geoJsonData;

  @override
  void initState() {
    super.initState();
    geoJsonData = _loadGeoJson();
  }

  Future<String> _loadGeoJson() async {
    return await rootBundle.loadString('assets/DISTRICT_BOUNDARIES.geojson');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relief Map')),
      body: FutureBuilder<String>(
        future: geoJsonData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(26.2006, 92.9376), // Center of Assam
                initialZoom: 7.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                // Add your GeoJSON layer here
              ],
            );
          }
        },
      ),
    );
  }
}
