import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Veterinarians extends StatefulWidget {
  const Veterinarians({super.key});

  @override
  State<Veterinarians> createState() => VeterinariansState();
}

class VeterinariansState extends State<Veterinarians> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _kGoogle = CameraPosition(
    target: LatLng(0, 0), // Default to (0,0).
    zoom: 14,
  );

  // on below line we have created the list of markers
  final List<Marker> _markers = <Marker>[
    Marker(
      markerId: MarkerId('1'),
      position: LatLng(20.42796133580664, 75.885749655962),
      infoWindow: InfoWindow(
        title: 'My Position',
      ),
    ),
  ];

  // updated method for getting user current location
  Future<void> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    final Position position = await Geolocator.getCurrentPosition();
    print(position.latitude.toString() + " " + position.longitude.toString());

    // Set the initial camera position to the user's location.
    setState(() {
      _kGoogle = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14,
      );

      // Marker added for the current user's location.
      _markers.add(
        Marker(
          markerId: MarkerId("2"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: 'My Current Location',
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // Call getUserCurrentLocation when the widget initializes.
    getUserCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0F9D58),
        // on below line we have given title of the app
        title: Text("GFG"),
      ),
      body: FutureBuilder<void>(
        future: getUserCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return _buildGoogleMap();
          }
        },
      ),
    );
  }

  Widget _buildGoogleMap() {
    return Container(
      child: SafeArea(
        // on below line creating google maps
        child: GoogleMap(
          // on below line setting camera position
          initialCameraPosition: _kGoogle,
          // on below line we are setting markers on the map
          markers: Set<Marker>.of(_markers),
          // on below line specifying map type.
          mapType: MapType.normal,
          // on below line setting user location enabled.
          myLocationEnabled: true,
          // on below line setting compass enabled.
          compassEnabled: true,
          // on below line specifying controller on map complete.
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
