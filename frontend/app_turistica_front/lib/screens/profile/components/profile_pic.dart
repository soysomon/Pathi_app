import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    Key? key,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.onImageTap,
    required this.onEditTap,
    this.isLoading = false,
  }) : super(key: key);

  final String name;
  final String email;
  final String imagePath;
  final VoidCallback onImageTap;
  final VoidCallback onEditTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 15, 192, 252),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: onEditTap,
        child: Row(
          children: [
            GestureDetector(
              onTap: onImageTap,
              child: SizedBox(
                height: 100, // Aumenta el tamaño aquí
                width: 100,  // Aumenta el tamaño aquí
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 75, // Aumenta el tamaño aquí
                      backgroundColor: Colors.transparent,
                      child: CachedNetworkImage(
                        imageUrl: imagePath,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: CircleAvatar(
                            radius: 75, // Aumenta el tamaño aquí
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset('assets/avatar.png'),
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 75, // Aumenta el tamaño aquí
                          backgroundImage: imageProvider,
                        ),
                      ),
                    ),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    Positioned(
                      right: -16,
                      bottom: 0,
                      child: SizedBox(
                        height: 46,
                        width: 46,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: const BorderSide(color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFFF5F6F9),
                          ),
                          onPressed: onImageTap,
                          child: SvgPicture.asset("assets/icons/Camera Icon.svg"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}