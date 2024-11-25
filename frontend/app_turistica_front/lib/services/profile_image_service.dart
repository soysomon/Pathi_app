import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileImageService with ChangeNotifier {
  String _imageUrl = 'assets/User Icon.svg';

  String get imageUrl => _imageUrl;

  ProfileImageService() {
    fetchProfileImage();
  }

  Future<void> fetchProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${dotenv.env['API_BASE_URL']}/perfil'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final imageUrl = data['foto_url'] ?? 'assets/avatar.png';
          setImageUrl(imageUrl);
        } else {
          print('Error al obtener los datos del perfil: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al realizar la solicitud: $e');
      }
    } else {
      print('Token no disponible');
    }
  }

  void setImageUrl(String url) {
    if (url.contains('http://localhost:3000')) {
      final String apiUrl = dotenv.env['API_BASE_URL']!;
      _imageUrl = url.replaceFirst('http://localhost:3000', apiUrl);
    } else {
      _imageUrl = url;
    }
    notifyListeners();
  }

  void clearImageUrl() {
    _imageUrl = 'assets/User Icon.svg'; // O cualquier URL predeterminada
    notifyListeners();
  }
}