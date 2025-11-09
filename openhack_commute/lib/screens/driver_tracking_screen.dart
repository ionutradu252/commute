import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui; // Pentru interpolare (lerp)
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Pentru calculul direcției
import '../models/driver.dart';
import '../widgets/rating_bottom_sheet.dart';

// CHEIA TA API GOOGLE
const String kGoogleApiKey = "AIzaSyDBTi9UursOW0kbzgIWy87WPgYCDxx39F0";

enum JourneyStage {
  waitingForDriver,
  inRide,
  arrived,
}

class DriverTrackingScreen extends StatefulWidget {
  final DriverRoute driver;
  const DriverTrackingScreen({super.key, required this.driver});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

// 1. Am ȘTERS 'with SingleTickerProviderStateMixin'
class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor _carIcon = BitmapDescriptor.defaultMarker;

  // --- MODIFICARE: Am înlocuit AnimationController cu Timer ---
  Timer? _animationTimer;
  final Stopwatch _stopwatch = Stopwatch(); // Pentru a urmări progresul
  // --- ---

  JourneyStage _currentStage = JourneyStage.waitingForDriver;
  String _etaMessage = "Se calculează ruta...";
  LatLng? _driverPosition;
  List<LatLng> _driverPolylinePoints = [];
  final int _rideDurationInSeconds = 60; // Durata simulării

  @override
  void initState() {
    super.initState();
    _driverPosition = widget.driver.startLocation;
    _loadResourcesAndStart();
  }

  Future<void> _loadResourcesAndStart() async {
    _carIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    await _fetchAndDrawDriverRoute();
    _startAnimation(); // Pornim animația bazată pe Timer
  }

  Future<void> _fetchAndDrawDriverRoute() async {
    // ... (Funcția rămâne neschimbată) ...
    final driverUrl = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${widget.driver.startLocation.latitude},${widget.driver.startLocation.longitude}"
        "&destination=${widget.driver.endLocation.latitude},${widget.driver.endLocation.longitude}"
        "&mode=driving&key=$kGoogleApiKey");

