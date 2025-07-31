import 'dart:ui';
import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/view/history/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/view/home/screens/home_screen.dart';
import 'package:abbeav/view/profile/screens/profile_screen.dart';
import 'package:abbeav/view/search/screens/search_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../tickets/screens/tickets_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _oldIndex;
  late int _selectedIndex;

  final List<Widget> pages = [
    const HomeScreen(),
    const SearchScreen(),
    HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _oldIndex = 0;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged(int newIndex) async {
    if (newIndex == _selectedIndex) return;
    setState(() {
      _oldIndex = _selectedIndex;
      _selectedIndex = newIndex;
    });
    _controller.reset();
    await _controller.forward();
  }

  Widget _buildAnimatedPage() {
    // Animation de transition slide + fade entre les pages
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        final inFromRight = _selectedIndex > _oldIndex;
        final offsetTween = Tween<Offset>(
          begin: Offset(inFromRight ? 1.0 : -1.0, 0),
          end: Offset.zero,
        );
        return SlideTransition(
          position: offsetTween.animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(_selectedIndex),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOutCubic,
          ),
          child: pages[_selectedIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: _buildAnimatedPage(),
      bottomNavigationBar: _HomeNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

class _HomeNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _HomeNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final items = [
      {
        'iconSelected': 'assets/images/icon_home_selected.svg',
        'icon': 'assets/images/icon_home.svg',
        'label': appLocalizations!.home!, //'Home',
      },
      {
        'iconSelected': 'assets/images/icon_search.svg',
        'icon': 'assets/images/icon_search.svg',
        'label': appLocalizations!.search!, //'Search',
      },
      {
        'iconSelected': 'assets/images/icon_my_list_selected.svg',
        'icon': 'assets/images/icon_my_list.svg',
        'label': appLocalizations!.search!, //'My List',
      },
      {
        'iconSelected': 'assets/images/icon_profile_selected.svg',
        'icon': 'assets/images/icon_profile.svg',
        'label': appLocalizations!.profile!, //'Profile',
      },
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 69,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              final isSelected = selectedIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isSelected
                      ? Colors.white.withOpacity(0.04)
                      : Colors.transparent,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 22 : 12, vertical: 8),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF3DCBFF),
                                      Color(0xFF7D3CF8)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds)
                                : const LinearGradient(
                                    colors: [
                                      Colors.white54,
                                      Colors.white38,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: SvgPicture.asset(
                            isSelected
                                ? items[i]['iconSelected']!
                                : items[i]['icon']!,
                            width: isSelected ? 32 : 26,
                            height: isSelected ? 32 : 26,
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: isSelected
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    items[i]['label']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/*import 'dart:ui';
import 'package:abbeav/tickets/screens/tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/home/providers/landing_provider.dart';
import 'package:abbeav/view/home/screens/home_screen.dart';
import 'package:abbeav/view/profile/screens/profile_screen.dart';
import 'package:abbeav/view/search/screens/search_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _HomeNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _HomeNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'iconSelected': 'assets/images/icon_home_selected.svg',
        'icon': 'assets/images/icon_home.svg',
        'label': 'Home',
      },
      {
        'iconSelected': 'assets/images/icon_search.svg',
        'icon': 'assets/images/icon_search.svg',
        'label': 'Search',
      },
      {
        'iconSelected': 'assets/images/icon_download_selected.svg',
        'icon': 'assets/images/icon_download.svg',
        'label': 'Tickets',
      },
      {
        'iconSelected': 'assets/images/icon_profile_selected.svg',
        'icon': 'assets/images/icon_profile.svg',
        'label': 'Profile',
      },
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 69,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              final isSelected = selectedIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 22 : 12, vertical: 8),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF3DCBFF),
                                      Color(0xFF7D3CF8)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds)
                                : const LinearGradient(
                                    colors: [
                                      Colors.white54,
                                      Colors.white38,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: SvgPicture.asset(
                            isSelected
                                ? items[i]['iconSelected']!
                                : items[i]['icon']!,
                            width: isSelected ? 32 : 26,
                            height: isSelected ? 32 : 26,
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: isSelected
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    items[i]['label']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  final List<Widget> pages = [
    const HomeScreen(),
    const SearchScreen(),
    const TicketsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedPage(int index, int selectedIndex) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        final inFromRight = selectedIndex > index;
        final offsetTween = Tween<Offset>(
          begin: Offset(inFromRight ? 1.0 : -1.0, 0),
          end: Offset.zero,
        );
        return SlideTransition(
          position: offsetTween.animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: pages[selectedIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LandingProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: _buildAnimatedPage(provider.selectedIndex, provider.selectedIndex),
      bottomNavigationBar: _HomeNavBar(
        selectedIndex: provider.selectedIndex,
        onTap: (i) {
          provider.onNavigationChange(i);
        },
      ),
    );
  }
}*/

/*import 'dart:ui';
import 'package:abbeav/tickets/screens/tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_icons.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/history/screens/history_screen.dart';
import 'package:abbeav/view/home/providers/landing_provider.dart';
import 'package:abbeav/view/home/screens/home_screen.dart';
import 'package:abbeav/view/home/widgets/bottom_bara_button.dart';
import 'package:abbeav/view/profile/screens/profile_screen.dart';
import 'package:abbeav/view/search/screens/search_screen.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _HomeNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _HomeNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': AppIcon.home, 'label': 'Home'},
      {'icon': AppIcon.search, 'label': 'Search'},
      {'icon': AppIcon.history, 'label': 'Tickets'},
      {'icon': AppIcon.user, 'label': 'Profile'},
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              final isSelected = selectedIndex == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                    /*gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,*/
                    //borderRadius: BorderRadius.circular(18),
                    /*boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3DCBFF).withOpacity(0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],*/
                    ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 22 : 12, vertical: 8),
                    child: Row(
                      children: [
                        if (items[i]['icon'] is IconData)
                          Icon(
                            items[i]['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            size: isSelected ? 32 : 26,
                          )
                        else if (items[i]['icon'] is String)
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            blendMode:
                                isSelected ? BlendMode.srcIn : BlendMode.dstIn,
                            child: Image.asset(
                              items[i]['icon'] as String,
                              width: isSelected ? 32 : 26,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        /*Image.asset(
                            items[i]['icon'] as String,
                            width: isSelected ? 32 : 26,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                          ),*/
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: isSelected
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    items[i]['label']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  final List<Widget> pages = [
    const HomeScreen(),
    const SearchScreen(),
    const TicketsScreen(), // Nouvelle page Tickets
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedPage(int index, int selectedIndex) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        final inFromRight = selectedIndex > index;
        final offsetTween = Tween<Offset>(
          begin: Offset(inFromRight ? 1.0 : -1.0, 0),
          end: Offset.zero,
        );
        return SlideTransition(
          position: offsetTween.animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: pages[selectedIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LandingProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: _buildAnimatedPage(provider.selectedIndex, provider.selectedIndex),
      bottomNavigationBar: _HomeNavBar(
        selectedIndex: provider.selectedIndex,
        onTap: (i) {
          provider.onNavigationChange(i);
        },
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_icons.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/history/screens/history_screen.dart';
import 'package:abbeav/view/home/providers/landing_provider.dart';
import 'package:abbeav/view/home/screens/home_screen.dart';
import 'package:abbeav/view/home/widgets/bottom_bara_button.dart';
import 'package:abbeav/view/profile/screens/profile_screen.dart';
import 'package:abbeav/view/search/screens/search_screen.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<Widget> pages = [
    const HomeScreen(),
    const SearchScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LandingProvider>(context);
    return Scaffold(
      body: pages[provider.selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        height: 90,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColor.primary,
        ),
        child: Consumer<LandingProvider>(builder: (context, p, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomBarButton(
                isSelected: p.selectedIndex == 0,
                onTap: () => p.onNavigationChange(0),
                icon: AppIcon.home,
                title: "Home",
              ),
              BottomBarButton(
                isSelected: p.selectedIndex == 1,
                onTap: () => p.onNavigationChange(1),
                icon: AppIcon.search,
                title: "Search",
              ),
              BottomBarButton(
                isSelected: p.selectedIndex == 2,
                onTap: () => p.onNavigationChange(2),
                icon: AppIcon.history,
                title: "History",
              ),
              BottomBarButton(
                isSelected: p.selectedIndex == 3,
                onTap: () => p.onNavigationChange(3),
                icon: AppIcon.user,
                title: "Profile",
              ),
            ],
          );
        }),
      ),
    );
  }
}*/
