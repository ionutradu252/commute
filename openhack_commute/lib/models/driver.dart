import 'package:flutter/material.dart';

// Acest fișier este necesar pentru a face 'passenger_home_screen.dart' să compileze

class DriverRoute {
  final String name;
  final String carModel;
  final String licensePlate;
  final double detourMinutes;
  final String profilePicUrl;

  DriverRoute({
    required this.name,
    required this.carModel,
    required this.licensePlate,
    required this.detourMinutes,
    required this.profilePicUrl,
  });
}

// Date demo pentru a simula căutarea
final List<DriverRoute> demoDrivers = [
  DriverRoute(
    name: "Mihai Popescu",
    carModel: "Dacia Logan",
    licensePlate: "B 123 ABC",
    detourMinutes: 5.0,
    profilePicUrl: "https://placehold.co/100x100/teal/white?text=MP",
  ),
  DriverRoute(
    name: "Ana Ionescu",
    carModel: "VW Golf",
    licensePlate: "B 456 XYZ",
    detourMinutes: 7.5,
    profilePicUrl: "https://placehold.co/100x100/orange/white?text=AI",
  ),
];