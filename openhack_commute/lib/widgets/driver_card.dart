import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../screens/driver_profile_screen.dart';

class DriverCard extends StatelessWidget {
  final DriverRoute driver;
  const DriverCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DriverProfileScreen(driver: driver),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(driver.profilePicUrl),
            radius: 25,
          ),
          title: Text(driver.name),
          subtitle: Text("${driver.carModel} • ${driver.licensePlate}"),
          trailing: Text(
            "+${driver.detourMinutes} min ocolire",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
