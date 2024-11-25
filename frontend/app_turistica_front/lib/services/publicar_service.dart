import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PublicarService {
  final String baseUrl;

  PublicarService() : baseUrl = dotenv.env['API_BASE_URL']!;

  Future<bool?> getPublicoStatus(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Token no disponible');
    }

    try {
      final uri = Uri.parse('$baseUrl/usuarios/$userId/publico');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['publico'];
      } else {
        throw Exception('Error al obtener el estado del campo publico');
      }
    } catch (e) {
      throw Exception('Error de conexión al servidor: $e');
    }
  }

  Future<bool> togglePublicoStatus(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Token no disponible');
    }

    try {
      final uri = Uri.parse('$baseUrl/usuarios/$userId/toggle-publico');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['publico'];
      } else {
        throw Exception('Error al actualizar el estado del campo publico');
      }
    } catch (e) {
      throw Exception('Error de conexión al servidor: $e');
    }
  }
}