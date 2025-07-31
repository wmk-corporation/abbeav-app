import 'dart:async';
import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/controller/movie_controller.dart';
import 'package:abbeav/models/movies_model.dart';
import 'package:abbeav/view/home/providers/user_provider.dart';
import 'package:abbeav/view/search/screens/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/database/movie_data.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/actor_details/screens/actor_details_screen.dart';
import 'package:abbeav/view/home/providers/landing_provider.dart';
import 'package:abbeav/view/home/widgets/movie_card_widget.dart';
import 'package:abbeav/view/home/widgets/play_button.dart';
import 'package:abbeav/view/home/widgets/star_rating_widget.dart';
import 'package:abbeav/view/home/widgets/title_card_widget.dart';
import 'package:abbeav/view/movie_details_screen/screens/movie_details_screen.dart';
import 'package:abbeav/view/search/widgets/actors_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _movieScrollController = ScrollController();
  bool _autoScrollStarted = false;
  int _centeredIndex = 0;
  Timer? _autoScrollTimer;
  late AnimationController _bannerAnimController;
  late Animation<double> _bannerFadeAnim;

  final PageController _pageController = PageController(viewportFraction: 0.62);
  Timer? _autoScrollPageTimer;

  late AnimationController _arrowAnimCtrl;
  late Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _bannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bannerFadeAnim = CurvedAnimation(
      parent: _bannerAnimController,
      curve: Curves.easeInOut,
    );

    // Charger les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bannerAnimController.forward();
      Provider.of<LandingProvider>(context, listen: false).initializeData();
    });

    _movieScrollController.addListener(_onMovieListScroll);

    _arrowAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _arrowAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _arrowAnimCtrl, curve: Curves.easeInOut),
    );
    _fetchUserLanguage();
  }

  void _fetchUserLanguage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<UserProvider>(context, listen: false)
          .fetchUserLanguage(user.uid);
    }
  }

  @override
  void dispose() {
    _movieScrollController.dispose();
    _autoScrollTimer?.cancel();
    _bannerAnimController.dispose();

    _pageController.dispose();
    _autoScrollPageTimer?.cancel();

    _arrowAnimCtrl.dispose();
    super.dispose();
  }

  void _onMovieListScroll() {
    if (!_autoScrollStarted &&
        _movieScrollController.position.extentAfter <
            _movieScrollController.position.viewportDimension * 2) {
      // L'utilisateur a scrollé jusqu'à la liste des films
      _autoScrollStarted = true;
      Future.delayed(const Duration(seconds: 2), _startAutoScroll);
    }
  }

  void _startAutoScroll() {
    if (!_autoScrollStarted) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_centeredIndex < 3) {
        _centeredIndex++;
      } else {
        _centeredIndex = 0;
      }
      _movieScrollController.animateTo(
        _centeredIndex * 220.0, // largeur approx d'une MovieCard
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
      setState(() {});
    });
  }

  Widget _buildReservationBanner(String title, String subtitle) {
    return FadeTransition(
      opacity: _bannerFadeAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        //"Buy your tickets",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        //"Immerse yourself in the magical world of cinema! Book your tickets online at ABBEAV and enjoy an unforgettable experience. From blockbusters to auteur films, there's something for everyone. Find your next adventure on the big screen.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/tickets.jpg",
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        FToast fToast = FToast();
                        fToast.init(context);
                        fToast.showToast(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary.withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.info_outline,
                                    color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  "This feature will be available in a future update.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: const Duration(seconds: 3),
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _arrowAnimCtrl,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _arrowAnim.value),
                          child: child,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 0, top: 0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.secondary.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_downward_rounded,
                            color: Color(0xFF3DCBFF),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCarouselSliderFinal(LandingProvider p) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance // <-- Modification ici
          .collection('movies')
          .where('isFeatured', isEqualTo: true)
          .orderBy('publishDate', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorPlaceholder();
        }

        if (!snapshot.hasData) {
          return _buildLoadingPlaceholder();
        }

        final movies = snapshot.data!.docs.map((doc) {
          return MovieModel.fromFirestore(doc);
        }).toList();

        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: movies.length,
              itemBuilder: (context, index, realIndex) {
                final movie = movies[index];
                return _buildMovieSlide(movie);
              },
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * .50,
                autoPlay: true,
                viewportFraction: 1,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (index, reason) {
                  p.onSliderIndexChange(index);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildMovieSlide(MovieModel movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              movie: movie,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: movie.thumbnailUrl,
            imageBuilder: (context, imageProvider) => AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: MediaQuery.of(context).size.height * .50,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: MediaQuery.of(context).size.height * .50,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 50),
          const SizedBox(height: 16),
          Text(
            'Failed to load featured movies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<LandingProvider>(context, listen: false);
              //._loadFeaturedMovies();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _goToSeeAllLatests() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
              parent: animation, curve: Curves.easeInOutCubicEmphasized);
          final slide =
              Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(fade);
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  void _goToSeeAllActors() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
              parent: animation, curve: Curves.easeInOutCubicEmphasized);
          final slide =
              Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(fade);
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  Widget _buildMovieList(
      String title, Stream<List<MovieModel>> stream, VoidCallback onSeeAll) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleCardWidget(
          title: title,
          onSeeAll: onSeeAll,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: StreamBuilder<List<MovieModel>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final movies = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieCard(
                    name: movie.title,
                    image: movie.thumbnailUrl,
                    duration: movie.formattedDuration,
                    rating: movie.rating.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            movie: movie, // Passez l'objet MovieModel complet
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieSection(String title, VoidCallback onSeeAll) {
    return Consumer<MovieController>(
      builder: (context, movieController, _) {
        return _buildMovieList(
          title,
          movieController.getNewReleases(),
          onSeeAll,
        );
      },
    );
  }

  Widget _buildMovieSectionTrending(String title, VoidCallback onSeeAll) {
    return Consumer<MovieController>(
      builder: (context, movieController, _) {
        return _buildMovieList(
          title,
          movieController.getTrendingMovies(),
          onSeeAll,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final userLanguage = Provider.of<UserProvider>(context).languagePreference;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer<LandingProvider>(builder: (context, p, _) {
                    return Stack(
                      children: [
                        _buildAnimatedCarouselSliderFinal(p),
                        Positioned(
                          left: 0,
                          bottom:
                              10, //MediaQuery.of(context).size.height * .10,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * .90,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            // Check if featuredMovies is empty
                                            if (p.featuredMovies.isEmpty ||
                                                p.activeIndex >=
                                                    p.featuredMovies.length) {
                                              return Container(); // or some placeholder widget
                                            }
                                            final movie =
                                                p.featuredMovies[p.activeIndex];
                                            return AnimatedOpacity(
                                              opacity: 1.0,
                                              duration: const Duration(
                                                  milliseconds: 700),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    child: Text(
                                                      movie.title,
                                                      key:
                                                          ValueKey(movie.title),
                                                      style: const TextStyle(
                                                        fontSize: 26,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        shadows: [
                                                          Shadow(
                                                              blurRadius: 8,
                                                              color:
                                                                  Colors.black)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    child: Row(
                                                      key: ValueKey(movie.genres
                                                          .join(',')),
                                                      children: [
                                                        ...movie.genres.map(
                                                          (g) => Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 8),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.18),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Text(
                                                              g,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    child: Row(
                                                      key: ValueKey(
                                                          '${movie.rating}-${movie.seasonNumber}-${movie.releaseDate}'),
                                                      children: [
                                                        StarRatingWidget(
                                                            rating: movie.rating
                                                                .toString()),
                                                        const SizedBox(
                                                            width: 12),
                                                        if (movie
                                                                .seasonNumber !=
                                                            null)
                                                          Text(
                                                            "Saison ${movie.seasonNumber}",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Text(
                                                          "Sortie : ${movie.releaseDate.year}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize: 13),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 700),
                                                    child: Text(
                                                      movie
                                                          .getDescriptionForLanguage(
                                                              userLanguage),
                                                      /*movie.descriptions?[
                                                              'fr'] ??
                                                          movie.descriptions?[
                                                              'en'] ??
                                                          '',*/
                                                      key: ValueKey(
                                                          movie.descriptions),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        AppSpacing.h10,
                                        Consumer<LandingProvider>(
                                            builder: (context, p, _) {
                                          return buildIndicator(p.activeIndex);
                                        }),
                                      ],
                                    ),
                                  ),
                                  // Modifiez le PlayButton dans le Stack principal
                                  PlayButton(
                                    onTap: () {
                                      final landingProvider =
                                          Provider.of<LandingProvider>(context,
                                              listen: false);
                                      if (landingProvider
                                              .featuredMovies.isNotEmpty &&
                                          landingProvider.activeIndex <
                                              landingProvider
                                                  .featuredMovies.length) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MovieDetailsScreen(
                                              movie: landingProvider
                                                      .featuredMovies[
                                                  landingProvider.activeIndex],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        _buildMovieSection(
                          appLocalizations!.latests!,
                          _goToSeeAllLatests,
                        ),

                        PopularMovieBanner(),

                        TitleCardWidget(
                          title: appLocalizations
                              .popularsActors!, // 'Popular Actors'
                          onSeeAll: _goToSeeAllActors,
                        ),

                        AppSpacing.h20,

// Nouveau widget pour afficher les acteurs
                        Consumer<MovieController>(
                          builder: (context, movieController, _) {
                            return StreamBuilder<List<MovieModel>>(
                              stream:
                                  movieController.getPopularMovies(limit: 5),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Error loading actors'));
                                }

                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                // Récupérer tous les acteurs de tous les films populaires
                                final allActors = <CastModel>[];
                                for (final movie in snapshot.data!) {
                                  if (movie.cast != null) {
                                    allActors.addAll(movie.cast!);
                                  }
                                }

                                // Éviter les doublons
                                final uniqueActors = <String, CastModel>{};
                                for (final actor in allActors) {
                                  uniqueActors.putIfAbsent(
                                      actor.id, () => actor);
                                }

                                final popularActors =
                                    uniqueActors.values.toList();

                                return SizedBox(
                                  height: 140,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: popularActors.length,
                                    itemBuilder: (_, index) {
                                      final actor = popularActors[index];
                                      return ActorsCard(
                                        onTap: () {
                                          /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActorDetailsScreen(actor: actor),
                    ),
                  );*/
                                        },
                                        image: actor.photoUrl ?? '',
                                        name: actor.name,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        /*TitleCardWidget(
                          title: appLocalizations
                              .popularsActors!, //'Popular Actors',
                          onSeeAll: _goToSeeAllActors,
                        ),

                        AppSpacing.h20,
                        
                        SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: .cast!.length,
                                  itemBuilder: (_, i) {
                                    final actor = widget.movie.cast![i];
                                    return ActorsCard(
                                      onTap: () {},
                                      /*onTap: () => _closeVideoAndNavigate(
                                        ActorDetailsSceen(actor: actor),
                                      ),*/
                                      image: actor.photoUrl ?? '',
                                      name: actor.name,
                                    );
                                  },
                                ),
                              ),*/
                        AppSpacing.h10,
                        _buildReservationBanner(
                          appLocalizations.buyYourTickets!,
                          appLocalizations.bodyMessage!,
                        ),
                        AppSpacing.h10,
                        _buildMovieSectionTrending(
                          appLocalizations.trending!,
                          _goToSeeAllLatests,
                        ),

                        AppSpacing.h40,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              padding:
                  const EdgeInsets.only(top: 0, left: 18, right: 18, bottom: 0),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicator(int activeIndex) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: 3,
        effect: ExpandingDotsEffect(
          dotColor: Colors.grey.withOpacity(0.3),
          activeDotColor: AppColor.primary,
          dotHeight: 10,
          dotWidth: 10,
        ),
      );
}

class PopularMovieBanner extends StatelessWidget {
  const PopularMovieBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final movieController = Provider.of<MovieController>(context);

    return StreamBuilder<List<MovieModel>>(
      stream: movieController.getPopularMovies(limit: 1),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorContainer();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildLoadingContainer();
        }

        final movie = snapshot.data!.first;
        return _buildMovieContainer(movie, context);
      },
    );
  }

  Widget _buildMovieContainer(MovieModel movie, BuildContext context) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: movie.thumbnailUrl,
                width: 100,
                height: 130,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            AppSpacing.w15,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (movie.isSeries)
                    Text(
                      '${movie.seasonNumber} Saisons',
                      style: const TextStyle(color: Colors.white),
                    ),
                  AppSpacing.h10,
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.h5,
                  Wrap(
                    spacing: 8,
                    children: movie.genres
                        .take(3)
                        .map((genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  AppSpacing.h10,
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .58,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PlayButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsScreen(
                                  movie: movie,
                                ),
                              ),
                            );
                          },
                        ),
                        AppSpacing.w15,
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/images/icon_download_selected.svg",
                                color: Colors.white.withOpacity(.50),
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        StarRatingWidget(rating: movie.rating.toString()),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
        ),
      ),
      child: const Center(
        child: Text(
          'Erreur de chargement',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
