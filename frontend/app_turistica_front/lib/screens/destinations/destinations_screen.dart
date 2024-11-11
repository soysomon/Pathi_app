import 'package:app_turistica_front/screens/destinations/components/business_card.dart';
import 'package:app_turistica_front/screens/destinations/components/services.dart';
import 'package:flutter/material.dart';
import 'components/destinations_header.dart'; // Asegúrate de importar el archivo correcto

class DestinationsScreen extends StatelessWidget {
  static String routeName = "/destinations";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DestinationsContent(),
    );
  }
}

// Contenido de la pantalla de inicio
class DestinationsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const DestinationsHeader(),
            const SizedBox(height: 20),
            const Services(),
            const SizedBox(height: 20),
            DestinationsCard(), // 
          ],
        ),
      ),
    );
  }
}
