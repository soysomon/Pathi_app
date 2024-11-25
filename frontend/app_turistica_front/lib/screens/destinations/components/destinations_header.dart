import 'package:app_turistica_front/screens/home/components/icon_btn_with_counter.dart';
import 'package:app_turistica_front/screens/profile/profile_screen.dart';
import 'package:app_turistica_front/services/profile_image_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'search_field.dart';

class DestinationsHeader extends StatelessWidget {

  final Function(List<dynamic>) onSearchResults;

  const DestinationsHeader({
    Key? key,
    this.profileImage,
    required this.onSearchResults,
  }) : super(key: key);

  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    final profileImageService = Provider.of<ProfileImageService>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 9), // Margen inferior de 5px
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: SearchField(onSearchResults: onSearchResults)),
          const SizedBox(width: 16),
          Container(
            margin: const EdgeInsets.only(bottom: 7), // Margen inferior de 5px
            child: IconBtnWithCounter(
              press: () => Navigator.pushNamed(context, ProfileScreen.routeName),
              profileImage: profileImageService.imageUrl,
            ),
          ),
        ],
      ),
    );
  }
}