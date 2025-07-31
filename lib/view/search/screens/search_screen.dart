import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/controller/movie_controller.dart';
import 'package:abbeav/models/movies_model.dart';
import 'package:abbeav/view/home/widgets/title_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/actor_details/screens/actor_details_screen.dart';
import 'package:abbeav/view/movie_details_screen/screens/movie_details_screen.dart';
import 'package:abbeav/view/search/widgets/actors_card.dart';
import 'package:abbeav/view/search/widgets/search_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedGenre = 'All';
  String _selectedType = 'All';
  bool _showFilterPopup = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  List<String> _categories = [];
  List<String> _genres = [];
  List<String> _types = ['All', 'Movie', 'Series'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeFilters(AppLocalizations appLocalizations) {
    _categories = [
      appLocalizations.all!,
      appLocalizations.movies!,
      appLocalizations.series!,
      appLocalizations.documentaries!,
    ];

    _genres = [
      appLocalizations.all!,
      appLocalizations.action!,
      appLocalizations.scienceFiction!,
      appLocalizations.thriller!,
      //appLocalizations.comedy!,
      //appLocalizations.drama!,
    ];

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = appLocalizations.all!;
    }
    if (!_genres.contains(_selectedGenre)) {
      _selectedGenre = appLocalizations.all!;
    }
  }

  void _toggleFilterPopup() {
    setState(() {
      _showFilterPopup = !_showFilterPopup;
      if (_showFilterPopup) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildFilterPopup(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    _initializeFilters(appLocalizations);

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.12,
      right: MediaQuery.of(context).size.width * 0.05,
      left: MediaQuery.of(context).size.width * 0.05,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    appLocalizations.category!,
                    _categories,
                    _selectedCategory,
                    (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  _buildFilterSection(
                    appLocalizations.genre!,
                    _genres,
                    _selectedGenre,
                    (value) {
                      setState(() => _selectedGenre = value);
                    },
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  _buildFilterSection(
                    'Type',
                    _types,
                    _selectedType,
                    (value) {
                      setState(() => _selectedType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = appLocalizations.all!;
                            _selectedGenre = appLocalizations.all!;
                            _selectedType = 'All';
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: Text(appLocalizations.reset!),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _toggleFilterPopup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          appLocalizations.apply!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primary : Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: AppColor.secondary, width: 1.5)
                      : null,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Stream<List<MovieModel>> _getFilteredMovies(MovieController controller) {
    String searchTerm = _searchController.text.toLowerCase();

    return controller.getAllMovies().map((movies) {
      return movies.where((movie) {
        // Filtre par recherche
        final matchesSearch = movie.title.toLowerCase().contains(searchTerm) ||
            (movie.descriptions?['en']?.toLowerCase().contains(searchTerm) ??
                false);

        // Filtre par catégorie
        final matchesCategory = _selectedCategory == 'All' ||
            movie.categories.contains(_selectedCategory);

        // Filtre par genre
        final matchesGenre =
            _selectedGenre == 'All' || movie.genres.contains(_selectedGenre);

        // Filtre par type
        final matchesType = _selectedType == 'All' ||
            (_selectedType == 'Movie' && movie.isMovie) ||
            (_selectedType == 'Series' && movie.isSeries);

        return matchesSearch && matchesCategory && matchesGenre && matchesType;
      }).toList();
    });
  }

  Stream<List<CastModel>> _getFilteredActors(MovieController controller) {
    String searchTerm = _searchController.text.toLowerCase();

    return controller.getAllMovies().map((movies) {
      final allActors = <CastModel>[];

      for (final movie in movies) {
        if (movie.cast != null) {
          allActors.addAll(movie.cast!);
        }
      }

      // Éviter les doublons
      final uniqueActors = <String, CastModel>{};
      for (final actor in allActors) {
        uniqueActors.putIfAbsent(actor.id, () => actor);
      }

      return uniqueActors.values.where((actor) {
        return actor.name.toLowerCase().contains(searchTerm) ||
            (actor.role?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final movieController = Provider.of<MovieController>(context);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/icon_search.svg',
                                width: 20,
                                height: 20,
                                color: Colors.grey,
                              ),
                              AppSpacing.w10,
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: appLocalizations.search!,
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  onChanged: (value) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.w10,
                      GestureDetector(
                        onTap: _toggleFilterPopup,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _showFilterPopup
                                ? AppColor.primary.withOpacity(0.8)
                                : AppColor.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/icon_filter.svg',
                            width: 24,
                            height: 24,
                            color: AppColor.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h20,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Acteurs
                          Text(
                            appLocalizations.actors!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          AppSpacing.h20,
                          StreamBuilder<List<CastModel>>(
                            stream: _getFilteredActors(movieController),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final actors = snapshot.data!;

                              if (actors.isEmpty) {
                                return Center(
                                  child: Text(
                                    appLocalizations.no!,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: actors.length,
                                  itemBuilder: (_, index) {
                                    final actor = actors[index];
                                    return ActorsCard(
                                      onTap: () {
                                        /*Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ActorDetailsScreen(actor: actor),
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
                          ),
                          AppSpacing.h20,
                          // Section Films & Séries
                          Text(
                            appLocalizations.moviesSeries!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          AppSpacing.h20,
                          StreamBuilder<List<MovieModel>>(
                            stream: _getFilteredMovies(movieController),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final movies = snapshot.data!;

                              if (movies.isEmpty) {
                                return Center(
                                  child: Text(
                                    appLocalizations.no!,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                );
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: 0.6,
                                ),
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                  final movie = movies[index];
                                  return SearchMovieCard(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MovieDetailsScreen(
                                            movie: movie,
                                          ),
                                        ),
                                      );
                                    },
                                    name: movie.title,
                                    image: movie.thumbnailUrl,
                                    duration: movie.formattedDuration,
                                    rating: movie.rating.toString(),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showFilterPopup) _buildFilterPopup(context),
        ],
      ),
    );
  }
}

/*import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/controller/movie_controller.dart';
import 'package:abbeav/models/movies_model.dart';
import 'package:abbeav/view/home/widgets/title_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/database/movie_data.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/actor_details/screens/actor_details_screen.dart';
import 'package:abbeav/view/movie_details_screen/screens/movie_details_screen.dart';
import 'package:abbeav/view/search/widgets/actors_card.dart';
import 'package:abbeav/view/search/widgets/search_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedGenre = 'All';
  bool _showFilterPopup = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  List<String> _categories = [];
  List<String> _genres = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _initializeFilters(AppLocalizations appLocalizations) {
    _categories = [
      appLocalizations.all!,
      appLocalizations.movies!,
      appLocalizations.series!,
      appLocalizations.documentaries!,
    ];

    _genres = [
      appLocalizations.all!,
      appLocalizations.action!,
      appLocalizations.scienceFiction!,
      appLocalizations.thriller!,
    ];

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = appLocalizations.all!;
    }
    if (!_genres.contains(_selectedGenre)) {
      _selectedGenre = appLocalizations.all!;
    }
  }

  void _toggleFilterPopup() {
    setState(() {
      _showFilterPopup = !_showFilterPopup;
      if (_showFilterPopup) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildFilterPopup(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    _initializeFilters(appLocalizations);

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.12,
      right: MediaQuery.of(context).size.width * 0.05,
      left: MediaQuery.of(context).size.width * 0.05,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    appLocalizations.category!,
                    _categories,
                    _selectedCategory,
                    (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  _buildFilterSection(
                    appLocalizations.genre!,
                    _genres,
                    _selectedGenre,
                    (value) {
                      setState(() => _selectedGenre = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = appLocalizations.all!;
                            _selectedGenre = appLocalizations.all!;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: Text(appLocalizations.reset!),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _toggleFilterPopup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          appLocalizations.apply!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options,
      String selectedValue, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () {
                onChanged(option);
                _animationController.forward(from: 0.8);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primary : Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: AppColor.secondary, width: 1.5)
                      : null,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/icon_search.svg',
                                width: 20,
                                height: 20,
                                color: Colors.grey,
                              ),
                              AppSpacing.w10,
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        appLocalizations.search!, //'Search...',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.w10,
                      GestureDetector(
                        onTap: _toggleFilterPopup,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _showFilterPopup
                                ? AppColor.primary.withOpacity(0.8)
                                : AppColor.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/icon_filter.svg',
                            width: 24,
                            height: 24,
                            color: AppColor.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h20,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appLocalizations.actors!,
                            //'Actors',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          AppSpacing.h20,
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
                                          onTap: () {},
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
                          AppSpacing.h20,
                          Text(
                            appLocalizations.moviesSeries!,
                            //'Movies & Series',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          AppSpacing.h20,
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 30,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.6,
                            ),
                            itemCount: MovieData.movies3.length,
                            itemBuilder: (context, i) {
                              return SearchMovieCard(
                                onTap: () {
                                  /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailsScreen(
                                        image: MovieData.movies3[i].image,
                                      ),
                                    ),
                                  );*/
                                },
                                name: MovieData.movies3[i].name,
                                image: MovieData.movies3[i].image,
                                duration: MovieData.movies3[i].duration,
                                rating: MovieData.movies3[i].rating,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showFilterPopup) _buildFilterPopup(context),
        ],
      ),
    );
  }
}*/
