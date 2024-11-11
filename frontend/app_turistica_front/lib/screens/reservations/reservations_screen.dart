import 'package:app_turistica_front/screens/reservations/components/reservation_header.dart';

import 'package:flutter/material.dart';
import '../reservations/components/reservation_card.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({Key? key}) : super(key: key);
  static String routeName = "/reservations";

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReservationContent(),
    );
  }
}

class ReservationsList extends StatelessWidget {
  const ReservationsList({
    Key? key,
  }) : super(key: key);

  final List<Map<String, dynamic>> reservations = const [
    {
      "image": "assets/images/Image Banner 2.png",
      "name": "Restaurante El Buen Sabor",
      "rating": 4.5,
      "location": "Calle 123, Ciudad",
      "date": "2023-10-01",
      "time": "19:00",
    },
    {
      "image": "assets/images/Image Banner 3.png",
      "name": "Restaurante La Buena Mesa",
      "rating": 4.0,
      "location": "Avenida 456, Ciudad",
      "date": "2023-10-02",
      "time": "20:00",
    },
    // Agrega más reservas aquí
  ];           


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return ReservationCard(
          image: reservation['image'],
          name: reservation['name'],
          rating: reservation['rating'],
          location: reservation['location'],
          date: reservation['date'],
          time: reservation['time'],
        );
      },
    );
  }
}

class ReservationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const ReservationHeader(),
            const ReservationsList(),
          ],
        ),
      ),
    );
  }
}