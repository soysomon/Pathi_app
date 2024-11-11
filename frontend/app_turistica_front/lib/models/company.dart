// models/Company.dart
class Company {
  final String name;
  final String address;

  Company({
    required this.name,
    required this.address,
  });

  // Método para crear una instancia de Company desde un JSON
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      address: json['address'],
    );
  }

  // Método para convertir una instancia de Company a un JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
    };
  }
}