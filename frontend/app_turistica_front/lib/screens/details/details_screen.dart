// details_screen.dart
import 'package:flutter/material.dart';

import '../../models/Service.dart';
import '../../components/body.dart';

class DetailsScreen extends StatelessWidget {
  static String routeName = "/details";

  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceDetailsArguments args =
        ModalRoute.of(context)!.settings.arguments as ServiceDetailsArguments;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: Text(args.service.title),
      ),
      body: Body(service: args.service),
    );
  }
}

class ServiceDetailsArguments {
  final Service service;

  ServiceDetailsArguments({required this.service});
}// TODO Implement this library.