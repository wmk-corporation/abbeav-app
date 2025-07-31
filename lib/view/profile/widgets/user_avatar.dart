import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../config/global/constants/image_routes.dart';

class UserAvatar extends StatelessWidget {
  final String? image; // Peut être un chemin local ou une URL
  final VoidCallback onTap;

  const UserAvatar({
    required this.image,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          backgroundColor: Colors.black,
          foregroundImage: _getImageProvider(),
          radius: 60,
          child: _buildFallbackChild(),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.01,
          right: MediaQuery.of(context).size.width * 0.001,
          child: GestureDetector(
            onTap: onTap,
            child: SvgPicture.asset(AppImagesRoute.iconEditProfile),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (image == null) return null;

    if (image!.startsWith('http')) {
      return NetworkImage(image!);
    } else if (image!.startsWith('assets/')) {
      return AssetImage(image!);
    } else {
      return FileImage(File(image!));
    }
  }

  Widget? _buildFallbackChild() {
    if (image == null ||
        (image!.startsWith('http') && _getImageProvider() == null)) {
      return const Icon(Icons.person, size: 50, color: Colors.white);
    }
    return null;
  }
}

/*class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.image,
    required this.onTap,
  });

  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          backgroundColor: Colors.black,
          foregroundImage: AssetImage(image),
          radius: 60,
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.01,
          right: MediaQuery.of(context).size.width * 0.001,
          child: GestureDetector(
            onTap: onTap,
            child: SvgPicture.asset(AppImagesRoute.iconEditProfile),
          ),
        ),
      ],
    );
  }
}*/
