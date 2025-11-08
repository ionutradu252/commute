// lib/screens/driver_reviews_screen.dart
import 'package:flutter/material.dart';
import '../models/driver.dart';

class DriverReviewsScreen extends StatelessWidget {
  final DriverRoute driver;
  const DriverReviewsScreen({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    // 🔹 Demo: câteva review-uri simulate
    final reviews = <Map<String, dynamic>>[
      {
        'name': 'Andrei Pop',
        'rating': 5,
        'text': 'Foarte punctual și amabil! Muzică la volum ok.',
        'avatar': 'https://ui-avatars.com/api/?name=Andrei+Pop&background=00897B&color=fff&size=100',
        'date': 'ieri'
      },
      {
        'name': 'Ioana D.',
        'rating': 4,
        'text': 'Mașina curată, condus relaxat. Ușor ocol, dar ok.',
        'avatar': 'https://ui-avatars.com/api/?name=Ioana+D&background=00897B&color=fff&size=100',
        'date': 'acum 3 zile'
      },
      {
        'name': 'Marius G.',
        'rating': 5,
        'text': 'Experiență foarte bună, recomand!',
        'avatar': 'https://ui-avatars.com/api/?name=Marius+G&background=00897B&color=fff&size=100',
        'date': 'săptămâna trecută'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Recenzii — ${driver.name}'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) {
          final r = reviews[i];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundImage: NetworkImage(r['avatar']), radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(r['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(width: 8),
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      Text('${r['rating']}',
                          style: const TextStyle(fontSize: 13)),
                      const Spacer(),
                      Text(r['date'],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ]),
                    const SizedBox(height: 6),
                    Text(r['text']),
                  ],
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemCount: reviews.length,
      ),
    );
  }
}
