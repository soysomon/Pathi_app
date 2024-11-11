// models/reservation.dart
import 'Company.dart';
import 'Service.dart';

class Reservation {
  final Service service;
  final int quantity;
  final Company company;

  Reservation({
    required this.service,
    required this.quantity,
    required this.company,
  });

  // Método para crear una instancia de Reservation desde un JSON
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      service: Service.fromJson(json['service']),
      quantity: json['quantity'],
      company: Company.fromJson(json['company']),
    );
  }

  // Método para convertir una instancia de Reservation a un JSON
  Map<String, dynamic> toJson() {
    return {
      'service': service.toJson(),
      'quantity': quantity,
      'company': company.toJson(),
    };
  }
}