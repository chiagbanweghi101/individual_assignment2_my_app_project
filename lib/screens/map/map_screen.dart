import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/listing_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingProvider>().allListings;
    final markers = listings
        .map(
          (item) => Marker(
            point: LatLng(item.latitude, item.longitude),
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.redAccent,
              size: 32,
            ),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: listings.isEmpty
          ? const Center(
              child: Text(
                'No map points to display yet.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: _kigaliCenter,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.my_app_project',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
    );
  }
}
