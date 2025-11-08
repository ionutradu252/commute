import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverRoute {
  final String name;
  final String carModel;
  final String licensePlate;
  final String profilePicUrl;
  final LatLng startLocation;
  final LatLng endLocation;
  final int availableSeats;
  final String bio;

  // Câmpuri noi pentru sortare și afișare
  final double rating;
  final int reviews; // 1. Am adăugat "reviews" (lipsea)
  final double detourMinutes; // Ocolul pentru șofer
  final int walkingTimeToPickupMinutes; // Timpul de mers pe jos al pasagerului
  final int driveTimeMinutes; // Timpul total cu mașina (după preluare)

  DriverRoute({
    required this.name,
    required this.carModel,
    required this.licensePlate,
    required this.profilePicUrl,
    required this.startLocation,
    required this.endLocation,
    required this.availableSeats,
    required this.bio,
    // Câmpuri noi
    required this.rating,
    required this.reviews, // 1. Am adăugat "reviews" și aici
    required this.detourMinutes,
    required this.walkingTimeToPickupMinutes,
    required this.driveTimeMinutes,
  });
}

// 2. Am completat lista demo cu datele lipsă
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
    // --- AM ADĂUGAT DATELE LIPSĂ ---
    walkingTimeToPickupMinutes: 5, // Timp de mers (simulat)
    driveTimeMinutes: 14,          // Timp cursa (simulat)
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
    // --- AM ADĂUGAT DATELE LIPSĂ ---
    walkingTimeToPickupMinutes: 8, // Timp de mers (simulat)
    driveTimeMinutes: 12,          // Timp cursa (simulat)
  ),
];