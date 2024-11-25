import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_turistica_front/screens/promotions/components/promotions_header.dart';
import 'package:app_turistica_front/screens/promotions/components/discount_banner.dart';
import 'package:app_turistica_front/screens/promotions/components/promotions_card.dart';
import 'package:shimmer/shimmer.dart';

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

class PromotionsList extends StatefulWidget {
  const PromotionsList({Key? key}) : super(key: key);

  @override
  _PromotionsListState createState() => _PromotionsListState();
}

class _PromotionsListState extends State<PromotionsList> {
  List<dynamic> promotions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPromotions();
  }

  Future<void> fetchPromotions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token no disponible, inicia sesión nuevamente')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('${dotenv.env['API_BASE_URL']}/listar_promociones'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        promotions = json.decode(response.body);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener las promociones')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 4, // Número de esqueletos a mostrar
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SkeletonPromotionCard(),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        final promotion = promotions[index];
        return PromotionCard(
          title: promotion['nombre_servicio'],
          description: promotion['detalles'],
          validUntil: promotion['fecha'],
        );
      },
    );
  }
}

class SkeletonPromotionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 50,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 18,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 100,
                    height: 14,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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