import 'package:flutter/material.dart';

class TopServices extends StatelessWidget {
  const TopServices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Servicios Destacados",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: topServices.length,
          itemBuilder: (context, index) => TopServiceCard(service: topServices[index]),
        ),
      ],
    );
  }
}

class TopServiceCard extends StatelessWidget {
  const TopServiceCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  service.image,
                  width: 130,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      service.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "\$${service.price}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < service.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Service {
  final String title, image, location;
  final double price;
  final int rating;

  Service({
    required this.title,
    required this.image,
    required this.location,
    required this.price,
    required this.rating,
  });
}

final List<Service> topServices = [
  Service(
    title: "Tour por la ciudad",
    image: "assets/4.jpg",
    location: "Centro, Ciudad",
    price: 50.0,
    rating: 4,
  ),
  Service(
    title: "Excursión a la montaña",
    image: "assets/5.jpg",
    location: "Montañas, Ciudad",
    price: 75.0,
    rating: 5,
  ),
  Service(
    title: "Visita al museo",
    image: "assets/7.jpg",
    location: "Museo, Ciudad",
    price: 30.0,
    rating: 4,
  ),
];