import 'package:flutter/material.dart';
import 'destinations_details_card.dart';

class DestinationsCard extends StatelessWidget {
  final List<Map<String, dynamic>> destinations = [
    {
      "name": "Eiffel Tower",
      "image": "assets/images/eiffel_tower.png",
      "rating": 4.7,
      "location": "Champ de Mars, 5 Avenue Anatole France, 75007 Paris, France",
      "serviceDetails": "Iconic landmark of Paris, offering panoramic views of the city.",
      "press": () {},
    },
    {
      "name": "Statue of Liberty",
      "image": "assets/images/statue_of_liberty.png",
      "rating": 4.6,
      "location": "Liberty Island, New York, NY 10004, United States",
      "serviceDetails": "Famous symbol of freedom and democracy in the United States.",
      "press": () {},
    },
    {
      "name": "Great Wall of China",
      "image": "assets/images/great_wall_of_china.png",
      "rating": 4.8,
      "location": "Huairou District, China",
      "serviceDetails": "Ancient series of walls and fortifications, totaling more than 13,000 miles in length.",
      "press": () {},
    },
    {
      "name": "Sydney Opera House",
      "image": "assets/images/sydney_opera_house.png",
      "rating": 4.7,
      "location": "Bennelong Point, Sydney NSW 2000, Australia",
      "serviceDetails": "World-renowned performing arts center in Sydney.",
      "press": () {},
    },
  ];

  DestinationsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => DestinationDetailsCard(destination: destination),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 230,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.5),
                  child: Stack(
                    children: [
                      Image.asset(
                        destination['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.black38,
                              Colors.black26,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    destination['location'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
