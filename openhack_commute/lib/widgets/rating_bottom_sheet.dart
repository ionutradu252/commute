import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/driver.dart';

class RatingBottomSheet extends StatefulWidget {
  final DriverRoute driver;
  const RatingBottomSheet({super.key, required this.driver});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  double _rating = 4.0;
  int _selectedTip = 0; // 0 = Fără tips, 5 = 5 RON, 10 = 10 RON, -1 = Custom
  final _customTipController = TextEditingController();

  @override
  void dispose() {
    _customTipController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    String tipAmount = "";
    if (_selectedTip == -1) {
      tipAmount = _customTipController.text;
    } else if (_selectedTip > 0) {
      tipAmount = "$_selectedTip RON";
    } else {
      tipAmount = "Fără tips";
    }

    print("--- Feedback Trimis ---");
    print("Șofer: ${widget.driver.name}");
    print("Rating: $_rating stele");
    print("Tips: $tipAmount");
    // TODO: Aici ai scrie în Firebase

    // --- AICI ESTE MODIFICAREA ---
    // Închide panoul și returnează 'true' pentru a semnala succesul
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    // Folosim Padding pentru a evita tastatura
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20,
          MediaQuery.of(context).viewInsets.bottom + 20), // Evită tastatura
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titlu
          Text(
            "Cum a fost cursa cu ${widget.driver.name}?",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Rating cu Steluțe
          Center(
            child: RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() => _rating = rating);
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Review (mesaj)
          TextField(
            decoration: InputDecoration(
              hintText: "Lasă un mesaj (opțional)...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          
          // Secțiune Tips
          const Text(
            "Lasă o recompensă (tips)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          
          Wrap(
            spacing: 10.0,
            children: [
              ChoiceChip(
                label: const Text("Fără tips"),
                selected: _selectedTip == 0,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTip = 0);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              ChoiceChip(
                label: const Text("5 RON"),
                selected: _selectedTip == 5,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTip = 5);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              ChoiceChip(
                label: const Text("10 RON"),
                selected: _selectedTip == 10,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTip = 10);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              ChoiceChip(
                label: const Text("Altă sumă"),
                selected: _selectedTip == -1,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTip = -1);
                },
              ),
            ],
          ),
          
          // Câmp pentru tips custom (apare condiționat)
          if (_selectedTip == -1)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextField(
                controller: _customTipController,
                decoration: InputDecoration(
                  labelText: "Sumă personalizată (RON)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          
          const SizedBox(height: 20),

          // Buton de trimitere
          ElevatedButton(
            onPressed: _submitFeedback,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.teal,
            ),
            child: const Text("Trimite Feedback",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}