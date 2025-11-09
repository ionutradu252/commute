import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/driver.dart';
import '../widgets/rating_bottom_sheet.dart';

const String kGoogleApiKey = "AIzaSyDBTi9UursOW0kbzgIWy87WPgYCDxx39F0";

class DriverRideSimulationScreen extends StatefulWidget {
  final DriverRoute driver;
  final List<LatLng> passengerPickups;
  final LatLng finalDestination;

  const DriverRideSimulationScreen({
    super.key,
    required this.driver,
    required this.passengerPickups,
    required this.finalDestination,
  });

  @override
  State<DriverRideSimulationScreen> createState() =>
      _DriverRideSimulationScreenState();
}

class _DriverRideSimulationScreenState
    extends State<DriverRideSimulationScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor _carIcon = BitmapDescriptor.defaultMarker;

  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  List<LatLng> _routePoints = [];
  LatLng? _carPosition;
  String _statusMessage = "Pornim cursa...";
  final int simulationDurationSeconds = 60;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
    _fetchFullRoute();
  }

  Future<void> _loadCarIcon() async {
    final bitmap = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(32, 32)),
      'assets/car.png',
    );
    setState(() => _carIcon = bitmap);
  }

  Future<void> _fetchFullRoute() async {
    final stops = [
      widget.driver.startLocation,
      ...widget.passengerPickups,
      widget.finalDestination,
    ];

    for (int i = 0; i < stops.length - 1; i++) {
      final segment = await _fetchRouteSegment(stops[i], stops[i + 1]);
      _routePoints.addAll(segment);

      if (i != 0 && i < stops.length - 1) {
        _markers.add(Marker(
          markerId: MarkerId("pickup_$i"),
          position: stops[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Pasager $i"),
        ));
      }
    }

    _markers.addAll([
      Marker(
        markerId: const MarkerId("start"),
        position: widget.driver.startLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "Start"),
      ),
      Marker(
        markerId: const MarkerId("end"),
        position: widget.finalDestination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: const InfoWindow(title: "Destinație finală"),
      ),
    ]);

    _polylines.add(Polyline(
      polylineId: const PolylineId("full_route"),
      color: Colors.blue,
      width: 5,
      points: _routePoints,
    ));

    _carPosition = widget.driver.startLocation;
    _updateCarMarker(_carPosition!, 0);

    setState(() {});
    _startAnimation();
  }

  Future<List<LatLng>> _fetchRouteSegment(LatLng from, LatLng to) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${from.latitude},${from.longitude}"
      "&destination=${to.latitude},${to.longitude}"
      "&mode=driving&key=$kGoogleApiKey",
    );
    final resp = await http.get(url);
    final data = json.decode(resp.body);
    if (data["routes"].isEmpty) return [];
    final pts = PolylinePoints()
        .decodePolyline(data["routes"][0]["overview_polyline"]["points"]);
    return pts.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }

  void _startAnimation() {
    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _updateSimulation);
  }

  void _updateSimulation(Timer timer) {
    if (_routePoints.isEmpty) return;

    double t = _stopwatch.elapsedMilliseconds / (simulationDurationSeconds * 1000);

    if (t >= 1) {
      _timer?.cancel();
      _stopwatch.stop();
      _carPosition = _routePoints.last;
      _updateCarMarker(_carPosition!, 0);
      _statusMessage = "Cursa completă 🚗";
      _showRatingSheet();
      setState(() {});
      return;
    }

    double total = _routePoints.length - 1;
    double exactIndex = t * total;
    int i = exactIndex.floor();
    double localT = exactIndex - i;

    final p1 = _routePoints[i];
    final p2 = _routePoints[(i + 1).clamp(0, _routePoints.length - 1)];

    _carPosition = LatLng(
      ui.lerpDouble(p1.latitude, p2.latitude, localT)!,
      ui.lerpDouble(p1.longitude, p2.longitude, localT)!,
    );

    final bearing = Geolocator.bearingBetween(
        p1.latitude, p1.longitude, p2.latitude, p2.longitude);

    int passengerIndex = (t * widget.passengerPickups.length).floor();
    if (passengerIndex < widget.passengerPickups.length) {
      _statusMessage = "În drum spre pasager ${passengerIndex + 1}...";
    } else {
      _statusMessage = "Transport pasageri către destinație...";
    }

    _updateCarMarker(_carPosition!, bearing);
    _mapController?.animateCamera(CameraUpdate.newLatLng(_carPosition!));
    setState(() {});
  }

  void _updateCarMarker(LatLng pos, double bearing) {
    _markers.removeWhere((m) => m.markerId == const MarkerId("car"));
    _markers.add(Marker(
      markerId: const MarkerId("car"),
      position: pos,
      icon: _carIcon,
      flat: true,
      rotation: bearing,
      anchor: const Offset(0.5, 0.5),
    ));
  }

  void _showRatingSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RatingBottomSheet(driver: widget.driver),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cursa lui ${widget.driver.name}")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: widget.driver.startLocation, zoom: 14),
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(widget.driver.profilePicUrl)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_statusMessage,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}