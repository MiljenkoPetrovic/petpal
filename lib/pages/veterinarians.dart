import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class Veterinarians extends StatefulWidget {
  @override
  _VeterinariansState createState() => _VeterinariansState();
}

class _VeterinariansState extends State<Veterinarians> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  // User's current location
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    // Get the user's current location and set it as the initial map location.
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    final Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });

    // Animate the camera to the user's location
    if (_controller != null && _userLocation != null) {
      _controller!.animateCamera(CameraUpdate.newLatLng(_userLocation!));

      // Add a marker for the user's location (green)
      _markers.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: _userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen), // Green marker
          infoWindow: InfoWindow(
            title: "Your Location",
          ),
        ),
      );

      // Fetch and add nearby vet stations (red markers)
      fetchVetStations();
    }
  }

  Future<void> fetchVetStations() async {
    final apiKey = "AIzaSyC7SakPUeqpvKg_FDXqNPfnhZKAmt2MTOI";
    final location = "${_userLocation!.latitude},${_userLocation!.longitude}";
    final radius = "5000"; // Radius in meters (adjust as needed).
    final type =
        "veterinary_care"; // Use the appropriate type for vet stations.

    final apiUrl =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=$radius&type=$type&key=$apiKey";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;

      for (var place in results) {
        final geometry = place['geometry'];
        final location = geometry['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        final name = place['name'];

        // Add a red marker for each vet station
        _markers.add(
          Marker(
            markerId: MarkerId(lat.toString() + lng.toString()),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed), // Red marker
            infoWindow: InfoWindow(
              title: name,
            ),
          ),
        );
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
              0, 0), // Default to (0,0) until we get the user's location.
          zoom: 14,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }
}
