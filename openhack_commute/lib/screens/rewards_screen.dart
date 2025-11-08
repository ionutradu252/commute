import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// O clasă simplă pentru a ține datele recompenselor
class Reward {
  final String title;
  final int points;
  final String imageUrl;
  final Color color;

  Reward(
      {required this.title,
      required this.points,
      required this.imageUrl,
      required this.color});
}

// Lista de recompense simulate
final List<Reward> demoRewards = [
  Reward(
    title: "Voucher 50 RON Combustibil Petrom",
    points: 5000,
    imageUrl: "https://placehold.co/600x400/E53935/FFFFFF?text=Petrom",
    color: Colors.red[700]!,
  ),
  Reward(
    title: "Suc natural Auchan 1L",
    points: 750,
    imageUrl: "https://placehold.co/600x400/C62828/FFFFFF?text=Auchan",
    color: Colors.red[900]!,
  ),
  Reward(
    title: "Spălare auto Standard",
    points: 3000,
    imageUrl: "https://placehold.co/600x400/0288D1/FFFFFF?text=Spalatorie",
    color: Colors.blue[700]!,
  ),
  Reward(
    title: "Cafea espresso",
    points: 500,
    imageUrl: "https://placehold.co/600x400/6D4C41/FFFFFF?text=Cafea",
    color: Colors.brown[700]!,
  ),
  Reward(
    title: "Reducere 10% anvelope",
    points: 2500,
    imageUrl: "https://placehold.co/600x400/37474F/FFFFFF?text=Anvelope",
    color: Colors.blueGrey[700]!,
  ),
  Reward(
    title: "Odorizant auto",
    points: 300,
    imageUrl: "https://placehold.co/600x400/00695C/FFFFFF?text=Fresh",
    color: Colors.teal[700]!,
  ),
];

class RewardsScreen extends StatelessWidget {
  final int currentPoints;
  final Function(int) onSpendPoints;

  const RewardsScreen({
    super.key,
    required this.currentPoints,
    required this.onSpendPoints,
  });

  @override
  Widget build(BuildContext context) {
    // --- AICI ESTE LOGICA DE SORTARE ---
    List<Reward> claimableRewards = demoRewards
        .where((r) => currentPoints >= r.points)
        .toList();
    List<Reward> insufficientRewards = demoRewards
        .where((r) => currentPoints < r.points)
        .toList();

    // Sortează ambele liste după puncte (de la cel mai ieftin la cel mai scump)
    claimableRewards.sort((a, b) => a.points.compareTo(b.points));
    insufficientRewards.sort((a, b) => a.points.compareTo(b.points));

    // Combină listele: cele pe care le permiți sunt primele
    final List<Reward> sortedRewards = [
      ...claimableRewards,
      ...insufficientRewards
    ];
    // --- SFÂRȘITUL LOGICII DE SORTARE ---

    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: sortedRewards.length,
        itemBuilder: (context, index) {
          final reward = sortedRewards[index];
          // Verificăm din nou, pentru a dezactiva butoanele
          final bool canAfford = currentPoints >= reward.points;
          return _buildRewardCard(context, reward, canAfford);
        },
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, Reward reward, bool canAfford) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              reward.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stack) {
                return Container(
                  color: Colors.grey[200],
                  child:
                      Icon(Icons.broken_image, color: Colors.grey[400], size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text("${reward.points} Pct",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: reward.color,
                  avatar: const Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: canAfford
                  ? () {
                      // 1. Acum arătăm dialogul de CONFIRMARE
                      _showConfirmationDialog(context, reward);
                    }
                  : null, // Butonul este dezactivat
              style: ElevatedButton.styleFrom(
                backgroundColor: reward.color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(canAfford ? "Revendică" : "Puncte insuficiente"),
            ),
          )
        ],
      ),
    );
  }

  // --- MODIFICARE: Aceasta este NOUA Funcție 1 ---
  // Arată dialogul de confirmare ÎNAINTE de a afișa codul QR
  void _showConfirmationDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmare Revendicare"),
        content: Text(
            "Ești sigur că vrei să revendici '${reward.title}' pentru ${reward.points} puncte?"),
        actions: [
          TextButton(
            child: const Text("Anulează"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text("Confirmă"),
            onPressed: () {
              // 1. Scade punctele
              onSpendPoints(reward.points);
              // 2. Închide dialogul de confirmare
              Navigator.of(ctx).pop();
              // 3. Arată dialogul cu codul QR
              _showQrCodeDialog(context, reward);
            },
          ),
        ],
      ),
    );
  }

  // --- MODIFICARE: Aceasta este NOUA Funcție 2 ---
  // Arată dialogul final cu codul QR
  void _showQrCodeDialog(BuildContext context, Reward reward) {
    // Afișăm SnackBar-ul de succes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("${reward.title} revendicat!"),
          backgroundColor: Colors.green),
    );

    // Afișăm dialogul QR
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reward.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Felicitări! Prezintă acest cod QR:"),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: 'https://youtu.be/dQw4w9WgXcQ?si=ss9qqA4BniT8iWjL',
                version: QrVersions.auto,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Gata"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}