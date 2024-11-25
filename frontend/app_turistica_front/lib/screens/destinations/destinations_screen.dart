import 'package:app_turistica_front/screens/destinations/components/business_card.dart';
import 'package:flutter/material.dart';
import 'components/destinations_header.dart';

class DestinationsScreen extends StatefulWidget {
  static String routeName = "/destinations";

  @override
  _DestinationsScreenState createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  List<dynamic> searchResults = [];

  void updateSearchResults(List<dynamic> results) {
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DestinationsContent(
        searchResults: searchResults,
        onSearchResults: updateSearchResults,
      ),
    );
  }
}

// Contenido de la pantalla de inicio
class DestinationsContent extends StatelessWidget {
    final List<dynamic> searchResults;
  final Function(List<dynamic>) onSearchResults;

  const DestinationsContent({
    Key? key,
    required this.searchResults,
    required this.onSearchResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            DestinationsHeader(onSearchResults: onSearchResults),
            const SizedBox(height: 20),
            DestinationsCard(searchResults: searchResults),
          ],
        ),
      ),
    );
  }
}
