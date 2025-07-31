import 'package:abbeav/config/global/constants/image_routes.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.onTap,
  });
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: /*Icon(
            Icons.play_arrow,
            size: 30,
          ),*/
              ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: SvgPicture.asset(AppImagesRoute.iconDownloadSelected,
                width: 24, height: 24),
          ),
        ),
      ),
    );
  }
}
