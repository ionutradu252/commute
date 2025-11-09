import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../models/driver.dart';
import '../widgets/driver_card.dart';
import 'user_profile_screen.dart';

const String kGoogleApiKey = "AIzaSyDBTi9UursOW0kbzgIWy87WPgYCDxx39F0";

// Enum pentru a gestiona starea sortării
enum SortType { time, rating }

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
  
  // --- MODIFICARE: De la un singur obiect la o listă ---
  List<DriverRoute> _foundDrivers = [];
  SortType _currentSort = SortType.time; // Sortarea implicită
  // --- ---

  LatLng? _currentPosition;
  LatLng? _passengerDestination;
  String? _passengerDestinationLabel;

  bool _isLoading = true;

  // Adrese Prestabilite
  static const String _workAddress = "Piața Victoriei 1, București, România";
  static const LatLng _workLatLng = LatLng(44.4485, 26.0869);
  static const String _homeAddress = "Piața Unirii, București, România";
  static const LatLng _homeLatLng = LatLng(44.4325, 26.1039);

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndMoveCamera();
  }

  Future<void> _getCurrentLocationAndMoveCamera() async {
    // ... (Funcția rămâne neschimbată) ...
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _currentPosition = LatLng(position.latitude, position.longitude);
        List<Placemark> placemarks =
            await placemarkFromCoordinates(position.latitude, position.longitude);
        String streetName = "Locație necunoscută";
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          streetName = "${p.street ?? ''} ${p.subThoroughfare ?? ''}".trim();
          if (streetName.isEmpty) streetName = p.name ?? "Locație curentă";
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
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  LatLng _randomNearbyPoint(LatLng center, double radiusMeters) {
    // ... (Funcția rămâne neschimbată) ...
    final random = Random();
    final u = random.nextDouble();
    final v = random.nextDouble();
    final w = radiusMeters / 111300 * sqrt(u); 
    final t = 2 * pi * v;
    final x = w * cos(t);
    final y = w * sin(t);
    final newX = x / cos(center.latitude * pi / 180);
    return LatLng(center.latitude + y, center.longitude + newX);
  }

  // --- MODIFICARE: Acum generează o LISTĂ de șoferi ---
  Future<void> _findBestDriver() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_currentPosition == null || _passengerDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selectează o destinație mai întâi.")),
      );
      return;
    }

    // Ștergem șoferii vechi înainte de o nouă căutare
    setState(() => _foundDrivers.clear());

    // 🚗 Simulăm 3 șoferi.
    // Într-o aplicație reală, aici ai face un apel API
    // care ar întoarce o listă de șoferi potriviți.
    List<DriverRoute> drivers = [
      DriverRoute(
        name: "Mihai Andrei",
        carModel: "Toyota Corolla",
        licensePlate: "B 118 OPH",
        profilePicUrl: "https://ui-avatars.com/api/?name=Mihai+Andrei&background=00897B&color=fff&size=100",
        startLocation: _randomNearbyPoint(_currentPosition!, 500),
        endLocation: _randomNearbyPoint(_passengerDestination!, 500),
        availableSeats: 3,
        rating: 4.8,
        reviews: 42,
        bio: "Conduc zilnic spre munca.",
        // Date simulate
        detourMinutes: 5.0,
        walkingTimeToPickupMinutes: 3,
        driveTimeMinutes: 15,
      ),
      DriverRoute(
        name: "Ana Ionescu",
        carModel: "VW Golf",
        licensePlate: "B 456 XYZ",
        profilePicUrl: "https://ui-avatars.com/api/?name=Ana+Ionescu&background=E65100&color=fff&size=100",
        startLocation: _randomNearbyPoint(_currentPosition!, 800),
        endLocation: _randomNearbyPoint(_passengerDestination!, 300),
        availableSeats: 2,
        rating: 4.9,
        reviews: 112,
        bio: "Muzică bună și drumuri line.",
        // Date simulate
        detourMinutes: 2.0,
        walkingTimeToPickupMinutes: 8,
        driveTimeMinutes: 12,
      ),
      DriverRoute(
        name: "Vasile Pop",
        carModel: "Dacia Logan",
        licensePlate: "IF 01 ABC",
        profilePicUrl: "https://ui-avatars.com/api/?name=Vasile+Pop&background=455A64&color=fff&size=100",
        startLocation: _randomNearbyPoint(_currentPosition!, 200),
        endLocation: _randomNearbyPoint(_passengerDestination!, 800),
        availableSeats: 4,
        rating: 4.5,
        reviews: 21,
        bio: "Aer condiționat și liniște.",
        // Date simulate
        detourMinutes: 8.0,
        walkingTimeToPickupMinutes: 2,
        driveTimeMinutes: 18,
      ),
    ];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Am găsit ${drivers.length} curse disponibile!")),
    );

    setState(() {
      _foundDrivers = drivers;
      // Sortăm lista implicit după timp
      _sortDrivers(SortType.time);
    });
  }

  // --- FUNCȚIE NOUĂ: Pentru sortarea listei ---
  void _sortDrivers(SortType sortType) {
    setState(() {
      _currentSort = sortType;
      if (sortType == SortType.time) {
        // Sortează după cel mai scurt timp total (mers + condus)
        _foundDrivers.sort((a, b) => (a.walkingTimeToPickupMinutes + a.driveTimeMinutes)
            .compareTo(b.walkingTimeToPickupMinutes + b.driveTimeMinutes));
      } else if (sortType == SortType.rating) {
        // Sortează după cel mai bun rating (descrescător)
        _foundDrivers.sort((a, b) => b.rating.compareTo(a.rating));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Pasager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UserProfileScreen(
                    isCurrentlyDriver: false, // Îi spunem că suntem în Mod Pasager
                    // TODO: Pasează punctele pasagerului dacă le ai
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            // ... (Harta neschimbată) ...
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
                // ... (Cardul neschimbat) ...
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // --- Chip-uri pentru locații salvate (MODIFICATE) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ActionChip(
                          avatar: Icon(Icons.work_outline,
                              size: 18, color: Colors.teal[800]),
                          label: Text('Muncă',
                              style: TextStyle(color: Colors.teal[900])),
                          onPressed: () {
                            setState(() {
                              _toController.text = _workAddress;
                              _passengerDestination = _workLatLng;
                              _passengerDestinationLabel = _workAddress;
                            });
                            _findBestDriver(); // Apel automat
                          },
                        ),
                        const SizedBox(width: 8), 
                        ActionChip(
                          avatar: Icon(Icons.home_outlined,
                              size: 18, color: Colors.blue[800]),
                          label: Text('Acasă',
                              style: TextStyle(color: Colors.blue[900])),
                          onPressed: () {
                            setState(() {
                              _toController.text = _homeAddress;
                              _passengerDestination = _homeLatLng;
                              _passengerDestinationLabel = _homeAddress;
                            });
                            _findBestDriver(); // Apel automat
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // --- Câmpurile de Autocomplete (Neschimbate) ---
                    GooglePlaceAutoCompleteTextField(
                      // ... (neschimbat) ...
                      textEditingController: _fromController,
                      googleAPIKey: kGoogleApiKey,
                      countries: const ["ro"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {},
                      itemClick: (Prediction prediction) {
                        _fromController.text = prediction.description ?? "";
                      },
                      inputDecoration: const InputDecoration(
                        labelText: 'De la',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GooglePlaceAutoCompleteTextField(
                      // ... (neschimbat) ...
                      textEditingController: _toController,
                      googleAPIKey: kGoogleApiKey,
                      countries: const ["ro"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction p) {
                        if (p.lat != null && p.lng != null) {
                          _passengerDestination = LatLng(double.parse(p.lat!), double.parse(p.lng!));
                          _passengerDestinationLabel = p.description;
                        }
                      },
                      itemClick: (Prediction p) {
                        _toController.text = p.description ?? "";
                         if (p.lat != null && p.lng != null) {
                          _passengerDestination = LatLng(double.parse(p.lat!), double.parse(p.lng!));
                          _passengerDestinationLabel = p.description;
                        }
                      },
                      inputDecoration: const InputDecoration(
                        labelText: 'La (Destinație)',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- Butonul de căutare (Neschimbat) ---
                    ElevatedButton.icon(
                      onPressed: _findBestDriver,
                      icon: const Icon(Icons.search),
                      label: const Text("Găsește cursă"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),

                    // --- MODIFICARE: Afișarea listei de șoferi ---
                    if (_foundDrivers.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      // --- NOILE BUTOANE DE SORTARE ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text("Timp"),
                            selected: _currentSort == SortType.time,
                            onSelected: (selected) {
                              if (selected) _sortDrivers(SortType.time);
                            },
                            iconTheme: IconThemeData(color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text("Rating"),
                            selected: _currentSort == SortType.rating,
                            onSelected: (selected) {
                              if (selected) _sortDrivers(SortType.rating);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // --- LISTA DE ȘOFERI ---
                      SizedBox(
                        height: 240, // Setăm o înălțime fixă pentru listă
                        child: ListView.builder(
                          itemCount: _foundDrivers.length,
                          itemBuilder: (context, index) {
                            final driver = _foundDrivers[index];
                            return DriverCard(
                              driver: driver,
                              passengerDestination: _passengerDestination,
                              passengerDestinationLabel:
                                  _passengerDestinationLabel,
                            );
                          },
                        ),
                      ),
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