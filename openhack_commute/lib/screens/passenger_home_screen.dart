import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';


import '../models/driver.dart';
import '../widgets/driver_card.dart';
import 'login_screen.dart';

// CHEIA TA API ESTE DEJA AICI
const String kGoogleApiKey = "AIzaSyDBTi9UursOW0kbzgIWy87WPgYCDxx39F0";

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final LatLng _center = const LatLng(44.439663, 26.096306);
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  GoogleMapController? _mapController;
  DriverRoute? bestMatch;

  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndMoveCamera();
  }

  Future<void> _getCurrentLocationAndMoveCamera() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        
        _currentPosition = LatLng(position.latitude, position.longitude);

        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        String streetName = "Locație necunoscută";
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          streetName = "${p.street ?? ''} ${p.subThoroughfare ?? ''}".trim();
          if (streetName.isEmpty) {
            streetName = p.name ?? "Locație curentă";
          }
        }

        setState(() {
          _fromController.text = streetName;
          _isLoading = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition!, zoom: 15),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eroare la obținerea locației: $e")),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Permisiunea pentru locație este necesară pentru a afișa curse.')),
      );
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _findBestDriver() async {
    print("De la: ${_fromController.text}");
    print("La: ${_toController.text}");

    setState(() => bestMatch = demoDrivers[1]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Am găsit o cursă cu ${bestMatch!.name}!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Pasager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SingleChildScrollView(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unde mergem azi?',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    GooglePlaceAutoCompleteTextField(
  textEditingController: _fromController,
  googleAPIKey: kGoogleApiKey,
  countries: const ["ro"],
  debounceTime: 400,
  isLatLngRequired: true,
  getPlaceDetailWithLatLng: (Prediction prediction) {
    debugPrint("Locație selectată: ${prediction.description}");
  },
  itemClick: (Prediction prediction) {
    _fromController.text = prediction.description ?? "";
    _fromController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
  },
  inputDecoration: const InputDecoration(
    labelText: 'De la',
    suffixIcon: Icon(Icons.search),
  ),
),

const SizedBox(height: 10),

GooglePlaceAutoCompleteTextField(
  textEditingController: _toController,
  googleAPIKey: kGoogleApiKey,
  countries: const ["ro"],
  debounceTime: 400,
  isLatLngRequired: true,
  getPlaceDetailWithLatLng: (Prediction prediction) {
    debugPrint("Destinație selectată: ${prediction.description}");
  },
  itemClick: (Prediction prediction) {
    _toController.text = prediction.description ?? "";
    _toController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
  },
  inputDecoration: const InputDecoration(
    labelText: 'La (Destinație)',
    suffixIcon: Icon(Icons.search),
  ),
),
                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: _findBestDriver,
                      icon: const Icon(Icons.search),
                      label: const Text("Găsește cursă"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),

                    if (bestMatch != null) ...[
                      const SizedBox(height: 15),
                      DriverCard(driver: bestMatch!)
                    ]
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}