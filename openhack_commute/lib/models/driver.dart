import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverRoute {
  final String name;
  final String carModel;
  final String licensePlate;
  final double detourMinutes;
  final String profilePicUrl;
  final LatLng startLocation;
  final LatLng endLocation;
  final int availableSeats;
  final double rating;
  final int reviews;
  final String bio;

  DriverRoute({
    required this.name,
    required this.carModel,
    required this.licensePlate,
    required this.detourMinutes,
    required this.profilePicUrl,
    required this.startLocation,
    required this.endLocation,
    required this.availableSeats,
    required this.rating,
    required this.reviews,
    required this.bio,
  });
}

final List<DriverRoute> demoDrivers = [
  DriverRoute(
    name: "Mihai Popescu",
    carModel: "Dacia Logan",
    licensePlate: "B 123 ABC",
    detourMinutes: 5.0,
    profilePicUrl: "https://placehold.co/100x100/teal/white?text=MP",
    startLocation: const LatLng(44.4479, 26.0978),
    endLocation: const LatLng(44.4268, 26.1025),
    availableSeats: 2,
    rating: 4.8,
    reviews: 32,
    bio: "Sunt punctual și prietenos. Conduc zilnic pe ruta Militari - Pipera.",
  ),
  DriverRoute(
    name: "Ana Ionescu",
    carModel: "VW Golf",
    licensePlate: "B 456 XYZ",
    detourMinutes: 7.5,
    profilePicUrl: "https://placehold.co/100x100/orange/white?text=AI",
    startLocation: const LatLng(44.4350, 26.0838),
    endLocation: const LatLng(44.4300, 26.1100),
    availableSeats: 3,
    rating: 4.9,
    reviews: 47,
    bio: "Îmi place să ofer o experiență plăcută pasagerilor. Mașină curată și aer condiționat mereu pornit.",
  ),
];
