import 'package:flutter/material.dart';
import 'driver_home_screen.dart';
import 'passenger_home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  Future<String> _getUserRole() async {
    await Future.delayed(const Duration(seconds: 1));
    // 👉 Schimbă între 'DRIVER' și 'PASSENGER' ca să testezi modurile
    return 'PASSENGER';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == 'DRIVER') {
          return const DriverHomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
