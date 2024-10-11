import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importa la pantalla de perfil
import ' profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String data = 'Cargando...';
  int _selectedIndex = 0;

  // Lista de pantallas para el BottomNavigationBar
  final List<Widget> _screens = [
    HomeContent(), // Puedes crear un widget para el contenido de inicio
    Center(child: Text('Pantalla Destinos')),
    Center(child: Text('Pantalla Reservas')),
    Center(child: Text('Pantalla Promociones')),
    ProfileScreen(), // Pantalla de Perfil
  ];

  // Función para hacer la solicitud GET al backend
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://10.0.0.150:3000/'));

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
              color: Colors.black.withOpacity(0.1), // Sombra para distinguir el menú
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF47DCB6), // Color del ícono seleccionado
          unselectedItemColor: Colors.grey, // Color de los íconos no seleccionados
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
    return Center(
      child: Text(
        'Pantalla de Inicio',
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }
}
