class DriverRoute {
  final String name;
  final String car;
  final String startAddress;
  final String endAddress;
  final String departureTime;
  final int availableSeats;
  final String phone;

  DriverRoute({
    required this.name,
    required this.car,
    required this.startAddress,
    required this.endAddress,
    required this.departureTime,
    required this.availableSeats,
    required this.phone,
  });
}

final demoDrivers = [
  DriverRoute(
    name: "Andrei Popescu",
    car: "Dacia Spring",
    startAddress: "Bulevardul Iuliu Maniu 100, București",
    endAddress: "Piața Victoriei, București",
    departureTime: "08:00",
    availableSeats: 2,
    phone: "0723456789",
  ),
  DriverRoute(
    name: "Maria Ionescu",
    car: "VW Golf 7",
    startAddress: "Strada Mihai Bravu 200, București",
    endAddress: "Piața Unirii, București",
    departureTime: "08:30",
    availableSeats: 3,
    phone: "0729876543",
  ),
  DriverRoute(
    name: "George Enache",
    car: "Tesla Model 3",
    startAddress: "Bd. Nicolae Grigorescu, București",
    endAddress: "Piața Victoriei, București",
    departureTime: "09:00",
    availableSeats: 1,
    phone: "0731112233",
  ),
];
