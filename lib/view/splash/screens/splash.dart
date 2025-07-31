import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/display.dart';
import 'package:abbeav/view/home/screens/home_screen.dart';
import 'package:abbeav/view/home/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _bgBlobController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initAnimations();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Attendre que les animations soient initialisées
    await Future.delayed(const Duration(milliseconds: 500));
    _checkAuthStatus();
  }

  /*Future<void> _checkAuthStatus() async {
    try {
      final userController =
          Provider.of<UserController>(context, listen: false);
      final isLoggedIn = await userController.getCurrentUser() != null;

      if (!mounted) return;

      // Attendre que l'animation du logo soit terminée (2800ms) + un délai supplémentaire
      final remainingDelay = max(0, 3500 - 2800);
      await Future.delayed(Duration(milliseconds: remainingDelay));

      if (isLoggedIn) {
        _navigateToHome();
      } else {
        _navigateToDisplay();
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      // En cas d'erreur, rediriger vers l'écran de connexion
      if (mounted) _navigateToDisplay();
    }
  }*/

  Future<void> _checkAuthStatus() async {
    try {
      // Utilisez read au lieu de watch car nous ne surveillons pas les changements
      final userController = context.read<UserController>();
      final isLoggedIn = await userController.getCurrentUser() != null;

      if (!mounted) return;

      final remainingDelay = max(0, 3500 - 2800);
      await Future.delayed(Duration(milliseconds: remainingDelay));

      if (isLoggedIn) {
        _navigateToHome();
      } else {
        _navigateToDisplay();
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      if (mounted) _navigateToDisplay();
    }
  }

  void _initAnimations() {
    _bgBlobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.55)
              .chain(CurveTween(curve: Curves.easeOutQuint)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.55, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50),
    ]).animate(_logoController);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoController.forward();
  }

  void _initParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        color: i % 3 == 0
            ? const Color(0xFF3DCBFF)
            : i % 2 == 0
                ? const Color(0xFF7D3CF8)
                : Colors.white.withOpacity(0.6),
        speed: Random().nextDouble() * 0.5 + 0.2,
        radius: Random().nextDouble() * 4 + 2,
        angle: Random().nextDouble() * 2 * pi,
        distance: Random().nextDouble() * 100 + 50,
      ));
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _navigateToDisplay() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DisplayScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.98,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                )),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgBlobController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBlob({
    required double size,
    required List<Color> colors,
    required double blur,
    required double angle,
    required Animation<double> controller,
    required double radius,
    required Offset center,
    double opacity = 1.0,
    bool isPulsating = false,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final theta = angle + t * 2 * pi;
        final scale = isPulsating ? 1.0 + 0.1 * sin(t * 2 * pi) : 1.0;
        final left = center.dx + radius * cos(theta) - size / 2;
        final top = center.dy + radius * sin(theta) - size / 2;

        return Transform.translate(
          offset: Offset(left, top),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: colors.map((c) => c.withOpacity(opacity)).toList(),
                  stops: const [0.4, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoFade.value,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/logos/logo_abbeav.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final logoSize = size.width * 0.35;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppColor.primary,
                  AppColor.primary,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: _buildLogo(),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _bgBlobController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.1 * sin(_bgBlobController.value * 2 * pi),
                        0.1 * cos(_bgBlobController.value * 2 * pi),
                      ),
                      radius: 1.5,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withOpacity(
                            0.01 * sin(_bgBlobController.value * pi)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  final Color color;
  final double speed;
  final double radius;
  double angle;
  final double distance;

  Particle({
    required this.color,
    required this.speed,
    required this.radius,
    required this.angle,
    required this.distance,
  });
}

/*import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/display.dart';
import 'package:abbeav/view/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _bgBlobController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initAnimations();
    _checkAuthAndNavigate();
  }

  void _initAnimations() {
    _bgBlobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.55)
              .chain(CurveTween(curve: Curves.easeOutQuint)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.55, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50),
    ]).animate(_logoController);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoController.forward().then((_) {
      _textController.forward();
    });
  }

  void _initParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        color: i % 3 == 0
            ? const Color(0xFF3DCBFF)
            : i % 2 == 0
                ? const Color(0xFF7D3CF8)
                : Colors.white.withOpacity(0.6),
        speed: Random().nextDouble() * 0.5 + 0.2,
        radius: Random().nextDouble() * 4 + 2,
        angle: Random().nextDouble() * 2 * pi,
        distance: Random().nextDouble() * 100 + 50,
      ));
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    // Attendre que les animations soient terminées
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    final userController = Provider.of<UserController>(context, listen: false);
    final isLoggedIn = await userController.getCurrentUser() != null;

    if (!mounted) return;

    if (isLoggedIn) {
      _navigateToHome();
    } else {
      _navigateToDisplay();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _navigateToDisplay() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DisplayScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.98,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                )),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgBlobController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBlob({
    required double size,
    required List<Color> colors,
    required double blur,
    required double angle,
    required Animation<double> controller,
    required double radius,
    required Offset center,
    double opacity = 1.0,
    bool isPulsating = false,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final theta = angle + t * 2 * pi;
        final scale = isPulsating ? 1.0 + 0.1 * sin(t * 2 * pi) : 1.0;
        final left = center.dx + radius * cos(theta) - size / 2;
        final top = center.dy + radius * sin(theta) - size / 2;

        return Transform.translate(
          offset: Offset(left, top),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: colors.map((c) => c.withOpacity(opacity)).toList(),
                  stops: const [0.4, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoFade.value,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/logos/logo_abbeav.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final logoSize = size.width * 0.35;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppColor.primary,
                  AppColor.primary,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: _buildLogo(),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _bgBlobController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.1 * sin(_bgBlobController.value * 2 * pi),
                        0.1 * cos(_bgBlobController.value * 2 * pi),
                      ),
                      radius: 1.5,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withOpacity(
                            0.01 * sin(_bgBlobController.value * pi)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  final Color color;
  final double speed;
  final double radius;
  double angle;
  final double distance;

  Particle({
    required this.color,
    required this.speed,
    required this.radius,
    required this.angle,
    required this.distance,
  });
}*/

/*import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:abbeav/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/view/auth/screens/display.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _bgBlobController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initParticles();

    _bgBlobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.55)
              .chain(CurveTween(curve: Curves.easeOutQuint)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.55, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50),
    ]).animate(_logoController);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoController.forward().then((_) {
      _textController.forward();
    });

    Timer(const Duration(milliseconds: 5500), _navigateToDisplay);
  }

  void _initParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        color: i % 3 == 0
            ? const Color(0xFF3DCBFF)
            : i % 2 == 0
                ? const Color(0xFF7D3CF8)
                : Colors.white.withOpacity(0.6),
        speed: Random().nextDouble() * 0.5 + 0.2,
        radius: Random().nextDouble() * 4 + 2,
        angle: Random().nextDouble() * 2 * pi,
        distance: Random().nextDouble() * 100 + 50,
      ));
    }
  }

  void _navigateToDisplay() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DisplayScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.98,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                )),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgBlobController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBlob({
    required double size,
    required List<Color> colors,
    required double blur,
    required double angle,
    required Animation<double> controller,
    required double radius,
    required Offset center,
    double opacity = 1.0,
    bool isPulsating = false,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final theta = angle + t * 2 * pi;
        final scale = isPulsating ? 1.0 + 0.1 * sin(t * 2 * pi) : 1.0;
        final left = center.dx + radius * cos(theta) - size / 2;
        final top = center.dy + radius * sin(theta) - size / 2;

        return Transform.translate(
          offset: Offset(left, top),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: colors.map((c) => c.withOpacity(opacity)).toList(),
                  stops: const [0.4, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [],
          ),
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoFade.value,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/logos/logo_abbeav.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final logoSize = size.width * 0.35;

    return Scaffold(
      //backgroundColor: const Color(0xFF1F2233),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  AppColor.primary,
                  AppColor.primary,
                ],
                stops: const [0.1, 1.0],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: _buildLogo(),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _bgBlobController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.1 * sin(_bgBlobController.value * 2 * pi),
                        0.1 * cos(_bgBlobController.value * 2 * pi),
                      ),
                      radius: 1.5,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withOpacity(
                            0.01 * sin(_bgBlobController.value * pi)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedLetter extends StatelessWidget {
  final String letter;
  final int delay;
  final double fontSize;

  const AnimatedLetter({
    super.key,
    required this.letter,
    required this.delay,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Transform.scale(
            scale: value,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF3DCBFF),
                    const Color(0xFF7D3CF8),
                    const Color(0xFF3DCBFF),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  final Color color;
  final double speed;
  final double radius;
  double angle;
  final double distance;

  Particle({
    required this.color,
    required this.speed,
    required this.radius,
    required this.angle,
    required this.distance,
  });
}*/
