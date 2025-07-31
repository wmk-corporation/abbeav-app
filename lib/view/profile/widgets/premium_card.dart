import 'package:abbeav/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../premium/premium_screen.dart';

class PremiumCard extends StatefulWidget {
  const PremiumCard({super.key});

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _gradientAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PremiumScreen(),
        ),
      ),
      child: AnimatedBuilder(
        animation: _gradientAnim,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3DCBFF).withOpacity(.3),
                  Color(0xFF7D3CF8).withOpacity(.3)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  _gradientAnim.value * 0.5,
                  1 - _gradientAnim.value * 0.5
                ],
                transform: GradientRotation(_gradientAnim.value * 3.14),
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3DCBFF).withOpacity(0.13),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: SvgPicture.asset(
                      'assets/images/icon_premium.svg',
                      width: 38,
                      height: 38,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 600),
                          style: theme.textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF3DCBFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ) ??
                              const TextStyle(
                                color: Color(0xFF3DCBFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                          child: const Text('Premium'),
                        ),
                        const SizedBox(height: 6),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 600),
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 13.5,
                                height: 1.3,
                              ) ??
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                height: 1.3,
                              ),
                          child: Text(
                            appLocalizations!.bodyPremium!,
                            //'Films Full-HD sans pub, accès illimité, nouveautés en avant-première.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedScale(
                    scale: 1 + (_gradientAnim.value * 0.08),
                    duration: const Duration(milliseconds: 600),
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
                        'assets/images/icon_arrow_right.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
