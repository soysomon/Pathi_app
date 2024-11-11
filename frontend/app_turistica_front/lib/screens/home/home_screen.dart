import 'package:app_turistica_front/screens/destinations/destinations_screen.dart';
import 'package:app_turistica_front/screens/promotions/promotions_screen.dart';
import 'package:app_turistica_front/screens/reservations/reservations_screen.dart';
import 'package:app_turistica_front/screens/home/components/top_services.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importa la pantalla de perfil
import '../profile/profile_screen.dart';
import 'components/categories.dart';
import 'components/home_header.dart';
import 'components/places.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String data = 'Cargando...';
  int _selectedIndex = 0;

  // Lista de pantallas para el BottomNavigationBar
  final List<Widget> _screens = [
    HomeContent(), // Contenido de la pantalla de inicio
    DestinationsScreen(),
    ReservationScreen(), // Pantalla de Reservas
    PromotionsScreen(),
    ProfileScreen(), // Pantalla de Perfil
  ];

  // Función para hacer la solicitud GET al backend
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.50.251:3000/'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      setState(() {
        data = decodedData['message'];
      });
    } else {
      setState(() {
        data = 'Error al cargar los datos';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: 'Destinos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Reservas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer),
              label: 'Promociones',
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
