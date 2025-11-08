import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver.dart';

// 5. Fișierul nou pe care l-am creat

class DriverTrackingScreen extends StatefulWidget {
  final DriverRoute driver;
  const DriverTrackingScreen({super.key, required this.driver});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  final Set<Marker> _markers = {};
  BitmapDescriptor _carIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  // Funcție pentru a seta marker-ul mașinii
  void _setMarkers() {
    // Într-o aplicație reală, ai folosi o imagine personalizată
    // Dar pentru hackathon, folosim un marker standard colorat
    _carIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(widget.driver.licensePlate),
          position: widget.driver.startLocation, // Folosim locația din model
          infoWindow: InfoWindow(
            title: widget.driver.name,
            snippet: widget.driver.carModel,
          ),
          icon: _carIcon,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Urmărește pe ${widget.driver.name}"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.driver.startLocation, // Centrează harta pe mașină
          zoom: 15,
        ),
        markers: _markers,
      ),
    );
  }
}