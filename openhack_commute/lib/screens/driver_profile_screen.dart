import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver.dart';

class DriverProfileScreen extends StatefulWidget {
  final DriverRoute driver;

  const DriverProfileScreen({super.key, required this.driver});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool showRoute = false;
  GoogleMapController? _mapController;

  final LatLng destination = const LatLng(44.4400, 26.1000); // demo: destinația

  void _toggleRoute() {
    setState(() {
      showRoute = !showRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.driver;

    return Scaffold(
      appBar: AppBar(
        title: Text(driver.name),
      ),
      body: Column(
        children: [
          // Informații despre șofer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
            ]),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(driver.profilePicUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(driver.carModel,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber),
                          Icon(Icons.star, color: Colors.amber),
                          Icon(Icons.star, color: Colors.amber),
                          Icon(Icons.star_half, color: Colors.amber),
                          Icon(Icons.star_border, color: Colors.amber),
                          SizedBox(width: 5),
                          Text("3.5 / 5.0"),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: driver.startLocation,
                    zoom: 13,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("driver"),
                      position: driver.startLocation,
                      infoWindow: const InfoWindow(title: "Șoferul"),
                    ),
                    if (showRoute)
                      Marker(
                        markerId: const MarkerId("destination"),
                        position: destination,
                        infoWindow: const InfoWindow(title: "Destinație"),
                      ),
                  },
                  polylines: showRoute
                      ? {
                          Polyline(
                            polylineId: const PolylineId("route"),
                            color: Colors.blue,
                            width: 5,
                            points: [
                              driver.startLocation,
                              destination,
                            ],
                          ),
                        }
                      : {},
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

                // Review-uri și butonul de alegere
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -3))
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Review-uri recente:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text("⭐️ \"Foarte punctual și amabil!\""),
                        const Text("⭐️⭐️⭐️⭐️ \"Mașină curată și confortabilă.\""),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _toggleRoute,
                          icon: Icon(showRoute
                              ? Icons.cancel
                              : Icons.directions_car),
                          label: Text(showRoute
                              ? "Anulează"
                              : "Merg cu ${driver.name}"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
