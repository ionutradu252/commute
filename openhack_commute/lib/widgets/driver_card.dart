import 'package:flutter/material.dart';
import '../models/driver.dart';

// Acest fișier este necesar pentru a face 'passenger_home_screen.dart' să compileze

class DriverCard extends StatelessWidget {
  final DriverRoute driver;
  const DriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(driver.profilePicUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback în caz că imaginea nu se încarcă
          },
        ),
        title: Text(driver.name),
        subtitle: Text("${driver.carModel} • ${driver.licensePlate}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "+${driver.detourMinutes.toStringAsFixed(0)} min",
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const Text("detur"),
          ],
        ),
      ),
    );
  }
}