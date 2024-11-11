import 'package:app_turistica_front/screens/profile/profile_screen.dart';
import 'package:app_turistica_front/screens/home/components/icon_btn_with_counter.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "¡Vamos a explorar!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          IconBtnWithCounter(
            svgSrc: "assets/icons/User Icon.svg",
            press: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          ),
        ],
      ),
    );
  }
}