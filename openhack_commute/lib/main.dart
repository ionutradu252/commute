import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Importuri Firebase (adăugați-le în pubspec.yaml)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final LatLng _center = const LatLng(44.439663, 26.096306); // Piața Universității

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mod Pasager')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
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
                    // TODO: Folosiți adresele salvate (Acasă/Birou)
                    const TextField(
                        decoration: InputDecoration(
                            labelText: 'De la (Acasă)', filled: true)),
                    const SizedBox(height: 10),
                    const TextField(
                        decoration: InputDecoration(
                            labelText: 'La (Birou)', filled: true)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implementează logica de căutare
                        // 1. Caută în 'driver_routes'
                        // 2. Aplică algoritmul de potrivire "AI"
                        // 3. Afișează un ecran cu rezultate
                      },
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