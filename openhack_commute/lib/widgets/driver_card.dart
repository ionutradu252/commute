import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver.dart';
import '../screens/driver_profile_screen.dart';

class DriverCard extends StatelessWidget {
  final DriverRoute driver;
  final LatLng? passengerDestination;
  final String? passengerDestinationLabel;

  const DriverCard({
    super.key,
    required this.driver,
    this.passengerDestination,
    this.passengerDestinationLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DriverProfileScreen(
              driver: driver,
              passengerDestination: passengerDestination ?? const LatLng(44.439663, 26.096306),
              passengerDestinationLabel: passengerDestinationLabel,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(driver.profilePicUrl),
            radius: 26,
          ),
          title: Text(driver.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${driver.carModel} • ${driver.licensePlate}"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "+${driver.detourMinutes.toStringAsFixed(0)} min",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const Text("ocol"),
            ],
          ),
        ),
      ),
    );
  }
}
