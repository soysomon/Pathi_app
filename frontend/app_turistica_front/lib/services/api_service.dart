import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.0.150:3000';

  // Obtener datos de perfil
  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/perfil'),
      headers: {
        'Authorization': 'Bearer $token',  // Enviar el token en la cabecera
        'Content-Type': 'application/json', // Asegúrate de incluir el tipo de contenido
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error al obtener el perfil: ${response.statusCode}');
      throw Exception('Error al obtener el perfil');
    }
  }
}
