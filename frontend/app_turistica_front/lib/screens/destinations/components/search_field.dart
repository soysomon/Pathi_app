import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';

class SearchField extends StatelessWidget {
  final Function(List<dynamic>) onSearchResults;

  const SearchField({
    Key? key,
    required this.onSearchResults,
  }) : super(key: key);

  Future<void> searchDestinations(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    final baseUrl = dotenv.env['API_BASE_URL'];
    final url = Uri.parse('$baseUrl/buscar-destinos?search=$query');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> destinations = json.decode(response.body);
      onSearchResults(destinations); // Llama al callback con los resultados
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        onChanged: (value) {
          if (value.isNotEmpty) {
            searchDestinations(value);
          } else {
            onSearchResults([]); // Limpia los resultados si el campo está vacío
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: kSecondaryColor.withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: searchOutlineInputBorder,
          focusedBorder: searchOutlineInputBorder,
          enabledBorder: searchOutlineInputBorder,
          hintText: "Search",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

const searchOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide.none,
);