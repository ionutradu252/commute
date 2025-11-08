import 'package:flutter/material.dart';
import '../models/driver.dart';

class DriverCard extends StatelessWidget {
  final DriverRoute driver;
  const DriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(driver.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("${driver.car} • Plecare: ${driver.departureTime}"),
            const SizedBox(height: 4),
            Text("Locuri disponibile: ${driver.availableSeats}"),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Contactat ${driver.name} 📞")),
                );
              },
              icon: const Icon(Icons.phone),
              label: const Text("Contactează"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            )
          ],
        ),
      ),
    );
  }
}
