import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_turistica_front/screens/client/components/client_header.dart';
import 'package:app_turistica_front/screens/client/components/client_card.dart';
import 'package:shimmer/shimmer.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({Key? key}) : super(key: key);
  static String routeName = "/clients";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClientContent(),
    );
  }
}

class ClientsList extends StatefulWidget {
  const ClientsList({Key? key}) : super(key: key);

  @override
  _ClientsListState createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> {
  List<dynamic> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token no disponible, inicia sesión nuevamente')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('${dotenv.env['API_BASE_URL']}/listar_clientes'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        clients = json.decode(response.body);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener los clientes')),
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
        itemBuilder: (context, index) => SkeletonClientCard(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return ClientCard(
          image: client['imagen_empresarial'],
          clientName: client['nombre_usuario'],
          clientEmail: client['correo'],
          clientPhone: client['telefono'],
          clientDate: client['fecha'],
          clientTime: client['hora'],
          totalPayment: client['total_pagar'],
          userName: client['nombre_usuario'],
          userLocation: client['ubicacion'],
          userDetails: client['detalles'], onRemove: () {  },
        );
      },
    );
  }
}

class SkeletonClientCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClientContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const ClientHeader(),
            const ClientsList(),
          ],
        ),
      ),
    );
  }
}