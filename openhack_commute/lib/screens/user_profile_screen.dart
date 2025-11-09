import 'package:flutter/material.dart';
import 'driver_home_screen.dart';
import 'passenger_home_screen.dart';
import 'login_screen.dart';
import 'chat_bot_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isCurrentlyDriver;
  final int driverPoints;

  const UserProfileScreen({
    super.key,
    required this.isCurrentlyDriver,
    this.driverPoints = 0,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late bool _isDriverMode;

  @override
  void initState() {
    super.initState();
    _isDriverMode = widget.isCurrentlyDriver;
  }

  // --- AICI ESTE REPARAȚIA ---
  void _toggleMode(bool newValue) {
    setState(() {
      _isDriverMode = newValue;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      // Definirea ecranului la care vrem să mergem
      Widget newScreen = newValue
          ? const DriverHomeScreen()
          : const PassengerHomeScreen();

      // Folosim pushAndRemoveUntil pentru a șterge tot istoricul
      // și a seta noul ecran ca fiind singurul în stivă.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => newScreen),
        (Route<dynamic> route) => false, // Șterge toate rutele anterioare
      );
    });
  }
  // --- SFÂRȘITUL REPARAȚIEI ---

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showAboutDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Despre noi"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("🏆 Eveniment: Openhack 2025"),
          SizedBox(height: 8),
          Text("👥 Echipa: IDCrew"),
          SizedBox(height: 8),
          Text("👤 Membri:\n- Radu Ionuț\n- Coman Cezar"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Închide"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilul Meu"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Secțiunea de sus: Poză și Nume
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      "https://ui-avatars.com/api/?name=Ionut+Popescu&background=00897B&color=fff&size=128"),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Ionuț Popescu",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Membru din 2024",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Secțiunea de Statistici (Puncte Condiționate)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Rating", "4.8", Icons.star, Colors.amber),
              _buildStatCard("Curse", "124", Icons.check_circle, Colors.green),
              
              if (widget.isCurrentlyDriver)
                _buildStatCard("Puncte", widget.driverPoints.toString(),
                    Icons.star, Colors.teal),
            ],
          ),
          const SizedBox(height: 24),

          // Secțiunea de Setări
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Comutator Mod Șofer
                SwitchListTile(
                  title: const Text("Mod Șofer",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(_isDriverMode
                      ? "Ești vizibil pentru pasageri"
                      : "Cauți curse ca pasager"),
                  secondary:
                      Icon(_isDriverMode ? Icons.drive_eta : Icons.search),
                  value: _isDriverMode,
                  onChanged: _toggleMode,
                  activeThumbColor: Colors.teal,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // Verificare KYC (Mock)
                ListTile(
                  leading: Icon(Icons.shield, color: Colors.green[600]),
                  title: const Text("Verificare KYC",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Completată",
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Colors.green[600]),
                    ],
                  ),
                ),

                // Buton Suport
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.support_agent, color: Colors.blue[600]),
                  title: const Text("Chat Suport",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ChatBotScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.purple[600]),
                    title: const Text("Despre noi",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showAboutDialog,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Buton Logout
          Center(
            child: TextButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, color: Colors.red[600]),
              label: Text(
                "Log Out",
                style: TextStyle(color: Colors.red[600], fontSize: 16),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget ajutător pentru cardurile de statistici
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}