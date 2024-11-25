import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int selectedIndex = 0;
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.all_inclusive, "text": "Todo"},
    {"icon": Icons.star, "text": "Popular"},
    {"icon": Icons.location_on, "text": "Cercano"},
    {"icon": Icons.thumb_up, "text": "Sugerido"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) => buildCategory(index),
        ),
      ),
    );
  }

  Widget buildCategory(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16), // Aumenta el espacio entre categorías
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: selectedIndex == index ? const Color(0xFF47DCB6) : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: selectedIndex == index
                        ? const Color(0xFF47DCB6).withOpacity(0.5)
                        : Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                categories[index]["icon"],
                color: selectedIndex == index ? Colors.white : Colors.black,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              categories[index]["text"]!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedIndex == index ? const Color(0xFF47DCB6) : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}