import 'package:flutter/material.dart';
import 'passenger_home_screen.dart'; // Make sure this path is correct

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

  void _handleLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
    );
  }

  void _handleRegister() {
    print("Navighează la înregistrare");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            // Asigură-te că numele fișierului este corect
            image: const AssetImage('assets/bg.png'), 
            fit: BoxFit.cover,
            // Aplicăm același filtru de estompare ca pe splash screen
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- MODIFICATION: Wrapped Image in a matching Hero ---
                  Hero(
                    tag: 'logo-hero', // This tag MUST match the one on SplashScreen
                    child: Image.asset(
                      'assets/logo.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
                  // --- END OF MODIFICATION ---
                  const SizedBox(height: 16),
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