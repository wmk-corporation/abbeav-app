import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:abbeav/config/global/constants/app_static_data.dart';
import '../../../config/global/constants/image_routes.dart';
import '../../../config/theme/app_colors.dart';

class ProfileOptionItem extends StatelessWidget {
  final int index;
  const ProfileOptionItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: SvgPicture.asset(
              AppStaticData.profileOptionsData[index][1],
              width: 28,
              height: 28,
            ),
          ),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ) ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
            child: Text(AppStaticData.profileOptionsData[index][0]),
          ),
          minLeadingWidth: 20,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          visualDensity: const VisualDensity(vertical: -2),
          trailing: _buildTrailing(context, theme),
          onTap: () {
            // Ajoute ici la navigation ou l'action associée à chaque option
          },
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, ThemeData theme) {
    if (index == 4) {
      // Langue
      return AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
            ) ??
            const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15,
            ),
        child: const Text('English (US)'),
      );
    }
    // Flèche animée pour les autres options
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: SvgPicture.asset(
          AppImagesRoute.iconArrowRight,
          width: 22,
          height: 22,
        ),
      ),
    );
  }
}

/*class ProfileOptionItem extends StatelessWidget {
  final int index;
  const ProfileOptionItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: SvgPicture.asset(
              AppStaticData.profileOptionsData[index][1],
              width: 28,
              height: 28,
            ),
          ),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ) ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
            child: Text(AppStaticData.profileOptionsData[index][0]),
          ),
          minLeadingWidth: 20,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          visualDensity: const VisualDensity(vertical: -2),
          trailing: _buildTrailing(context, theme),
          onTap: () {
            // Ajoute ici la navigation ou l'action associée à chaque option
          },
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, ThemeData theme) {
    if (index == 4) {
      // Langue
      return AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
            ) ??
            const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 15,
            ),
        child: const Text('English (US)'),
      );
    }
    // Flèche animée pour les autres options
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: SvgPicture.asset(
          AppImagesRoute.iconArrowRight,
          width: 22,
          height: 22,
        ),
      ),
    );
  }
}*/
