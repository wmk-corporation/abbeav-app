import 'dart:async';
import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/main.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimController;
  late Animation<double> _bgScaleAnim;
  late AnimationController _contentController;
  late Animation<Offset> _contentSlideAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late ScrollController _scrollController;
  late Timer _autoScrollTimer;
  int _currentCenterIndex = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Color _dominantColor = AppColor.secondary;
  Color _textColor = Colors.white;

  final Map<String, dynamic> _featuredContent = {
    'image': 'assets/images/display/d_06.png',
    'gradient': [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
  };

  final List<Map<String, dynamic>> _contentRows = [
    {
      'items':
          List.generate(10, (i) => 'assets/images/content/popular_${i + 1}.png')
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateDominantColor();
    _startAutoScroll();
  }

  void _initAnimations() {
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    _bgScaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _bgAnimController,
        curve: Curves.easeInOut,
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    _scrollController = ScrollController();
    _contentController.forward();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentCenterIndex < _contentRows[0]['items'].length - 1) {
        _currentCenterIndex++;
      } else {
        _currentCenterIndex = 0;
      }

      final newPosition = _currentCenterIndex * (w(110) + w(8));
      _scrollController.animateTo(
        newPosition.toDouble(),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuint,
      );
    });
  }

  Future<void> _updateDominantColor() async {
    final imageProvider = AssetImage(_featuredContent['image']);
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);

    setState(() {
      _dominantColor =
          paletteGenerator.dominantColor?.color ?? AppColor.secondary;
      final luminance = _dominantColor.computeLuminance();
      _textColor = luminance > 0.5 ? Colors.black : Colors.white;
    });
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _scrollController.dispose();
    _scaleController.dispose();
    _autoScrollTimer.cancel();
    super.dispose();
  }

  Widget _buildContentItem(String imagePath, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCenter = index == _currentCenterIndex;
        return AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            double scale = 1.0;
            if (isCenter) {
              scale = _scaleAnimation.value;
            }

            return Transform.scale(
              scale: scale,
              child: Container(
                width: isCenter ? w(120) : w(110),
                margin: EdgeInsets.symmetric(horizontal: w(4)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w(8)),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContentRow(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w(16), vertical: h(8)),
          child: Text(
            AppLocalizations.of(context)!.popular!,
            style: TextStyle(
              fontSize: w(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: h(180),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              final centerPosition = _scrollController.position.pixels +
                  (MediaQuery.of(context).size.width / 2);
              final newCenterIndex = (centerPosition / (w(110) + w(8))).round();

              if (newCenterIndex >= 0 &&
                  newCenterIndex < items.length &&
                  newCenterIndex != _currentCenterIndex) {
                setState(() {
                  _currentCenterIndex = newCenterIndex;
                });
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: w(16)),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildContentItem(items[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  double w(double width) => width * (MediaQuery.of(context).size.width / 375);
  double h(double height) =>
      height * (MediaQuery.of(context).size.height / 812);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScaleAnim.value,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_featuredContent['image']),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SlideTransition(
              position: _contentSlideAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: h(550),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: w(24)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(flex: 5),
                            Text(
                              appLocalizations!.title!,
                              style: TextStyle(
                                fontSize: w(36),
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: _featuredContent['gradient'],
                                    stops: const [0.0, 1.0],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(
                                    Rect.fromLTWH(0, 0, w(300), h(50)),
                                  ),
                              ),
                            ),
                            SizedBox(height: h(8)),
                            Text(
                              appLocalizations.subtitle!,
                              style: TextStyle(
                                fontSize: w(16),
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: h(16)),
                            Text(
                              appLocalizations.description!,
                              style: TextStyle(
                                fontSize: w(14),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: h(24)),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _dominantColor.withOpacity(0.9),
                                    foregroundColor: _textColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(24),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    _buttonController.forward().then((_) {
                                      _buttonController.reverse();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const SignInScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            final fade = Tween<double>(
                                              begin: 0.0,
                                              end: 1.0,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOutCubic,
                                              ),
                                            );
                                            final slide = Tween<Offset>(
                                              begin: const Offset(0, 0.1),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                            );
                                            return FadeTransition(
                                              opacity: fade,
                                              child: SlideTransition(
                                                position: slide,
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    });
                                  },
                                  child: Text(
                                    appLocalizations.login!,
                                    style: TextStyle(
                                      fontSize: w(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: w(16)),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(20),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.5)),
                                  ),
                                  onPressed: () {
                                    final newLocale =
                                        languageProvider.locale.languageCode ==
                                                'fr'
                                            ? const Locale('en')
                                            : const Locale('fr');
                                    languageProvider.setLocale(newLocale);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        appLocalizations.changeLanguage!,
                                        style: TextStyle(fontSize: w(16)),
                                      ),
                                      SizedBox(width: w(8)),
                                      Icon(
                                        Icons.language,
                                        color: Colors.white,
                                        size: w(16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: h(40)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final row = _contentRows[index];
                        return _buildContentRow(row['items']);
                      },
                      childCount: _contentRows.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';
import 'package:palette_generator/palette_generator.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimController;
  late Animation<double> _bgScaleAnim;
  late AnimationController _contentController;
  late Animation<Offset> _contentSlideAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  // Contrôleurs pour l'animation du carrousel
  late ScrollController _scrollController;
  late Timer _autoScrollTimer;
  int _currentCenterIndex = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  Color _dominantColor = AppColor.secondary;
  Color _textColor = Colors.white;

  final Map<String, dynamic> _featuredContent = {
    'title': 'The Crown Legacy',
    'subtitle': 'New Season Available Now',
    'description':
        'The epic saga continues with new intrigues and power struggles',
    'image': 'assets/images/display/d_06.png',
    'gradient': [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
  };

  final List<Map<String, dynamic>> _contentRows = [
    {
      'title': 'Popular on ABBEAV',
      'items':
          List.generate(10, (i) => 'assets/images/content/popular_${i + 1}.png')
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateDominantColor();
    _startAutoScroll();
  }

  void _initAnimations() {
    // Animation background
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    _bgScaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _bgAnimController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation contenu principal
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animation bouton
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    // Animation scale pour l'item central
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Contrôleur de scroll pour détecter l'item central
    _scrollController = ScrollController();

    _contentController.forward();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentCenterIndex < _contentRows[0]['items'].length - 1) {
        _currentCenterIndex++;
      } else {
        _currentCenterIndex = 0;
      }

      final newPosition = _currentCenterIndex * (w(110) + w(8));
      _scrollController.animateTo(
        newPosition.toDouble(),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuint,
      );
    });
  }

  Future<void> _updateDominantColor() async {
    final imageProvider = AssetImage(_featuredContent['image']);
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);

    setState(() {
      _dominantColor =
          paletteGenerator.dominantColor?.color ?? AppColor.secondary;
      final luminance = _dominantColor.computeLuminance();
      _textColor = luminance > 0.5 ? Colors.black : Colors.white;
    });
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _scrollController.dispose();
    _scaleController.dispose();
    _autoScrollTimer.cancel();
    super.dispose();
  }

  Widget _buildContentItem(String imagePath, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCenter = index == _currentCenterIndex;
        return AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            // Calcul de la position relative pour l'effet parallaxe
            double scale = 1.0;
            if (isCenter) {
              scale = _scaleAnimation.value;
            }

            return Transform.scale(
              scale: scale,
              child: Container(
                width: isCenter ? w(120) : w(110),
                margin: EdgeInsets.symmetric(horizontal: w(4)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w(8)),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContentRow(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w(16), vertical: h(8)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: w(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: h(180), // Augmenté pour accommoder l'effet de scale
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              // Détection de l'item central pendant le scroll
              final centerPosition = _scrollController.position.pixels +
                  (MediaQuery.of(context).size.width / 2);
              final newCenterIndex = (centerPosition / (w(110) + w(8))).round();

              if (newCenterIndex >= 0 &&
                  newCenterIndex < items.length &&
                  newCenterIndex != _currentCenterIndex) {
                setState(() {
                  _currentCenterIndex = newCenterIndex;
                });
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: w(16)),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildContentItem(items[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  double w(double width) => width * (MediaQuery.of(context).size.width / 375);
  double h(double height) =>
      height * (MediaQuery.of(context).size.height / 812);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Featured Background
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScaleAnim.value,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_featuredContent['image']),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              );
            },
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SlideTransition(
              position: _contentSlideAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: h(550),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: w(24)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(flex: 5),
                            Text(
                              _featuredContent['title'],
                              style: TextStyle(
                                fontSize: w(36),
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: _featuredContent['gradient'],
                                    stops: const [0.0, 1.0],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(
                                    Rect.fromLTWH(0, 0, w(300), h(50)),
                                  ),
                              ),
                            ),
                            SizedBox(height: h(8)),
                            Text(
                              _featuredContent['subtitle'],
                              style: TextStyle(
                                fontSize: w(16),
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: h(16)),
                            Text(
                              _featuredContent['description'],
                              style: TextStyle(
                                fontSize: w(14),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: h(24)),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _dominantColor.withOpacity(0.9),
                                    foregroundColor: _textColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(24),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    _buttonController.forward().then((_) {
                                      _buttonController.reverse();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const SignInScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            final fade = Tween<double>(
                                              begin: 0.0,
                                              end: 1.0,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOutCubic,
                                              ),
                                            );
                                            final slide = Tween<Offset>(
                                              begin: const Offset(0, 0.1),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                            );
                                            return FadeTransition(
                                              opacity: fade,
                                              child: SlideTransition(
                                                position: slide,
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    });
                                  },
                                  child: Text(
                                    'Login to Play',
                                    style: TextStyle(
                                      fontSize: w(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: w(16)),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(20),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.5)),
                                  ),
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Text(
                                        'Change Language',
                                        style: TextStyle(fontSize: w(16)),
                                      ),
                                      SizedBox(width: w(8)),
                                      Icon(
                                        Icons.language,
                                        color: Colors.white,
                                        size: w(16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: h(40)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final row = _contentRows[index];
                        return _buildContentRow(row['title'], row['items']);
                      },
                      childCount: _contentRows.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';
import 'package:palette_generator/palette_generator.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimController;
  late Animation<double> _bgScaleAnim;
  late AnimationController _contentController;
  late Animation<Offset> _contentSlideAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  // Contrôleurs pour l'animation du carrousel
  late ScrollController _scrollController;
  late Timer _autoScrollTimer;
  int _currentCenterIndex = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  Color _dominantColor = AppColor.secondary;
  Color _textColor = Colors.white;

  final Map<String, dynamic> _featuredContent = {
    'title': 'The Crown Legacy',
    'subtitle': 'New Season Available Now',
    'description':
        'The epic saga continues with new intrigues and power struggles',
    'image': 'assets/images/display/d_06.png',
    'gradient': [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
  };

  final List<Map<String, dynamic>> _contentRows = [
    {
      'title': 'Popular on ABBEAV',
      'items':
          List.generate(10, (i) => 'assets/images/content/popular_${i + 1}.png')
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateDominantColor();
    _startAutoScroll();
  }

  void _initAnimations() {
    // Animation background
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    _bgScaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _bgAnimController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation contenu principal
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animation bouton
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    // Animation scale pour l'item central
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Contrôleur de scroll pour détecter l'item central
    _scrollController = ScrollController();

    _contentController.forward();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentCenterIndex < _contentRows[0]['items'].length - 1) {
        _currentCenterIndex++;
      } else {
        _currentCenterIndex = 0;
      }

      final newPosition = _currentCenterIndex * (w(110) + w(8));
      _scrollController.animateTo(
        newPosition.toDouble(),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuint,
      );
    });
  }

  Future<void> _updateDominantColor() async {
    final imageProvider = AssetImage(_featuredContent['image']);
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);

    setState(() {
      _dominantColor =
          paletteGenerator.dominantColor?.color ?? AppColor.secondary;
      final luminance = _dominantColor.computeLuminance();
      _textColor = luminance > 0.5 ? Colors.black : Colors.white;
    });
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _scrollController.dispose();
    _scaleController.dispose();
    _autoScrollTimer.cancel();
    super.dispose();
  }

  Widget _buildContentItem(String imagePath, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCenter = index == _currentCenterIndex;
        return AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            // Calcul de la position relative pour l'effet parallaxe
            double scale = 1.0;
            if (isCenter) {
              scale = _scaleAnimation.value;
            }

            return Transform.scale(
              scale: scale,
              child: Container(
                width: isCenter ? w(120) : w(110),
                margin: EdgeInsets.symmetric(horizontal: w(4)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w(8)),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContentRow(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w(16), vertical: h(8)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: w(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: h(180), // Augmenté pour accommoder l'effet de scale
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              // Détection de l'item central pendant le scroll
              final centerPosition = _scrollController.position.pixels +
                  (MediaQuery.of(context).size.width / 2);
              final newCenterIndex = (centerPosition / (w(110) + w(8))).round();

              if (newCenterIndex >= 0 &&
                  newCenterIndex < items.length &&
                  newCenterIndex != _currentCenterIndex) {
                setState(() {
                  _currentCenterIndex = newCenterIndex;
                });
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: w(16)),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildContentItem(items[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  double w(double width) => width * (MediaQuery.of(context).size.width / 375);
  double h(double height) =>
      height * (MediaQuery.of(context).size.height / 812);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Featured Background
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScaleAnim.value,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_featuredContent['image']),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              );
            },
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SlideTransition(
              position: _contentSlideAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: h(550),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: w(24)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(flex: 5),
                            Text(
                              _featuredContent['title'],
                              style: TextStyle(
                                fontSize: w(36),
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: _featuredContent['gradient'],
                                    stops: const [0.0, 1.0],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(
                                    Rect.fromLTWH(0, 0, w(300), h(50)),
                                  ),
                              ),
                            ),
                            SizedBox(height: h(8)),
                            Text(
                              _featuredContent['subtitle'],
                              style: TextStyle(
                                fontSize: w(16),
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: h(16)),
                            Text(
                              _featuredContent['description'],
                              style: TextStyle(
                                fontSize: w(14),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: h(24)),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _dominantColor.withOpacity(0.9),
                                    foregroundColor: _textColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(24),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    _buttonController.forward().then((_) {
                                      _buttonController.reverse();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const SignInScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            final fade = Tween<double>(
                                              begin: 0.0,
                                              end: 1.0,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOutCubic,
                                              ),
                                            );
                                            final slide = Tween<Offset>(
                                              begin: const Offset(0, 0.1),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                            );
                                            return FadeTransition(
                                              opacity: fade,
                                              child: SlideTransition(
                                                position: slide,
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    });
                                  },
                                  child: Text(
                                    'Login to Play',
                                    style: TextStyle(
                                      fontSize: w(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: w(16)),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(20),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.5)),
                                  ),
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Text(
                                        'Change Language',
                                        style: TextStyle(fontSize: w(16)),
                                      ),
                                      SizedBox(width: w(8)),
                                      Icon(
                                        Icons.language,
                                        color: Colors.white,
                                        size: w(16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: h(40)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final row = _contentRows[index];
                        return _buildContentRow(row['title'], row['items']);
                      },
                      childCount: _contentRows.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';
import 'package:palette_generator/palette_generator.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimController;
  late Animation<double> _bgScaleAnim;
  late AnimationController _contentController;
  late Animation<Offset> _contentSlideAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  Color _dominantColor = AppColor.secondary;
  Color _textColor = Colors.white;

  final Map<String, dynamic> _featuredContent = {
    'title': 'The Crown Legacy',
    'subtitle': 'New Season Available Now',
    'description':
        'The epic saga continues with new intrigues and power struggles',
    'image': 'assets/images/display/d_06.png',
    'gradient': [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
  };

  final List<Map<String, dynamic>> _contentRows = [
    {
      'title': 'Popular on ABBEAV',
      'items':
          List.generate(5, (i) => 'assets/images/content/popular_${i + 1}.png')
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateDominantColor();
  }

  void _initAnimations() {
    // Background scale animation
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    _bgScaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _bgAnimController,
        curve: Curves.easeInOut,
      ),
    );

    // Content slide animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Button scale animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    _contentController.forward();
  }

  Future<void> _updateDominantColor() async {
    final imageProvider = AssetImage(_featuredContent['image']);
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);

    setState(() {
      _dominantColor =
          paletteGenerator.dominantColor?.color ?? AppColor.secondary;
      final luminance = _dominantColor.computeLuminance();
      _textColor = luminance > 0.5 ? Colors.black : Colors.white;
    });
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Widget _buildContentRow(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w(16), vertical: h(8)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: w(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: h(160),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: w(8)),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Handle content item tap
                },
                child: Container(
                  width: w(110),
                  margin: EdgeInsets.symmetric(horizontal: w(4)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(w(8)),
                    image: DecorationImage(
                      image: AssetImage(items[index]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double w(double width) => width * (MediaQuery.of(context).size.width / 375);
  double h(double height) =>
      height * (MediaQuery.of(context).size.height / 812);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Featured Background
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScaleAnim.value,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_featuredContent['image']),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              );
            },
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SlideTransition(
              position: _contentSlideAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: h(550),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: w(24)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Featured Content Logo/Title
                            Spacer(flex: 5),
                            Text(
                              _featuredContent['title'],
                              style: TextStyle(
                                fontSize: w(36),
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: _featuredContent['gradient'],
                                    stops: const [0.0, 1.0],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(
                                    Rect.fromLTWH(0, 0, w(300), h(50)),
                                  ),
                              ),
                            ),
                            SizedBox(height: h(8)),

                            // Featured Content Subtitle
                            Text(
                              _featuredContent['subtitle'],
                              style: TextStyle(
                                fontSize: w(16),
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: h(16)),

                            // Featured Content Description
                            Text(
                              _featuredContent['description'],
                              style: TextStyle(
                                fontSize: w(14),
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: h(24)),

                            // Action Buttons Row
                            Row(
                              children: [
                                // Play Button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _dominantColor.withOpacity(0.9),
                                    foregroundColor: _textColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(24),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    _buttonController.forward().then((_) {
                                      _buttonController.reverse();
                                      // Handle play action
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const SignInScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            final fade = Tween<double>(
                                              begin: 0.0,
                                              end: 1.0,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOutCubic,
                                              ),
                                            );
                                            final slide = Tween<Offset>(
                                              begin: const Offset(0, 0.1),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                            );
                                            return FadeTransition(
                                              opacity: fade,
                                              child: SlideTransition(
                                                position: slide,
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    });
                                  },
                                  child: Text(
                                    'Login to Play',
                                    style: TextStyle(
                                      fontSize: w(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: w(16)),

                                // More Info Button
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w(20),
                                      vertical: h(12),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(w(8)),
                                    ),
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.5)),
                                  ),
                                  onPressed: () {
                                    // Handle more info action
                                  },
                                  child: Text(
                                    'Sign Up for More Info',
                                    style: TextStyle(fontSize: w(16)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: h(40)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Rows
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final row = _contentRows[index];
                        return _buildContentRow(row['title'], row['items']);
                      },
                      childCount: _contentRows.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

/*import 'dart:async';
import 'dart:ui';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';
import 'package:palette_generator/palette_generator.dart'; // Nouveau package pour extraire les couleurs

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen>
    with TickerProviderStateMixin {
  final CarouselController _carouselController = CarouselController();
  late AnimationController _bgAnimController;
  late Animation<double> _bgFadeAnim;
  late Animation<double> _bgScaleAnim;
  late AnimationController _contentController;
  late Animation<double> _contentFadeAnim;
  late Animation<Offset> _contentSlideAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _gradientController;
  late Animation<double> _gradientAnim;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorScaleAnim;

  int _currentIndex = 0;
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _loadingApple = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Nouvelle variable pour stocker la couleur dominante
  Color _dominantColor = AppColor.secondary; // Couleur par défaut
  Color _textColor = Colors.white; // Couleur de texte par défaut

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Unlimited 4K Streaming',
      'subtitle': 'Enjoy crystal clear movies and shows in stunning 4K HDR',
      'image': 'assets/images/display/d_05.png',
      'gradient': [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
    },
    {
      'title': 'Personalized For You',
      'subtitle': 'Smart recommendations based on your taste',
      'image': 'assets/images/display/display_01.jpg',
      'gradient': [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
    },
    {
      'title': 'Download Anywhere',
      'subtitle': 'Watch offline during flights or commutes',
      'image': 'assets/images/display/display_03.jpg',
      'gradient': [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialiser les animations
    _initAnimations();

    // Charger la couleur dominante pour la première image
    _updateDominantColor(0);
  }

  void _initAnimations() {
    // Background animation
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bgFadeAnim = CurvedAnimation(
      parent: _bgAnimController,
      curve: Curves.easeInOutCubic,
    );
    _bgScaleAnim = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgAnimController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Content animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _contentFadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOutCubic,
    );
    _contentSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutBack,
      ),
    );

    // Button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    // Gradient animation
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Indicator animation
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _indicatorScaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOut,
      ),
    );

    // Contrôleur pour l'animation de fondu
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOutQuart,
      ),
    );

    // Contrôleur pour l'animation de glissement
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      ),
    );

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
    _bgAnimController.forward();
    _contentController.forward();
    _indicatorController.repeat(reverse: true);
  }

  // Nouvelle méthode pour mettre à jour la couleur dominante
  Future<void> _updateDominantColor(int index) async {
    final imagePath = _features[index]['image'];
    final imageProvider = AssetImage(imagePath);
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);

    setState(() {
      _dominantColor =
          paletteGenerator.dominantColor?.color ?? AppColor.secondary;

      // Calculer la luminosité pour déterminer la couleur du texte
      final luminance = _dominantColor.computeLuminance();
      _textColor = luminance > 0.5 ? Colors.black : Colors.white;
    });
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _gradientController.dispose();
    _indicatorController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCarouselSlider() {
    return CarouselSlider.builder(
      itemCount: _features.length,
      itemBuilder: (context, index, realIndex) {
        return AnimatedBuilder(
          animation: Listenable.merge([_fadeController, _slideController]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image avec effet de parallaxe
                    Hero(
                      tag: 'image_$index',
                      child: Image.asset(
                        _features[index]['image'],
                        fit: BoxFit.cover,
                        alignment: Alignment(
                          0,
                          -0.2 + 0.4 * (1 - _fadeAnimation.value),
                        ),
                      ),
                    ),

                    // Overlay gradient animé
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black
                                .withOpacity(0.9 * _fadeAnimation.value),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),

                    // Effet de flou animé
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 2 * (1 - _fadeAnimation.value),
                        sigmaY: 2 * (1 - _fadeAnimation.value),
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      options: CarouselOptions(
        height: MediaQuery.sizeOf(context).height,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 1500),
        autoPlayCurve: Curves.easeInOutQuint,
        enlargeCenterPage: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
            // Mettre à jour la couleur dominante pour la nouvelle image
            _updateDominantColor(index);
            // Réinitialiser et relancer les animations
            _fadeController.reset();
            _slideController.reset();
            _fadeController.forward();
            _slideController.forward();
          });
        },
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _currentIndex == index ? 24.0 : 8.0,
        height: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: _currentIndex == index
              ? AppColor.primary
              : Colors.white.withOpacity(0.3),
        ),
        child: _currentIndex == index
            ? ScaleTransition(
                scale: _indicatorScaleAnim,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: _features[index]['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Carousel
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Opacity(
                opacity: _bgFadeAnim.value,
                child: Transform.scale(
                  scale: _bgScaleAnim.value,
                  child: _buildAnimatedCarouselSlider(),
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _contentFadeAnim,
              child: SlideTransition(
                position: _contentSlideAnim,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isSmall ? 20 : 40,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _features.asMap().entries.map((entry) {
                          return _buildIndicator(entry.key);
                        }).toList(),
                      ),
                      const SizedBox(height: 40),

                      // Feature Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _features[_currentIndex]['title'],
                          key: ValueKey(_currentIndex),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: _features[_currentIndex]['gradient'],
                                stops: const [0.0, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(
                                const Rect.fromLTWH(0, 0, 400, 70),
                              ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Feature Subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _features[_currentIndex]['subtitle'],
                          key: ValueKey('subtitle_$_currentIndex'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Get Started Button avec couleur dynamique
                      AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScaleAnim.value,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _dominantColor.withOpacity(0.9),
                                foregroundColor: _textColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: _dominantColor.withOpacity(0.4),
                              ),
                              onPressed: () {
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  //_buttonController.reverse();
                                });
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 800),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const SignInScreen(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      final fade = Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOutCubic,
                                        ),
                                      );
                                      final slide = Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutBack,
                                        ),
                                      );
                                      return FadeTransition(
                                        opacity: fade,
                                        child: SlideTransition(
                                          position: slide,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: isSmall ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                      color: _textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String asset,
    required VoidCallback onTap,
    required Color bgColor,
    Color? iconColor,
    double size = 54,
    bool isApple = false,
  }) {
    final isLoading = isApple ? _loadingApple : _loadingGoogle;
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: () async {
        setState(() {
          if (isApple) {
            _loadingApple = true;
          } else {
            _loadingGoogle = true;
          }
        });
        await Future.delayed(const Duration(milliseconds: 1500));
        setState(() {
          if (isApple) {
            _loadingApple = false;
          } else {
            _loadingGoogle = false;
          }
        });
      },
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScaleAnim.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOutBack,
                  switchOutCurve: Curves.easeInOutBack,
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isApple ? Colors.white : Colors.black87,
                          ),
                        )
                      : Image.asset(
                          asset,
                          width: 24,
                          height: 24,
                          color: iconColor,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}*/

/*import 'dart:async';
import 'dart:ui';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen>
    with TickerProviderStateMixin {
  final CarouselController _carouselController = CarouselController();
  late AnimationController _bgAnimController;
  late Animation<double> _bgFadeAnim;
  late Animation<double> _bgScaleAnim;
  late AnimationController _contentController;
  late Animation<double> _contentFadeAnim;
  late Animation<Offset> _contentSlideAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _gradientController;
  late Animation<double> _gradientAnim;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorScaleAnim;

  int _currentIndex = 0;
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _loadingApple = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Unlimited 4K Streaming',
      'subtitle': 'Enjoy crystal clear movies and shows in stunning 4K HDR',
      'image': 'assets/images/display/display_01.jpg',
      'gradient': [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
    },
    {
      'title': 'Personalized For You',
      'subtitle': 'Smart recommendations based on your taste',
      'image': 'assets/images/display/display_02.jpg',
      'gradient': [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
    },
    {
      'title': 'Download Anywhere',
      'subtitle': 'Watch offline during flights or commutes',
      'image': 'assets/images/display/display_03.jpg',
      'gradient': [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    },
  ];

  @override
  void initState() {
    super.initState();

    // Background animation
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bgFadeAnim = CurvedAnimation(
      parent: _bgAnimController,
      curve: Curves.easeInOutCubic,
    );
    _bgScaleAnim = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgAnimController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Content animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _contentFadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOutCubic,
    );
    _contentSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutBack,
      ),
    );

    // Button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    // Gradient animation
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Indicator animation
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _indicatorScaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOut,
      ),
    );

    // Contrôleur pour l'animation de fondu
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOutQuart,
      ),
    );

    // Contrôleur pour l'animation de glissement
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      ),
    );

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();

    // Start animations
    _bgAnimController.forward();
    _contentController.forward();
    _indicatorController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _gradientController.dispose();
    _indicatorController.dispose();

    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCarouselSlider() {
    return CarouselSlider.builder(
      itemCount: _features.length,
      itemBuilder: (context, index, realIndex) {
        return AnimatedBuilder(
          animation: Listenable.merge([_fadeController, _slideController]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image avec effet de parallaxe
                    Hero(
                      tag: 'image_$index',
                      child: Image.asset(
                        _features[index]['image'],
                        fit: BoxFit.cover,
                        alignment: Alignment(
                          0,
                          -0.2 + 0.4 * (1 - _fadeAnimation.value),
                        ),
                      ),
                    ),

                    // Overlay gradient animé
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black
                                .withOpacity(0.9 * _fadeAnimation.value),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),

                    // Effet de flou animé
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 2 * (1 - _fadeAnimation.value),
                        sigmaY: 2 * (1 - _fadeAnimation.value),
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      options: CarouselOptions(
        height: MediaQuery.sizeOf(context).height,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 1500),
        autoPlayCurve: Curves.easeInOutQuint,
        enlargeCenterPage: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
            // Réinitialiser et relancer les animations à chaque changement de slide
            _fadeController.reset();
            _slideController.reset();
            _fadeController.forward();
            _slideController.forward();
          });
        },
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _currentIndex == index ? 24.0 : 8.0,
        height: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: _currentIndex == index
              ? AppColor.primary
              : Colors.white.withOpacity(0.3),
        ),
        child: _currentIndex == index
            ? ScaleTransition(
                scale: _indicatorScaleAnim,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: _features[index]['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Carousel
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Opacity(
                opacity: _bgFadeAnim.value,
                child: Transform.scale(
                  scale: _bgScaleAnim.value,
                  child: _buildAnimatedCarouselSlider(),
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _contentFadeAnim,
              child: SlideTransition(
                position: _contentSlideAnim,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isSmall ? 20 : 40,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _features.asMap().entries.map((entry) {
                          return _buildIndicator(entry.key);
                        }).toList(),
                      ),
                      const SizedBox(height: 40),

                      // Feature Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _features[_currentIndex]['title'],
                          key: ValueKey(_currentIndex),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: _features[_currentIndex]['gradient'],
                                stops: const [0.0, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(
                                const Rect.fromLTWH(0, 0, 400, 70),
                              ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Feature Subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _features[_currentIndex]['subtitle'],
                          key: ValueKey('subtitle_$_currentIndex'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Get Started Button
                      AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScaleAnim.value,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.secondary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: AppColor.primary.withOpacity(0.4),
                              ),
                              onPressed: () {
                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  //_buttonController.reverse();
                                });
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 800),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const SignInScreen(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      final fade = Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOutCubic,
                                        ),
                                      );
                                      final slide = Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutBack,
                                        ),
                                      );
                                      return FadeTransition(
                                        opacity: fade,
                                        child: SlideTransition(
                                          position: slide,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: isSmall ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String asset,
    required VoidCallback onTap,
    required Color bgColor,
    Color? iconColor,
    double size = 54,
    bool isApple = false,
  }) {
    final isLoading = isApple ? _loadingApple : _loadingGoogle;
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: () async {
        setState(() {
          if (isApple) {
            _loadingApple = true;
          } else {
            _loadingGoogle = true;
          }
        });
        await Future.delayed(const Duration(milliseconds: 1500));
        setState(() {
          if (isApple) {
            _loadingApple = false;
          } else {
            _loadingGoogle = false;
          }
        });
      },
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScaleAnim.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOutBack,
                  switchOutCurve: Curves.easeInOutBack,
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isApple ? Colors.white : Colors.black87,
                          ),
                        )
                      : Image.asset(
                          asset,
                          width: 24,
                          height: 24,
                          color: iconColor,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}*/
