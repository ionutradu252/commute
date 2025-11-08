import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/driver.dart';
import 'driver_tracking_screen.dart';
import 'driver_reviews_screen.dart'; // 👈 adăugat pentru recenzii

const String kGoogleApiKey = "AIzaSyDBTi9UursOW0kbzgIWy87WPgYCDxx39F0";

class DriverProfileScreen extends StatefulWidget {
  final DriverRoute driver;
  final LatLng? passengerDestination;
  final String? passengerDestinationLabel;

  const DriverProfileScreen({
    super.key,
    required this.driver,
    this.passengerDestination,
    this.passengerDestinationLabel,
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  GoogleMapController? _controller;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  LatLng? _currentPosition;
  LatLng? _pickupPoint;
  LatLng? _dropPoint;
  late LatLng _finalDestination;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _finalDestination = widget.passengerDestination ?? widget.driver.endLocation;
    _initLocationAndRoute();
  }

  Future<void> _initLocationAndRoute() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permite locația pentru a continua')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      await _drawRoute();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la inițializare: $e')),
      );
    }
  }

  double _distanceBetween(LatLng a, LatLng b) {
    const double R = 6371000;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final h = pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);
    return 2 * R * asin(sqrt(h));
  }

  Future<void> _drawRoute() async {
    if (_currentPosition == null) return;

    setState(() {
      isLoading = true;
      _polylines.clear();
      _markers.clear();
      _pickupPoint = null;
      _dropPoint = null;
    });

    // 1) Ruta șoferului
    final driverUrl = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${widget.driver.startLocation.latitude},${widget.driver.startLocation.longitude}"
      "&destination=${widget.driver.endLocation.latitude},${widget.driver.endLocation.longitude}"
      "&mode=driving&key=$kGoogleApiKey",
    );

    final driverResp = await http.get(driverUrl);
    final driverData = json.decode(driverResp.body);
    if (driverData["routes"].isEmpty) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(driverData["error_message"] ?? "Ruta șoferului nu a fost găsită")),
      );
      return;
    }

    final driverPts = PolylinePoints().decodePolyline(
      driverData["routes"][0]["overview_polyline"]["points"],
    );
    final driverPolyline = driverPts.map((p) => LatLng(p.latitude, p.longitude)).toList();

    // 2) Cel mai apropiat punct de pasager -> pickupPoint
    double minDistPickup = double.infinity;
    for (final p in driverPolyline) {
      final d = _distanceBetween(_currentPosition!, p);
      if (d < minDistPickup) {
        minDistPickup = d;
        _pickupPoint = p;
      }
    }

    // 3) Cel mai apropiat punct de destinația pasagerului -> dropPoint
    double minDistDrop = double.infinity;
    for (final p in driverPolyline) {
      final d = _distanceBetween(_finalDestination, p);
      if (d < minDistDrop) {
        minDistDrop = d;
        _dropPoint = p;
      }
    }

    // 4) Desenăm rutele
    _polylines.add(Polyline(
      polylineId: const PolylineId("driver_route"),
      color: Colors.blue,
      width: 6,
      points: driverPolyline,
    ));

    // mers pe jos până la pickup (verde punctat)
    if (_pickupPoint != null) {
      await _addWalkingPolyline(
        from: _currentPosition!,
        to: _pickupPoint!,
        id: const PolylineId("walking_to_pickup"),
        color: Colors.green,
      );
    }

    // mers pe jos de la drop până la destinație (mov punctat)
    if (_dropPoint != null) {
      final needWalk = _distanceBetween(_dropPoint!, _finalDestination) > 10;
      if (needWalk) {
        await _addWalkingPolyline(
          from: _dropPoint!,
          to: _finalDestination,
          id: const PolylineId("walking_from_drop"),
          color: Colors.purple,
        );
      }
    }

    // 5) Markere
    _markers.addAll([
      Marker(
        markerId: const MarkerId("me"),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: "Tu"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId("driver_start"),
        position: widget.driver.startLocation,
        infoWindow: InfoWindow(title: "Start ${widget.driver.name}"),
      ),
      Marker(
        markerId: const MarkerId("driver_end"),
        position: widget.driver.endLocation,
        infoWindow: const InfoWindow(title: "Destinație șofer"),
      ),
      if (_pickupPoint != null)
        Marker(
          markerId: const MarkerId("pickup"),
          position: _pickupPoint!,
          infoWindow: const InfoWindow(title: "Punct îmbarcare"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      if (_dropPoint != null)
        Marker(
          markerId: const MarkerId("drop"),
          position: _dropPoint!,
          infoWindow: const InfoWindow(title: "Punct coborâre"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      Marker(
        markerId: const MarkerId("destination"),
        position: _finalDestination,
        infoWindow: InfoWindow(
          title: widget.passengerDestinationLabel ?? "Destinația ta",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    ]);

    setState(() => isLoading = false);

    if (_controller != null && _markers.isNotEmpty) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFromMarkers(_markers), 80),
      );
    }
  }

  Future<void> _addWalkingPolyline({
    required LatLng from,
    required LatLng to,
    required PolylineId id,
    required Color color,
  }) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${from.latitude},${from.longitude}"
      "&destination=${to.latitude},${to.longitude}"
      "&mode=walking&key=$kGoogleApiKey",
    );
    final resp = await http.get(url);
    final data = json.decode(resp.body);
    if (data["routes"].isEmpty) return;

    final pts = PolylinePoints().decodePolyline(
      data["routes"][0]["overview_polyline"]["points"],
    );
    _polylines.add(Polyline(
      polylineId: id,
      color: color,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(12)],
      points: pts.map((e) => LatLng(e.latitude, e.longitude)).toList(),
    ));
  }

  LatLngBounds _boundsFromMarkers(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLat = minLat, maxLng = minLng;
    for (final m in markers) {
      minLat = min(minLat, m.position.latitude);
      minLng = min(minLng, m.position.longitude);
      maxLat = max(maxLat, m.position.latitude);
      maxLng = max(maxLng, m.position.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _confirmRide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverTrackingScreen(driver: widget.driver),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.driver;

    return Scaffold(
      appBar: AppBar(title: Text(driver.name)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? driver.startLocation,
              zoom: 13,
            ),
            onMapCreated: (c) => _controller = c,
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // 🔽 Sheet cu profilul și recenziile
          DraggableScrollableSheet(
            initialChildSize: 0.22,
            minChildSize: 0.15,
            maxChildSize: 0.55,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(driver.profilePicUrl),
                          radius: 35,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver.name,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber[700], size: 20),
                                  const SizedBox(width: 4),
                                  Text("${driver.rating} • ${driver.reviews} recenzii",
                                      style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => DriverReviewsScreen(driver: driver),
                                  ));
                                },
                                child: const Text("Vezi toate recenziile"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(driver.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _confirmRide,
                      icon: const Icon(Icons.directions_car),
                      label: const Text("Confirmă cursa"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 50),
                      ),
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
