import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  final List<dynamic> results;

  const SearchResults({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          title: Text(result['nombre_usuario']),
          subtitle: Text(result['ubicacion']),
          onTap: () {
            // Manejar la acción al seleccionar un destino
          },
        );
      },
    );
  }
}