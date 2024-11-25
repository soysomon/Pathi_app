import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class IconBtnWithCounter extends StatelessWidget {
  const IconBtnWithCounter({
    Key? key,
    required this.press,
    this.profileImage,
  }) : super(key: key);

  final VoidCallback press;
  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          profileImage != null
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedNetworkImageProvider(profileImage!),
                  child: CachedNetworkImage(
                    imageUrl: profileImage!,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 30,
                      backgroundImage: imageProvider,
                    ),
                  ),
                )
              : Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
        ],
      ),
    );
  }
}