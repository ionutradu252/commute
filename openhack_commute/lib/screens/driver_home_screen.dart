import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'rewards_screen.dart';
import 'user_profile_screen.dart';
import 'passenger_tracking_screen.dart';
import '../models/driver.dart';

// 🔹 CHEIA API GOOGLE
const String kGoogleApiKey = "AIzaSyDBTi9UursOW0kbzgIWy87WPgYCDxx39F0";

class MockPassenger {
  final String name;
  final double rating;
  final int points;
  final LatLng pickupLocation;

  MockPassenger({
    required this.name,
    required this.rating,
    required this.points,
    required this.pickupLocation,
  });
}

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final LatLng _center = const LatLng(44.439663, 26.096306);
  GoogleMapController? _mapController;

  int _currentBottomTabIndex = 0;
  bool _isRoutePublished = false;
  bool _isLoading = false;
  bool _isFindingPassengers = false;

  int _driverPoints = 1250;
  int _totalPointsFromRide = 0;

  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<bool> _selectedDays = List.generate(7, (index) => false);
  int _selectedSeats = 1;

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  String? _etaMessage;

  final List<MockPassenger> _mockPassengers = [];

  LatLng? _startLocation;
  LatLng? _endLocation;

  void _spendPoints(int points) {
    if (_driverPoints >= points) {
      setState(() {
        _driverPoints -= points;
      });
    }
  }

  void _setSavedRoute(String from, String to, TimeOfDay start, TimeOfDay end) {
    setState(() {
      _fromController.text = from;
      _toController.text = to;
      _startTime = start;
      _endTime = end;
      _selectedDays = [true, true, true, true, true, false, false];
    });
  }

  Future<void> _publishRoute() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completează adresa de plecare și destinația.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _polylines.clear();
      _markers.clear();
      _mockPassengers.clear();
      _totalPointsFromRide = 0;
    });

    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${_fromController.text}"
        "&destination=${_toController.text}"
        "&mode=driving&key=$kGoogleApiKey",
      );

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data["routes"].isEmpty) {
        throw Exception(data["error_message"] ?? "Ruta nu a fost găsită.");
      }

      final route = data["routes"][0];
      final points = PolylinePoints().decodePolyline(route["overview_polyline"]["points"]);
      final polylinePoints = points.map((p) => LatLng(p.latitude, p.longitude)).toList();

      final leg = route["legs"][0];
      _etaMessage = leg["duration"]["text"];

      _startLocation = LatLng(leg["start_location"]["lat"], leg["start_location"]["lng"]);
      _endLocation = LatLng(leg["end_location"]["lat"], leg["end_location"]["lng"]);

      _polylines.add(Polyline(
        polylineId: const PolylineId("driver_route"),
        color: Colors.blue,
        width: 6,
        points: polylinePoints,
      ));

      _markers.add(Marker(
        markerId: const MarkerId("start"),
        position: _startLocation!,
        infoWindow: InfoWindow(title: "Plecare", snippet: leg["start_address"]),
      ));

      _markers.add(Marker(
        markerId: const MarkerId("end"),
        position: _endLocation!,
        infoWindow: InfoWindow(title: "Destinație", snippet: leg["end_address"]),
      ));

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_getBounds(polylinePoints), 50.0),
      );

      setState(() {
        _isLoading = false;
        _isFindingPassengers = true;
      });

      await Future.delayed(const Duration(seconds: 5));

      _generateMockPassengers(polylinePoints);

      setState(() {
        _isRoutePublished = true;
        _isFindingPassengers = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isFindingPassengers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la calcularea rutei: $e')),
      );
    }
  }

  void _generateMockPassengers(List<LatLng> routePoints) {
    final random = Random();
    int count = _selectedSeats == 1 ? 1 : random.nextInt(_selectedSeats) + 1;

    _mockPassengers.clear();
    _totalPointsFromRide = 0;

    for (int i = 0; i < count; i++) {
      final locationIndex = (routePoints.length * (0.3 + (i * 0.2))).floor();
      if (locationIndex >= routePoints.length) continue;

      final pLocation = routePoints[locationIndex];
      final points = 50 + random.nextInt(50);

      final p = MockPassenger(
        name: "Pasager ${i + 1}",
        rating: 4.5 + random.nextDouble() * 0.5,
        points: points,
        pickupLocation: pLocation,
      );

      _mockPassengers.add(p);
      _totalPointsFromRide += points;

      _markers.add(Marker(
        markerId: MarkerId(p.name),
        position: p.pickupLocation,
        infoWindow: InfoWindow(title: p.name, snippet: "Preluare (+${p.points} pct)"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () => _onPassengerTapped(p.pickupLocation),
      ));
    }
  }

  void _onPassengerTapped(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 16.0));
  }

  void _cancelRoute() {
    setState(() {
      _isRoutePublished = false;
      _isFindingPassengers = false;
      _polylines.clear();
      _markers.clear();
      _mockPassengers.clear();
      _etaMessage = null;
      _fromController.clear();
      _toController.clear();
      _startTime = null;
      _endTime = null;
      _selectedDays = List.generate(7, (index) => false);
      _selectedSeats = 1;
      _totalPointsFromRide = 0;
    });
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude,
        minLng = points.first.longitude,
        maxLat = points.first.latitude,
        maxLng = points.first.longitude;
    for (var point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildMapScreen(),
      RewardsScreen(
        currentPoints: _driverPoints,
        onSpendPoints: _spendPoints,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Șofer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(
                    isCurrentlyDriver: true,
                    driverPoints: _driverPoints,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              avatar: const Icon(Icons.star, color: Colors.amber),
              label: Text("$_driverPoints Puncte",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentBottomTabIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomTabIndex,
        onTap: (index) => setState(() => _currentBottomTabIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Hartă"),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Recompense"),
        ],
      ),
    );
  }

  Widget _buildMapScreen() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _center, zoom: 12),
          onMapCreated: (c) => _mapController = c,
          polylines: _polylines,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
        if (!_isFindingPassengers)
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isRoutePublished ? _buildPublishedView() : _buildRouteForm(),
              ),
            ),
          ),
        if (_isLoading)
          _buildOverlay("Se calculează ruta..."),
        if (_isFindingPassengers)
          _buildOverlay("Căutare pasageri..."),
      ],
    );
  }

  Widget _buildOverlay(String text) => Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white)),
            ],
          ),
        ),
      );

  // --- formularul de rută (nemodificat)
