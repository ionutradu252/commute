import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Importuri Firebase (adăugați-le în pubspec.yaml)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'dart:convert';
import 'firebase_options.dart'; // Generat de Firebase CLI
// --- Punct de intrare ---
void main() async {
  // Asigurați-vă că Widget-urile sunt inițializate
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inițializare Firebase (decomentați după ce adăugați fișierul de configurare)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CommuteApp());
}

class CommuteApp extends StatelessWidget {
  const CommuteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commute',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      // --- Navigare ---
      // Începeți cu AuthGate, care va decide ce ecran să arate
      home: const AuthGate(),
    );
  }
}

// --- 1. Auth Gate ---
// Decide dacă arată Login sau Home
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aici veți folosi un StreamBuilder pe FirebaseAuth.instance.authStateChanges()
    // Pentru hackathon, putem simula starea de "logat" pentru a merge direct la ecrane
    
    // Simulare: Încă nu e logat
    // return const LoginScreen();
    
    // Simulare: Este logat
    // După login, trebuie să verificăm rolul
    return const RoleCheckScreen();
  }
}

// --- 2. Login Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    // Aici veți apela FirebaseAuth.instance.signInWithEmailAndPassword
    print('Login with: ${_emailController.text}');
    // După login cu succes, AuthGate va prelua controlul și va trimite la RoleCheckScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Commute',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Parolă'),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigare către ecranul de Register
                },
                child: const Text('Nu ai cont? Înregistrează-te'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. Role Check Screen ---
// Verifică în Firestore dacă userul are un rol și adrese
class RoleCheckScreen extends StatelessWidget {
  const RoleCheckScreen({Key? key}) : super(key: key);

  Future<String> _getUserRole() async {
    // Aici veți citi din Firestore:
    // final userId = FirebaseAuth.instance.currentUser!.uid;
    // final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // if (!doc.exists || doc.data()?['role'] == null) {
    //   return 'NEVERIFICAT';
    // }
    // return doc.data()?['role'];
    
    // Simulare pentru hackathon:
    await Future.delayed(const Duration(seconds: 1));
    return 'PASSENGER'; // Schimbați în 'DRIVER' sau 'NEVERIFICAT' pentru a testa
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Eroare: ${snapshot.error}')));
        }

        final role = snapshot.data;
        if (role == 'DRIVER') {
          return const DriverHomeScreen();
        } else if (role == 'PASSENGER') {
          return const PassengerHomeScreen();
        } else {
          // Dacă e 'NEVERIFICAT' sau nu are profil
          return const ProfileSetupScreen();
        }
      },
    );
  }
}

