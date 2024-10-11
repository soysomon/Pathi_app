import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String message;

  const CustomTextWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,  // Puedes cambiar este color para ajustarlo a la paleta de la app
        ),
      ),
    );
  }
}
