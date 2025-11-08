import 'package:google_maps_flutter/google_maps_flutter.dart'; // 1. Am adăugat importul pentru LatLng

class DriverRoute {
  final String name;
  final String carModel;
  final String licensePlate;
  final double detourMinutes;
  final String profilePicUrl;
  final LatLng startLocation; // 2. Am adăugat locația (simulată) a șoferului

  DriverRoute({
    required this.name,
    required this.carModel,
    required this.licensePlate,
    required this.detourMinutes,
    required this.profilePicUrl,
    required this.startLocation, // 3. Am adăugat în constructor
  });
}

// 4. Am actualizat datele demo cu locații
final List<DriverRoute> demoDrivers = [
  DriverRoute(
    name: "Mihai Popescu",
    carModel: "Dacia Logan",
    licensePlate: "B 123 ABC",
    detourMinutes: 5.0,
    profilePicUrl: "https://placehold.co/100x100/teal/white?text=MP",
    startLocation: const LatLng(44.4479, 26.0978), // Aproape de Piața Romană
  ),
  DriverRoute(
    name: "Ana Ionescu",
    carModel: "VW Golf",
    licensePlate: "B 456 XYZ",
    detourMinutes: 7.5,
    profilePicUrl: "https://placehold.co/100x100/orange/white?text=AI",
    startLocation: const LatLng(44.4350, 26.0838), // Aproape de Cișmigiu
  ),
];