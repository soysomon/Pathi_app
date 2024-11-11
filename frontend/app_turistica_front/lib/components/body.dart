// body.dart
import 'package:flutter/material.dart';

import '../../../models/Service.dart';
import 'service_description.dart';
import 'company_info.dart';

class Body extends StatelessWidget {
  final Service service;

  const Body({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(service.images[0]),
          const SizedBox(height: 20),
          ServiceDescription(service: service),
          const SizedBox(height: 20),
          CompanyInfo(company: service.company),
        ],
      ),
    );
  }
}