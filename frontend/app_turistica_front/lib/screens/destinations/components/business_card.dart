import 'package:app_turistica_front/screens/destinations/components/destinations_details_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class DestinationsCard extends StatefulWidget {
  final List<dynamic> searchResults;

  const DestinationsCard({
    Key? key,
    required this.searchResults,
  }) : super(key: key);

  @override
  _DestinationsCardState createState() => _DestinationsCardState();
}

class _DestinationsCardState extends State<DestinationsCard> {
  List<Map<String, dynamic>> destinations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDestinations();
  }

  Future<void> fetchDestinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token'); // Obtén el token de autenticación
      final uri = Uri.parse('${dotenv.env['API_BASE_URL']}/destinos');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token', // Incluye el token en los encabezados
      });

      if (response.statusCode == 200) {
        setState(() {
          destinations = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print('Failed to load destinations: ${response.statusCode}');
        throw Exception('Failed to load destinations');
      }
    } catch (e) {
      print('Error fetching destinations: $e');
      throw Exception('Failed to load destinations');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> displayList = widget.searchResults.isNotEmpty
        ? List<Map<String, dynamic>>.from(widget.searchResults)
        : destinations;

    return isLoading
        ? GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.5),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
              );
            },
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final destination = displayList[index];
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => DestinationDetailsCard(
                      destination: destination,
                      destinationId: int.parse(destination['id'].toString()), // Asegúrate de que destinationId sea un entero
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 230,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.5),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: destination['imagen_empresarial'] != null
                                  ? '${dotenv.env['API_BASE_URL']}/${destination['imagen_empresarial']}'
                                  : '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black54,
                                    Colors.black38,
                                    Colors.black26,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destination['nombre_usuario'] ?? 'Nombre no disponible',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          destination['ubicacion'] ?? 'Ubicación no disponible',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}