import 'package:app_turistica_front/screens/client/clients_screen.dart';
import 'package:app_turistica_front/screens/destinations/destinations_screen.dart';
import 'package:app_turistica_front/screens/promotions/promotions_screen.dart';
import 'package:app_turistica_front/screens/reservations/reservations_screen.dart';
import 'package:app_turistica_front/screens/home/components/top_services.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Importa la pantalla de perfil
import 'components/categories.dart';
import 'components/home_header.dart';
import 'components/places.dart';
import 'package:app_turistica_front/services/profile_image_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String data = 'Cargando...';
  int _selectedIndex = 0;
  String? userRole;

  // Lista de pantallas para el BottomNavigationBar
  final List<Widget> _screens = [
    HomeContent(), // Contenido de la pantalla de inicio
    DestinationsScreen(),
    ReservationScreen(), // Pantalla de Reservas
    PromotionsScreen(),
    ClientsScreen(), // Pantalla de Clientes
  ];

    Future<void> fetchRol() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString('jwt_token'); // Recupera el token guardado
  
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${dotenv.env['API_BASE_URL']}/obtener_rol'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        );
  
        if (response.statusCode == 200) {
          final decodedData = json.decode(response.body);
          setState(() {
            userRole = decodedData['rol']; // Almacena el rol del usuario
            print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa${userRole}");
          });
  
          // Guarda el rol en SharedPreferences
          await prefs.setString('user_role', userRole!);
        } else if (response.statusCode == 404) {
          setState(() {
            data = 'Usuario no encontrado';
          });
        } else {
          setState(() {
            data = 'Error al obtener los datos: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          data = 'Error al realizar la solicitud: $e';
        });
      }
    } else {
      setState(() {
        data = 'Token no disponible';
      });
    }
  }

  // Función para hacer la solicitud GET al backend
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token =
        await prefs.getString('jwt_token'); // Recupera el token guardado

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
          final decodedData = json.decode(response.body);
          setState(() {
            data = decodedData['message'];
          });

          // Llama al servicio de imagen y establece la URL de la imagen
          final profileImageService =
              Provider.of<ProfileImageService>(context, listen: false);
          profileImageService.setImageUrl(
              decodedData['data']['foto_url'] ?? 'assets/avatar.png');
        } else if (response.statusCode == 404) {
          setState(() {
            data = 'Usuario no encontrado';
          });
        } else {
          setState(() {
            data = 'Error al obtener los datos: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          data = 'Error al realizar la solicitud: $e';
        });
      }
    } else {
      setState(() {
        data = 'Token no disponible';
      });
    }
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchData(),
      fetchRol(),
      Provider.of<ProfileImageService>(context, listen: false)
          .fetchProfileImage(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco de la pantalla
      body: _screens[_selectedIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Fondo completamente blanco
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.1), // Sombra para distinguir el menú
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2), // Sombra hacia arriba
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: 'Destinos',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Reservas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_offer),
              label: 'Promociones',
            ),
            if (userRole == 'empresa')
              const BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Clientes',
              ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor:
              const Color(0xFF47DCB6), // Color del ícono seleccionado
          unselectedItemColor:
              Colors.grey, // Color de los íconos no seleccionados
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: const IconThemeData(
            size: 30, // Tamaño del ícono seleccionado
          ),
          unselectedIconTheme: const IconThemeData(
            size: 24, // Tamaño de los íconos no seleccionados
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.white, // Fondo blanco del menú
        ),
      ),
    );
  }
}

// Contenido de la pantalla de inicio
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const HomeHeader(),
            const Categories(),
            const Places(),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            TopServices(), // Componente de servicios destacados
          ],
        ),
      ),
    );
  }
}
