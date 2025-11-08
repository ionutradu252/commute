import 'package:flutter/material.dart';
import 'passenger_home_screen.dart'; // Importăm doar ecranul implicit
// import 'driver_home_screen.dart'; // Nu mai este necesar aici

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- AICI ESTE MODIFICAREA ---
  void _handleLogin() {
    // Într-o aplicație reală, ai verifica emailul și parola cu Firebase Auth
    // Pentru demo, facem pur și simplu login.
    
    // String email = _emailController.text.trim().toLowerCase();
    
    // Nu mai verificăm rolul aici. Trimitem utilizatorul la ecranul implicit (Pasager).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
    );
  }
  // --- SFÂRȘITUL MODIFICĂRII ---

  void _handleRegister() {
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
                    onPressed: _handleLogin, // Funcția simplificată
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