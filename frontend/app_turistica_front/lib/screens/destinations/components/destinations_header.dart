import 'package:app_turistica_front/screens/destinations/components/icon_btn_with_counter.dart';
import 'package:app_turistica_front/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'search_field.dart';

class DestinationsHeader extends StatelessWidget {
  const DestinationsHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: SearchField()),
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
