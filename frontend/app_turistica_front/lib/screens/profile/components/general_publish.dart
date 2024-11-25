import 'package:flutter/material.dart';
import 'package:app_turistica_front/services/publicar_service.dart'; // Asegúrate de importar el servicio correctamente

class MostrarCompaniaSwitch extends StatefulWidget {
  final bool isPublico;
  final String userId;

  const MostrarCompaniaSwitch({
    Key? key,
    required this.isPublico,
    required this.userId,
  }) : super(key: key);

  @override
  _MostrarCompaniaSwitchState createState() => _MostrarCompaniaSwitchState();
}

class _MostrarCompaniaSwitchState extends State<MostrarCompaniaSwitch> {
  late bool isPublico;
  final PublicarService publicarService = PublicarService();

  @override
  void initState() {
    super.initState();
    isPublico = widget.isPublico;
  }

  Future<void> _togglePublicoStatus() async {
    try {
      final newStatus = await publicarService.togglePublicoStatus(widget.userId);
      setState(() {
        isPublico = newStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Mostrar Compañia",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: isPublico,
            onChanged: (value) => _togglePublicoStatus(),
          ),
        ],
      ),
    );
  }
}