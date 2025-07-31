import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';

class BottomBarButton extends StatelessWidget {
  const BottomBarButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });
  final String icon;
  final String title;
  final bool isSelected;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            height: 25,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              blendMode: isSelected ? BlendMode.srcIn : BlendMode.dstIn,
              child: Image.asset(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ),
          AppSpacing.h5,
          Text(
            title,
            style:
                TextStyle(color: isSelected ? AppColor.secondary : Colors.grey),
          )
        ],
      ),
    );
  }
}
