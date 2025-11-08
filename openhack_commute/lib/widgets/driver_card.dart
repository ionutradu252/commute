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
              passengerDestination:
                  passengerDestination ?? const LatLng(44.439663, 26.096306),
              passengerDestinationLabel: passengerDestinationLabel,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Partea Stângă: Poza
              CircleAvatar(
                backgroundImage: NetworkImage(driver.profilePicUrl),
                radius: 28,
              ),
              const SizedBox(width: 12),

              // Partea din Mijloc: Nume, Rating, Mașină, Locuri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    // RATING
                    Row(
                      children: [
                        Icon(Icons.star,
                            color: Colors.amber[600], size: 18),
                        const SizedBox(width: 4),
                        Text(driver.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(" (${driver.reviews} review-uri)",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${driver.carModel} • ${driver.licensePlate}",
                        style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                    
                    // --- AICI ESTE MODIFICAREA ---
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "${driver.availableSeats} locuri disponibile",
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    ),
                    // --- SFÂRȘITUL MODIFICĂRII ---
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Partea Dreaptă: Timpii
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Timp total
                  Text(
                    "${driver.walkingTimeToPickupMinutes + driver.driveTimeMinutes} min",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),

                  // Detalii timpi
                  Row(
                    children: [
                      Icon(Icons.directions_walk,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text("${driver.walkingTimeToPickupMinutes} min",
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.time_to_leave,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text("${driver.driveTimeMinutes} min",
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}