    try {
      final response = await http.get(driverUrl);
      final data = json.decode(response.body);

      if (data["routes"].isNotEmpty) {
        final points = PolylinePoints()
            .decodePolyline(data["routes"][0]["overview_polyline"]["points"]);
        _driverPolylinePoints =
            points.map((p) => LatLng(p.latitude, p.longitude)).toList();

        _polylines.add(Polyline(
          polylineId: const PolylineId("driver_route"),
          color: Colors.blueAccent,
          width: 5,
          points: _driverPolylinePoints,
        ));

        _markers.add(Marker(
          markerId: MarkerId(widget.driver.licensePlate),
          position: _driverPosition!,
          icon: _carIcon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
        ));

        _markers.add(Marker(
          markerId: const MarkerId("destination"),
          position: widget.driver.endLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));

        setState(() {});

        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            _getBounds(_driverPolylinePoints), 50.0),
        );
      }
    } catch (e) {
      print("Eroare la desenarea rutei șoferului: $e");
    }
  }

  // --- MODIFICARE: Funcția de animație folosește Timer ---
  void _startAnimation() {
    _stopwatch.start(); // Pornim cronometrul
    _animationTimer = Timer.periodic(const Duration(milliseconds: 100), _updateSimulation); // Rulează de 10 ori/sec
  }

  // --- MODIFICARE: Funcția de update primește un Timer ---
  void _updateSimulation(Timer timer) {
    if (_driverPolylinePoints.isEmpty) return;

    // Calculăm progresul animației
    final double t = _stopwatch.elapsedMilliseconds /
        (_rideDurationInSeconds * 1000);

    if (t >= 1.0) {
      _onAnimationComplete(timer); // Am ajuns
      return;
    }

    int index = (t * (_driverPolylinePoints.length - 1)).floor();
    if (index < 0) index = 0;
    if (index > _driverPolylinePoints.length - 2) {
      index = _driverPolylinePoints.length - 2;
    }

    final LatLng pos1 = _driverPolylinePoints[index];
    final LatLng pos2 = _driverPolylinePoints[index + 1];
    
    final double localT = (t * _driverPolylinePoints.length) % 1.0;
    _driverPosition = LatLng(
      ui.lerpDouble(pos1.latitude, pos2.latitude, localT)!,
      ui.lerpDouble(pos1.longitude, pos2.longitude, localT)!,
    );

    final double bearing = Geolocator.bearingBetween(
      pos1.latitude, pos1.longitude,
      pos2.latitude, pos2.longitude,
    );

    // Actualizăm ETA
    final remainingTime = _rideDurationInSeconds * (1.0 - t);
    setState(() {
      if (remainingTime < 2) {
        _currentStage = JourneyStage.inRide;
        _etaMessage = "Aproape ați ajuns...";
      } else if (t > 0.1) {
        _currentStage = JourneyStage.inRide;
        _etaMessage = "ETA: ${remainingTime.toStringAsFixed(0)} secunde";
      } else {
        _currentStage = JourneyStage.waitingForDriver;
        _etaMessage = "Șoferul pornește...";
      }
      // Actualizăm marker-ul (doar de 10 ori/sec, nu 60)
      _updateDriverMarker(_driverPosition!, bearing);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        _driverPosition!,
      ),
    );
  }

  // --- MODIFICARE: Funcția de final primește Timer-ul pentru a-l opri ---
  void _onAnimationComplete(Timer timer) {
    timer.cancel();
    _stopwatch.stop();

    setState(() {
      _currentStage = JourneyStage.arrived;
      _etaMessage = "Ați ajuns la destinație!";
    });
    _showRatingSheet();
  }

  // --- MODIFICARE: Funcția de rating așteaptă un rezultat ---
  void _showRatingSheet() async {
    // Așteptăm rezultatul de la panoul de rating
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return RatingBottomSheet(driver: widget.driver);
      },
    );

    // --- MODIFICARE: Gestionăm feedback-ul și navigarea ---
    if (result == true && mounted) {
      // 1. Arată SnackBar-ul (Tooltip)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mulțumim pentru feedback!"),
          backgroundColor: Colors.green,
        ),
      );

      // 2. Așteaptă 1 secundă ca utilizatorul să vadă mesajul
      await Future.delayed(const Duration(seconds: 1));

      // 3. Închide acest ecran
      Navigator.of(context).pop();
      // 4. Închide și ecranul anterior (DriverProfileScreen)
      Navigator.of(context).pop();
      // (Acum utilizatorul este înapoi la PassengerHomeScreen)
    }
  }

  void _updateDriverMarker(LatLng newPosition, double bearing) {
    _markers.removeWhere(
        (m) => m.markerId == MarkerId(widget.driver.licensePlate));
    _markers.add(
      Marker(
        markerId: MarkerId(widget.driver.licensePlate),
        position: newPosition,
        icon: _carIcon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: bearing,
      ),
    );
    // Nu mai este nevoie de setState aici, se face în _updateSimulation
  }

  IconData _getStageIcon(JourneyStage stage) {
    // ... (Funcția rămâne neschimbată) ...
    switch (stage) {
      case JourneyStage.waitingForDriver: return Icons.directions_walk;
      case JourneyStage.inRide: return Icons.time_to_leave;
      case JourneyStage.arrived: return Icons.check_circle;
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    // ... (Funcția rămâne neschimbată) ...
    double minLat = points.first.latitude,
           minLng = points.first.longitude,
           maxLat = points.first.latitude,
           maxLng = points.first.longitude;
    for (var point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    return LatLngBounds(
        southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  @override
  void dispose() {
    _animationTimer?.cancel(); // Oprim timer-ul
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI-ul (build method) rămâne neschimbat) ...
    return Scaffold(
      appBar: AppBar(
        title: Text("Urmărește pe ${widget.driver.name}"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.driver.startLocation,
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            buildingsEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.driver.profilePicUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.driver.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                  "${widget.driver.carModel} • ${widget.driver.licensePlate}",
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(_getStageIcon(_currentStage),
                            color: Colors.teal, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _etaMessage, // Mesajul dinamic
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              if (_currentStage == JourneyStage.arrived)
                                Text("Vă mulțumim că ați folosit Commute!",
                                    style: TextStyle(color: Colors.grey[600]))
                              else
                                Text("Către: ${widget.driver.endLocation.latitude.toStringAsFixed(2)}, ${widget.driver.endLocation.longitude.toStringAsFixed(2)}",
                                    style: TextStyle(color: Colors.grey[600]))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}