Widget _buildRouteForm() {
  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Planifică o cursă nouă",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // 🔸 Rute salvate
        const Text("Rute salvate", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            ActionChip(
              avatar: const Icon(Icons.work_outline, size: 18),
              label: const Text('Muncă'),
              onPressed: () => _setSavedRoute(
                "Strada Liviu Rebreanu 4, București",
                "Piața Victoriei 1, București",
                const TimeOfDay(hour: 8, minute: 0),
                const TimeOfDay(hour: 9, minute: 0),
              ),
            ),
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Acasă'),
              onPressed: () => _setSavedRoute(
                "Piața Victoriei 1, București",
                "Strada Liviu Rebreanu 4, București",
                const TimeOfDay(hour: 17, minute: 0),
                const TimeOfDay(hour: 18, minute: 0),
              ),
            ),
          ],
        ),
        const Divider(height: 20),

        // 🔸 Adresă plecare
        _buildLocationInput(_fromController, "De la"),
        const SizedBox(height: 10),

        // 🔸 Ora plecării
        _buildTimePicker(
          context,
          "Ora plecării",
          _startTime,
          (time) => setState(() => _startTime = time),
        ),
        const SizedBox(height: 12),

        // 🔸 Adresă destinație
        _buildLocationInput(_toController, "La (Destinație)"),
        const SizedBox(height: 10),

        // 🔸 Ora sosirii
        _buildTimePicker(
          context,
          "Ora sosirii (aprox.)",
          _endTime,
          (time) => setState(() => _endTime = time),
        ),

        const SizedBox(height: 16),

        // 🔸 Selector zile
        const Text("Zilele săptămânii",
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ToggleButtons(
            isSelected: _selectedDays,
            onPressed: (index) {
              setState(() {
                _selectedDays[index] = !_selectedDays[index];
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: Colors.teal,
            children: const [
              Text(" L "),
              Text(" Ma "),
              Text(" Mi "),
              Text(" J "),
              Text(" V "),
              Text(" S "),
              Text(" D "),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 🔸 Locuri disponibile
        const Text("Locuri disponibile",
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: [1, 2, 3, 4].map((seats) {
            return ChoiceChip(
              label: Text("$seats Locuri"),
              selected: _selectedSeats == seats,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedSeats = seats);
                }
              },
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color: _selectedSeats == seats ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 🔸 Buton publicare
        ElevatedButton.icon(
          onPressed: _publishRoute,
          icon: const Icon(Icons.publish),
          label: const Text("Publică Cursa"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
} // (păstrează exact ce aveai)

  Widget _buildLocationInput(
    TextEditingController controller, String label) {
  return GooglePlaceAutoCompleteTextField(
    textEditingController: controller,
    googleAPIKey: kGoogleApiKey,
    countries: const ["ro"],
    debounceTime: 400,
    isLatLngRequired: false,
    getPlaceDetailWithLatLng: (Prediction p) {},
    itemClick: (Prediction p) {
      controller.text = p.description ?? "";
    },
    inputDecoration: InputDecoration(
      labelText: label,
      suffixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
  );
}

Widget _buildTimePicker(BuildContext context, String label, TimeOfDay? time,
    Function(TimeOfDay) onTimeChanged) {
  return OutlinedButton.icon(
    onPressed: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: time ?? TimeOfDay.now(),
      );
      if (picked != null) onTimeChanged(picked);
    },
    icon: const Icon(Icons.access_time),
    label: Text(time == null ? label : time.format(context)),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 45),
      alignment: Alignment.centerLeft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}


  // --- Published View ---
  Widget _buildPublishedView() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Cursă Activă",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (_etaMessage != null)
            Chip(
              label: Text("ETA: $_etaMessage",
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text("Pasageri găsiți: ${_mockPassengers.length} / $_selectedSeats",
          style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: _mockPassengers.length,
          itemBuilder: (context, index) {
            final passenger = _mockPassengers[index];
            return Card(
              elevation: 1,
              child: ListTile(
                onTap: () => _onPassengerTapped(passenger.pickupLocation),
                leading: CircleAvatar(
                  child: Text(passenger.name.substring(0, 1)),
                ),
                title: Text(passenger.name),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(" ${passenger.rating.toStringAsFixed(1)}"),
                  ],
                ),
                trailing: Chip(
                  label: Text("+${passenger.points} Pct",
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: Chip(
          label: Text(
            "Total Puncte Cursă: $_totalPointsFromRide",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green[100],
          avatar: const Icon(Icons.star, color: Colors.green),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      const SizedBox(height: 12),

      // 🔹 Buton: Anulează cursa
      ElevatedButton.icon(
        onPressed: _cancelRoute,
        icon: const Icon(Icons.cancel_outlined),
        label: const Text("Anulează Cursa"),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 45),
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
        ),
      ),
      const SizedBox(height: 10),

      // 🔹 Buton: Începe cursa (simulare)
      ElevatedButton.icon(
        onPressed: () {
          if (_mockPassengers.isEmpty ||
              _startLocation == null ||
              _endLocation == null) return;

          // Creează lista cu locațiile tuturor pasagerilor
          final passengerLocations =
              _mockPassengers.map((p) => p.pickupLocation).toList();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DriverRideSimulationScreen(
                driver: DriverRoute(
                  name: "Șoferul Meu",
                  profilePicUrl:
                      "https://ui-avatars.com/api/?name=Sofer&background=00897B&color=fff",
                  startLocation: _startLocation!,
                  endLocation: _endLocation!,
                  carModel: "Dacia Logan",
                  licensePlate: "B 123 ABC",
                  bio: "Demo",
                  rating: 4.5,
                  reviews: 10,
                  detourMinutes: 0,
                  walkingTimeToPickupMinutes: 0,
                  driveTimeMinutes: 0,
                  availableSeats: _selectedSeats,
                ),
                passengerPickups: passengerLocations,
                finalDestination: _endLocation!,
              ),
            ),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text("Începe cursa"),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 45),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
    ],
  );
}
}