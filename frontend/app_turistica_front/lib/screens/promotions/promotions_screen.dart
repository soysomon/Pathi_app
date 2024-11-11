import 'package:flutter/material.dart';
import 'package:app_turistica_front/screens/promotions/components/promotions_header.dart';
import 'package:app_turistica_front/screens/promotions/components/discount_banner.dart';
import 'package:app_turistica_front/screens/promotions/components/promotions_card.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({Key? key}) : super(key: key);
  static String routeName = "/promotions";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PromotionsContent(),
    );
  }
}

class PromotionsList extends StatelessWidget {
  const PromotionsList({
    Key? key,
  }) : super(key: key);

  final List<Map<String, dynamic>> promotions = const [
    {
      "title": "Descuento en Restaurante A",
      "description": "20% de descuento en tu próxima visita",
      "validUntil": "2023-12-31",
    },
    {
      "title": "Oferta en Restaurante B",
      "description": "2x1 en platos seleccionados",
      "validUntil": "2023-11-30",
    },
    // Agrega más promociones aquí
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        final promotion = promotions[index];
        return PromotionCard(
          title: promotion['title'],
          description: promotion['description'],
          validUntil: promotion['validUntil'],
        );
      },
    );
  }
}

class PromotionsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const PromotionsHeader(),
            const DiscountBanner(),
            const PromotionsList(),
          ],
        ),
      ),
    );
  }
}