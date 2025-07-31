import 'package:abbeav/controller/movie_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/models/movies_model.dart';

class LandingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final MovieController _movieController;

  LandingProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _movieController =
            MovieController(firestore: firestore ?? FirebaseFirestore.instance);

  // États du provider
  int _activeIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Données des films
  List<MovieModel> _featuredMovies = [];
  List<MovieModel> _popularMovies = [];
  List<MovieModel> _newReleases = [];
  List<MovieModel> _trendingMovies = [];

  // Getters
  int get activeIndex => _activeIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MovieModel> get featuredMovies => _featuredMovies;
  List<MovieModel> get popularMovies => _popularMovies;
  List<MovieModel> get newReleases => _newReleases;
  List<MovieModel> get trendingMovies => _trendingMovies;

  // Méthodes pour changer l'état
  void onSliderIndexChange(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  // Initialisation des données
  Future<void> initializeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadFeaturedMovies(),
        _loadPopularMovies(),
        _loadNewReleases(),
        _loadTrendingMovies(),
      ]);
    } catch (e) {
      _errorMessage = "Failed to load data: ${e.toString()}";
      //////debugPrint(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Chargement des films boostés (carousel principal)
  Future<void> _loadFeaturedMovies() async {
    try {
      _featuredMovies = await _movieController
          .getFeaturedMovies()
          .first
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      _errorMessage = "Failed to load featured movies";
      rethrow;
    }
  }

  // Chargement des films populaires
  Future<void> _loadPopularMovies() async {
    try {
      _popularMovies = await _movieController
          .getPopularMovies()
          .first
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      _errorMessage = "Failed to load popular movies";
      rethrow;
    }
  }

  // Chargement des nouveautés
  Future<void> _loadNewReleases() async {
    try {
      _newReleases = await _movieController
          .getNewReleases()
          .first
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      _errorMessage = "Failed to load new releases";
      rethrow;
    }
  }

  // Chargement des tendances
  Future<void> _loadTrendingMovies() async {
    try {
      _trendingMovies = await _movieController
          .getTrendingMovies()
          .first
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      _errorMessage = "Failed to load trending movies";
      rethrow;
    }
  }

  // Méthode pour rafraîchir toutes les données
  Future<void> refreshData() async {
    await initializeData();
  }

  // Méthode pour obtenir un film par son ID
  Future<MovieModel?> getMovieById(String movieId) async {
    try {
      // Vérifie d'abord dans les listes chargées
      final allMovies = [
        ..._featuredMovies,
        ..._popularMovies,
        ..._newReleases,
        ..._trendingMovies,
      ];

      final localMovie = allMovies.cast<MovieModel?>().firstWhere(
            (movie) => movie?.id == movieId,
            orElse: () => null,
          );

      if (localMovie != null) return localMovie;

      // Si non trouvé, charge depuis Firestore
      final doc = await _firestore.collection('movies').doc(movieId).get();
      if (!doc.exists) return null;

      return MovieModel.fromFirestore(doc);
    } catch (e) {
      //////debugPrint('Error getting movie by ID: $e');
      return null;
    }
  }
}

/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/movies_model.dart';

class LandingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _activeIndex = 0;
  int get activeIndex => _activeIndex;

  List<String> sliderbanners = [
    'assets/images/slider1.jpg',
    'assets/images/slider2.jpg',
    'assets/images/slider3.jpg',
  ];

  List<MovieModel> _featuredMovies = [];
  List<MovieModel> _popularMovies = [];
  List<MovieModel> _newReleases = [];
  List<MovieModel> _trendingMovies = [];

  List<MovieModel> get featuredMovies => _featuredMovies;
  List<MovieModel> get popularMovies => _popularMovies;
  List<MovieModel> get newReleases => _newReleases;
  List<MovieModel> get trendingMovies => _trendingMovies;

  void onSliderIndexChange(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  // Charger les films boostés
  Future<void> loadFeaturedMovies() async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('isFeatured', isEqualTo: true)
          .orderBy('publishDate', descending: true)
          .limit(5)
          .get();

      _featuredMovies =
          snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      //////debugPrint('Error loading featured movies: $e');
    }
  }

  // Charger les films populaires
  Future<void> loadPopularMovies() async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('viewCount', descending: true)
          .limit(10)
          .get();

      _popularMovies =
          snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      //////debugPrint('Error loading popular movies: $e');
    }
  }

  // Charger les nouveautés
  Future<void> loadNewReleases() async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('publishDate', descending: true)
          .limit(10)
          .get();

      _newReleases =
          snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      //////debugPrint('Error loading new releases: $e');
    }
  }

  // Charger les tendances
  Future<void> loadTrendingMovies() async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('isTrending', isEqualTo: true)
          .orderBy('publishDate', descending: true)
          .limit(10)
          .get();

      _trendingMovies =
          snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      //////debugPrint('Error loading trending movies: $e');
    }
  }

  // Initialiser toutes les données
  Future<void> initializeData() async {
    await Future.wait([
      loadFeaturedMovies(),
      loadPopularMovies(),
      loadNewReleases(),
      loadTrendingMovies(),
    ]);
  }
}*/

/*import 'package:flutter/material.dart';

class LandingProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  int activeIndex = 0;
  CarouselController? controller = CarouselController();

  PageController pageController = PageController();

  List<String> sliderbanners = [
    "assets/images/carousel/mv_02.png",
    "assets/images/carousel/mv_01.jpg",
    "assets/images/carousel/mv_03.jpg",
  ];
  List<String> bannerTitels = [
    "Mulan",
    "Vikings",
    "The Flash",
  ];

  void onNavigationChange(int i) {
    _selectedIndex = i;
    notifyListeners();
  }

  void onSliderIndexChange(int i) {
    activeIndex = i;
    notifyListeners();
  }
}*/
