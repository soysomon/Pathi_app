import 'package:app_turistica_front/screens/profile/profile_screen.dart';
import 'package:app_turistica_front/services/profile_image_service.dart';
import 'package:flutter/material.dart';
import 'package:app_turistica_front/screens/home/components/icon_btn_with_counter.dart';
import 'package:provider/provider.dart';

class PromotionsHeader extends StatelessWidget {
  const PromotionsHeader({
    Key? key,
    this.profileImage,
  }) : super(key: key);

  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    final profileImageService = Provider.of<ProfileImageService>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Promociones",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          IconBtnWithCounter(
            press: () => Navigator.pushNamed(context, ProfileScreen.routeName),
            profileImage: profileImageService.imageUrl,

          ),
        ],
      ),
    );
  }
}