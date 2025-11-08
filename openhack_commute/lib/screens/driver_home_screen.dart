import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'login_screen.dart'; // 1. Importăm ecranul de login

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  final LatLng _center = const LatLng(44.439663, 26.096306);

  // 2. Funcție de logout
  void _logout(BuildContext context) {
    // Navigăm înapoi la LoginScreen și ștergem istoria de navigare
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Șofer"),
        // 3. Adăugăm butonul de logout aici
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => _logout(context), // Apelăm funcția de logout
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cursa publicată!")),
                );
              },
              icon: const Icon(Icons.publish),
              label: const Text("Publică cursa (Acasă → Birou)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}