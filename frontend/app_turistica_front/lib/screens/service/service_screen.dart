// services_screen.dart
import 'package:flutter/material.dart';
import '../../components/service_card.dart';
import '../../models/Service.dart';
import '../../models/Company.dart';

import '../details/details_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static String routeName = "/services";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            itemCount: demoServices.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.7,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) => ServiceCard(
              service: demoServices[index],
              onPress: () => Navigator.pushNamed(
                context,
                DetailsScreen.routeName,
                arguments: ServiceDetailsArguments(service: demoServices[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Lista de servicios de demostración
List<Service> demoServices = [
  Service(
    title: "Service 1",
    description: "Description of Service 1",
    price: 50.0,
    isFavourite: true,
    images: ["assets/images/service1.png"],
    company: Company(
      name: "Company 1",
      address: "123 Street, City",
    ),
  ),
  Service(
    title: "Service 2",
    description: "Description of Service 2",
    price: 30.0,
    isFavourite: false,
    images: ["assets/images/service2.png"],
    company: Company(
      name: "Company 2",
      address: "456 Avenue, City",
    ),
  ),
  // Agrega más servicios de demostración según sea necesario
];