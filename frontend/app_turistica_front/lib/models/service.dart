import 'Company.dart';

class Service {
  final String title;
  final String description;
  final double price;
  final bool isFavourite;
  final List<String> images;
  final Company company; // Definir la propiedad company

  Service({
    required this.title,
    required this.description,
    required this.price,
    required this.isFavourite,
    required this.images,
    required this.company, // Inicializar la propiedad company
  });

  // Método para crear una instancia de Service desde un JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      title: json['title'],
      description: json['description'],
      price: json['price'],
      isFavourite: json['isFavourite'],
      images: List<String>.from(json['images']),
      company: Company.fromJson(json['company']), // Inicializar company desde JSON
    );
  }

  // Getter para la propiedad company
  Company get getCompany => company;

  // Método para convertir una instancia de Service a un JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'isFavourite': isFavourite,
      'images': images,
      'company': company.toJson(), // Convertir company a JSON
    };
  }
}