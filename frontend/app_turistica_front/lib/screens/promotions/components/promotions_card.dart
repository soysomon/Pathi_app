import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    // Parse and format the date
    final DateTime parsedDate = DateTime.parse(validUntil);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: Colors.redAccent, size: 35),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                SizedBox(width: 5),
                Text(
                  'Válido hasta: $formattedDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}