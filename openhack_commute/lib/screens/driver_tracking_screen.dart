import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver.dart';

// Acest fișier este "lib/screens/driver_tracking_screen.dart"

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
          // TODO: Aici ar trebui să fie locația LIVE a șoferului
          // Pentru demo, folosim locația de start a șoferului
          position: widget.driver.startLocation,
          infoWindow: InfoWindow(
            title: widget.driver.name,
            snippet: widget.driver.carModel,
          ),
          icon: _carIcon,
          // Poți adăuga 'rotation' dacă ai ști direcția mașinii
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
        // TODO: Într-o aplicație reală, ai actualiza poziția marker-ului
        // folosind un Stream din Firebase (ex. Firestore.snapshots())
      ),
    );
  }
}