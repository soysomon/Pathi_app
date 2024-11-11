import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final String validUntil;

  const PromotionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.validUntil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(184, 226, 255, 251), // Color verde claro
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.local_offer, color: Colors.red),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            Text('Válido hasta: $validUntil'),
          ],
        ),
      ),
    );
  }
}