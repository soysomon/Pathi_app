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
    {"icon": Icons.thumb_up, "text": "Recomendado"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20), // Añade margen superior
      width: double.infinity, // Ocupa todo el ancho de la pantalla
      child: SizedBox(
        height: 100,
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
        margin: const EdgeInsets.symmetric(horizontal: 19), // Añade espacio horizontal entre categorías
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? const Color(0xFFFFECDF)
                    : const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(10),
                border: selectedIndex == index
                    ? Border.all(color: Colors.orange, width: 2)
                    : null,
              ),
              child: Icon(
                categories[index]["icon"],
                color: selectedIndex == index ? Colors.orange : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              categories[index]["text"]!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedIndex == index ? Colors.orange : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}