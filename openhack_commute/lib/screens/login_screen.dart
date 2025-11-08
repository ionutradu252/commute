import 'package:flutter/material.dart';
import 'passenger_home_screen.dart';
import 'driver_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Creăm controlere pentru a citi textul
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // 2. Curățăm controlerele când widget-ul este eliminat
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. Funcția de Login
  void _handleLogin() {
    // Citim textul și îl "curățăm"
    final String email = _emailController.text.trim().toLowerCase();
    // final String password = _passwordController.text.trim(); // Deocamdată nu verificăm parola, dar o avem

    // --- Logica de Hackathon ---
    // Folosim email-uri fixe pentru a demonstra rolurile
    // Testează cu:
    // Email Șofer: sofer@commute.com
    // Email Pasager: pasager@commute.com

    if (email == 'sofer') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
      );
    } else if (email == 'pasager') {
      // Logare ca Pasager
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sau parolă incorectă!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleRegister() {
    // TODO: Implementează navigarea către un ecran de înregistrare
    print("Navighează la înregistrare");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00695C), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car,
                      size: 60, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text("Commute",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  // 4. Conectăm controlerele la TextField-uri
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    // 5. Apelăm funcția de login
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("Login"),
                  ),
                  TextButton(
                    onPressed: _handleRegister,
                    child: const Text("Nu ai cont? Înregistrează-te"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}