// --- 4. Profile Setup Screen ---
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setează Profilul')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Completează-ți profilul pentru a continua.'),
              const SizedBox(height: 20),
              // TODO: Adăugați câmpuri pentru Nume
              // TODO: Adăugați butoane pentru a alege Rolul (DRIVER/PASSENGER)
              // TODO: Adăugați câmpuri de text pentru 'Acasă' și 'Birou'
              // Aici veți folosi Google Places Autocomplete
              const TextField(decoration: InputDecoration(labelText: 'Adresa Acasă')),
              const TextField(decoration: InputDecoration(labelText: 'Adresa Birou')),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // TODO: Salvează datele în Firestore
                  // După salvare, navigați la ecranul corespunzător
                },
                child: const Text('Salvează Profilul'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- 5. Passenger Home Screen ---
class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({Key? key}) : super(key: key);

  @override
  _PassengerHomeScreenState createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final String _googleApiKey = 'AIzaSyDBTi9UursOW0kbzgIWy87WPgYCDxx39F0';
  
  final LatLng _center = const LatLng(44.439663, 26.096306); // Piața Universității
  GoogleMapController? _mapController;

  // Controlere pentru TextFields
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  // Stocare pentru markere și traseu
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    // Simulare: pre-luăm adresele. Într-o aplicație reală, le-ați lua din Firestore
    // Poți folosi adrese din București pentru a testa
    _fromController.text = "Piata Universitatii, Bucuresti"; // Simulare
    _toController.text = "Piata Victoriei 1, Bucuresti"; // Simulare
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Funcția principală care cheamă API-ul și desenează traseul
  Future<void> _getRouteAndDraw() async {
    String fromAddress = _fromController.text;
    String toAddress = _toController.text;

    if (fromAddress.isEmpty || toAddress.isEmpty) {
      // Oprește dacă nu sunt adrese
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduceți adresa de plecare și destinația')),
      );
      return;
    }

    // Curăță harta veche
    setState(() {
      _markers.clear();
      _polylines.clear();
    });

    try {
      // Construiește URL-ul pentru Directions API
      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$fromAddress&destination=$toAddress&key=$_googleApiKey';
      
      // Fă requestul HTTP
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['routes'].isNotEmpty) {
          var route = jsonResponse['routes'][0];

          // --- Preluare Polyline (traseul) ---
          var points = PolylinePoints();
          List<PointLatLng> decodedPolyline =
              points.decodePolyline(route['overview_polyline']['points']);
          
          List<LatLng> polylineCoordinates = decodedPolyline.map((point) {
            return LatLng(point.latitude, point.longitude);
          }).toList();

          // --- Preluare Markere (start/sfârșit) ---
          var startLocation = route['legs'][0]['start_location'];
          var endLocation = route['legs'][0]['end_location'];
          LatLng startLatLng = LatLng(startLocation['lat'], startLocation['lng']);
          LatLng endLatLng = LatLng(endLocation['lat'], endLocation['lng']);

          // --- Preluare Limite (pentru zoom) ---
          var bounds = route['bounds'];
          LatLng southwest = LatLng(bounds['southwest']['lat'], bounds['southwest']['lng']);
          LatLng northeast = LatLng(bounds['northeast']['lat'], bounds['northeast']['lng']);

          // --- Actualizează Starea (UI-ul) ---
          setState(() {
            _markers.add(
              Marker(
                markerId: const MarkerId('start'),
                position: startLatLng,
                infoWindow: InfoWindow(title: 'De la', snippet: fromAddress),
              ),
            );
            _markers.add(
              Marker(
                markerId: const MarkerId('end'),
                position: endLatLng,
                infoWindow: InfoWindow(title: 'Până la', snippet: toAddress),
              ),
            );

            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: polylineCoordinates,
                color: Colors.teal,
                width: 5,
              ),
            );
          });

          // --- Mișcă Camera ---
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(southwest: southwest, northeast: northeast),
              50.0, // padding
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Niciun traseu găsit.')),
          );
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eroare la apelul API Directions')),
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A apărut o eroare: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mod Pasager')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
            // Legăm funcțiile și variabilele de hartă
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unde mergem azi?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // Conectăm Controlerele la TextField-uri
                    TextField(
                      controller: _fromController,
                      decoration: const InputDecoration(
                          labelText: 'De la (Acasă)', filled: true),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _toController,
                      decoration: const InputDecoration(
                          labelText: 'La (Birou)', filled: true),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      // Apelăm funcția la apăsare
                      onPressed: _getRouteAndDraw,
                      child: const Text('Găsește Cursă'),
                    )
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

// --- 6. Driver Home Screen ---
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final LatLng _center = const LatLng(44.439663, 26.096306);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mod Șofer')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {
                // TODO: Implementează logica de publicare a cursei
                // 1. Citește adresele 'Acasă' și 'Birou'
                // 2. Calculează 'originalDuration' cu Directions API
                // 3. Scrie o nouă intrare în colecția 'driver_routes'
              },
              child: const Text('Publică Cursa (Acasă -> Birou)',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Chip(
              label: const Text('Puncte: 0',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.all(12),
            ),
          )
        ],
      ),
      // TODO: Adăugați un Listă cu 'Cererile de Preluare' (pasagerii care s-au potrivit)
    );
  }
}