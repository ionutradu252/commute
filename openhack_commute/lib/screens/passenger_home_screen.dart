import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver.dart';
import '../widgets/driver_card.dart';
import 'login_screen.dart'; // 1. Importăm ecranul de login

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final LatLng _center = const LatLng(44.439663, 26.096306);
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  GoogleMapController? _mapController;
  DriverRoute? bestMatch;

  // 2. Funcție de logout
  void _logout(BuildContext context) {
    // Navigăm înapoi la LoginScreen și ștergem istoria de navigare
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _findBestDriver() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) return;
    setState(() => bestMatch = demoDrivers[1]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Am găsit o cursă cu ${bestMatch!.name}!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Pasager"),
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
            onMapCreated: (c) => _mapController = c,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unde mergem azi?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _fromController,
                    decoration:
                        const InputDecoration(labelText: 'De la (Acasă)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _toController,
                    decoration:
                        const InputDecoration(labelText: 'La (Birou)'),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _findBestDriver,
                    icon: const Icon(Icons.search),
                    label: const Text("Găsește cursă"),
                  ),
                  if (bestMatch != null) ...[
                    const SizedBox(height: 15),
                    DriverCard(driver: bestMatch!)
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}