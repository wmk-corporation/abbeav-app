import 'dart:async';

import 'package:abbeav/controller/download_controller.dart';
import 'package:abbeav/controller/movie_controller.dart';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/home/providers/user_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/view/actor_details/screens/actor_details_screen.dart';
import 'package:abbeav/view/home/widgets/movie_card_widget.dart';
import 'package:abbeav/view/home/widgets/play_button.dart';
import 'package:abbeav/view/movie_details_screen/widgets/title_text.dart';
import 'package:abbeav/view/search/widgets/actors_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abbeav/models/movies_model.dart';
import 'package:abbeav/models/user_model.dart';
import 'package:abbeav/models/comment_model.dart';
//import 'package:abbeav/controllers/movie_controller.dart';
//import 'package:abbeav/controllers/user_controller.dart';
//import 'package:abbeav/controllers/download_controller.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({Key? key, required this.movie}) : super(key: key);
  final MovieModel movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isMiniPlayer = false;
  late AnimationController _miniPlayerAnim;
  late Animation<double> _miniPlayerAnimation;

  bool _isLoadingVideo = false;
  bool _hasVideoError = false;
  String? _videoErrorMsg;
  bool _isVideoEnded = false;
  bool _hasInternet = true;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String? _offlinePath;

  final UserController _userController = UserController();
  final MovieController _movieController =
      MovieController(firestore: FirebaseFirestore.instance);
  final DownloadController _downloadController = DownloadController();

  late UserModel? _currentUser;
  StreamSubscription<Duration>? _progressSubscription;
  Duration _currentPosition = Duration.zero;
  String? _currentUserId;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _galleryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initUser();
    _initVideo();
    _checkDownloadStatus();
    _miniPlayerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _miniPlayerAnimation =
        CurvedAnimation(parent: _miniPlayerAnim, curve: Curves.easeOutExpo);
  }

  Future<void> _initUser() async {
    final user = await _userController.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
        _currentUserId = user.uid;
      });
      _checkIfLiked();
      _checkIfSaved();
      _loadWatchingProgress();
    }
  }

  Future<void> _checkIfLiked() async {
    if (_currentUserId == null) return;
    final isLiked =
        await _movieController.isMovieLiked(widget.movie.id, _currentUserId!);
    setState(() {
      _isLiked = isLiked;
    });
  }

  Future<void> _checkIfSaved() async {
    if (_currentUserId == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .get();
    final favorites = List<String>.from(userDoc['favoriteMovies'] ?? []);
    setState(() {
      _isSaved = favorites.contains(widget.movie.id);
    });
  }

  Future<void> _loadWatchingProgress() async {
    if (_currentUserId == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .get();
    final progress = (userDoc['watchingProgress'] ?? {})[widget.movie.id] ?? 0;
    setState(() {
      widget.movie.watchedProgress = progress / widget.movie.duration.inSeconds;
    });
  }

  Future<void> _initVideo() async {
    await _checkInternetAndInitVideo();
    if (widget.movie.watchedProgress != null &&
        widget.movie.watchedProgress! > 0) {
      final position = widget.movie.duration * widget.movie.watchedProgress!;
      _videoPlayerController.seekTo(position);
    }
  }

  Future<void> _checkInternetAndInitVideo() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        _hasInternet = false;
        _isLoadingVideo = false;
        _videoErrorMsg = "Aucune connexion Internet.";
      });
      _showSnackBar("Aucune connexion Internet.", Colors.red);
      return;
    }

    setState(() {
      _hasInternet = true;
      _isLoadingVideo = true;
      _videoErrorMsg = null;
    });

    try {
      _videoPlayerController =
          VideoPlayerController.network(widget.movie.videoUrl)
            ..addListener(_videoListener)
            ..initialize().then((_) {
              setState(() {
                _isLoadingVideo = false;
                _hasVideoError = false;
                _videoErrorMsg = null;
              });

              // Si le film a déjà été regardé, reprendre là où l'utilisateur s'était arrêté
              if (widget.movie.watchedProgress != null &&
                  widget.movie.watchedProgress! > 0) {
                final position =
                    widget.movie.duration * widget.movie.watchedProgress!;
                _videoPlayerController.seekTo(position);
              }
            });
    } catch (e) {
      setState(() {
        _isLoadingVideo = false;
        _hasVideoError = true;
        _videoErrorMsg = "Erreur de chargement vidéo.";
      });
      _showSnackBar("Erreur de chargement vidéo.", Colors.red);
    }
  }

  Future<void> _checkDownloadStatus() async {
    if (_currentUserId == null) return;

    final isDownloaded = await _downloadController.isMovieDownloaded(
        _currentUserId!, widget.movie.id);
    if (isDownloaded) {
      final path = await _downloadController.getOfflineMoviePath(
          _currentUserId!, widget.movie.id);
      setState(() {
        _isDownloaded = true;
        _offlinePath = path;
      });
    }
  }

  void _videoListener() {
    if (_videoPlayerController.value.hasError) {
      setState(() {
        _hasVideoError = true;
        _videoErrorMsg = _videoPlayerController.value.errorDescription ??
            "Erreur inconnue de la vidéo.";
      });
      _showSnackBar(_videoErrorMsg!, Colors.red);
    }

    // Mettre à jour la position actuelle
    if (_videoPlayerController.value.isInitialized) {
      setState(() {
        _currentPosition = _videoPlayerController.value.position;
      });

      // Sauvegarder la progression toutes les 10 secondes
      if (_currentPosition.inSeconds % 10 == 0 && _currentUserId != null) {
        _saveWatchingProgress();
      }
    }

    if (_videoPlayerController.value.position >=
            _videoPlayerController.value.duration &&
        _videoPlayerController.value.isInitialized &&
        !_isLoadingVideo) {
      setState(() {
        _isVideoEnded = true;
        _isPlaying = false;
      });
      _showSnackBar("Vidéo terminée.", Colors.green);

      // Marquer comme complètement regardé
      if (_currentUserId != null) {
        _saveWatchingProgress(fullDuration: true);
      }
    }
  }

  Future<void> _saveWatchingProgress({bool fullDuration = false}) async {
    if (_currentUserId == null) return;

    final progress = fullDuration
        ? widget.movie.duration
        : _videoPlayerController.value.position;

    await _userController.updateWatchingProgress(
      userId: _currentUserId!,
      movieId: widget.movie.id,
      progress: progress,
    );
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _videoPlayerController.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    _miniPlayerAnim.dispose();
    _commentController.dispose();
    _galleryScrollController.dispose();
    super.dispose();
  }

  void _closeVideoCompletely() {
    _chewieController?.pause();
    _chewieController?.dispose();
    _chewieController = null;
    _videoPlayerController.pause();
    _isPlaying = false;
    _isMiniPlayer = false;
    _isLoadingVideo = false;
    _hasVideoError = false;
    _videoErrorMsg = null;
    _isVideoEnded = false;
    _miniPlayerAnim.reset();
  }

  void _initChewieController() {
    _chewieController?.dispose();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColor.primary,
        handleColor: AppColor.primary,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.withOpacity(0.5),
      ),
      errorBuilder: (context, errorMsg) {
        return Center(
          child: Text(
            errorMsg,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
      },
    );
  }

  void _togglePlay() async {
    if (!_hasInternet && !_isDownloaded) {
      _showSnackBar("Aucune connexion Internet.", Colors.red);
      return;
    }

    if (_isLoadingVideo) return;

    if (_hasVideoError) {
      _showSnackBar(_videoErrorMsg ?? "Erreur vidéo.", Colors.red);
      return;
    }

    if (!_videoPlayerController.value.isInitialized) {
      setState(() {
        _isLoadingVideo = true;
      });

      try {
        await _videoPlayerController.initialize();
        setState(() {
          _isLoadingVideo = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingVideo = false;
          _hasVideoError = true;
          _videoErrorMsg = "Erreur d'initialisation vidéo.";
        });
        _showSnackBar(_videoErrorMsg!, Colors.red);
        return;
      }
    }

    setState(() {
      _isPlaying = !_isPlaying;
      _isVideoEnded = false;

      if (_isPlaying) {
        _initChewieController();
        _videoPlayerController.play();
      } else {
        _chewieController?.pause();
        _chewieController?.dispose();
        _chewieController = null;
        _videoPlayerController.pause();
      }
    });
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _closeVideoAndNavigate(Widget page) async {
    _closeVideoCompletely();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutExpo,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _onLikeTap() async {
    if (_currentUserId == null) {
      _showSnackBar("Connectez-vous pour aimer ce film", Colors.orange);
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
    });

    try {
      await _movieController.toggleLike(widget.movie.id, _currentUserId!);
      _showSnackBar(
        _isLiked ? "Ajouté aux favoris !" : "Retiré des favoris.",
        _isLiked ? Colors.pink : Colors.grey[800]!,
      );
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked; // Revert on error
      });
      _showSnackBar("Erreur lors de la mise à jour", Colors.red);
    }
  }

  void _onSaveTap() async {
    if (_currentUserId == null) {
      _showSnackBar("Connectez-vous pour sauvegarder ce film", Colors.orange);
      return;
    }

    setState(() {
      _isSaved = !_isSaved;
    });

    try {
      await _userController.toggleFavorite(_currentUserId!, widget.movie.id);
      _showSnackBar(
        _isSaved ? "Film sauvegardé !" : "Film retiré des sauvegardes.",
        _isSaved ? Colors.green : Colors.grey[800]!,
      );
    } catch (e) {
      setState(() {
        _isSaved = !_isSaved; // Revert on error
      });
      _showSnackBar("Erreur lors de la sauvegarde", Colors.red);
    }
  }

  Future<void> _onDownloadTap() async {
    if (_currentUserId == null) {
      _showSnackBar("Connectez-vous pour télécharger ce film", Colors.orange);
      return;
    }

    if (_isDownloaded) {
      _showSnackBar("Ce film est déjà téléchargé", Colors.blue);
      return;
    }

    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      await _downloadController.startDownload(widget.movie);
      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
      });
      _showSnackBar(
          "Téléchargement terminé - Disponible hors ligne", Colors.green);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ////debugPrint('$e');
      _showSnackBar(
          "Erreur lors du téléchargement: ${e.toString()}", Colors.red);
    }
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutExpo,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF232526), Color(0xFF414345)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 6,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.chat_bubble_2,
                                color: Colors.white70),
                            const SizedBox(width: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('comments')
                                  .where('movieId', isEqualTo: widget.movie.id)
                                  .orderBy('createdAt', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.docs.length ?? 0;
                                return Text(
                                  "Comments ($count)",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('comments')
                              .where('movieId', isEqualTo: widget.movie.id)
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final comments = snapshot.data!.docs.map((doc) {
                              return CommentModel.fromFirestore(doc);
                            }).toList();

                            if (comments.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Aucun commentaire",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: comments.length,
                              itemBuilder: (context, i) {
                                final c = comments[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.grey[700],
                                            child: c.userPhotoUrl != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                    child: Image.network(
                                                      c.userPhotoUrl!,
                                                      width: 36,
                                                      height: 36,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Text(
                                                    c.userFullName[0],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            c.userFullName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            c.timeAgo,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        c.content,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Divider(
                                          color: Colors.white12, height: 24),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (_currentUserId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          color: Colors.black.withOpacity(0.7),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _commentController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Add a comment...",
                                    hintStyle:
                                        const TextStyle(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.white10,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  CupertinoIcons.arrow_up_circle_fill,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  if (_commentController.text.trim().isEmpty)
                                    return;

                                  try {
                                    await _movieController.addComment(
                                      movieId: widget.movie.id,
                                      userId: _currentUserId!,
                                      userFullName:
                                          _currentUser?.fullName ?? 'Anonymous',
                                      userPhotoUrl: _currentUser?.photoUrl,
                                      content: _commentController.text.trim(),
                                    );

                                    _commentController.clear();
                                    FocusScope.of(context).unfocus();
                                  } catch (e) {
                                    _showSnackBar(
                                        "Erreur lors de l'ajout du commentaire",
                                        Colors.red);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerHeight = MediaQuery.of(context).size.height * .25;

    final userLanguage = Provider.of<UserProvider>(context).languagePreference;
    final miniHeight = 90.0;
    final miniWidth = 160.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: containerHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _miniPlayerAnimation,
                    builder: (context, child) {
                      final isMini = _isMiniPlayer || _miniPlayerAnim.value > 0;
                      final top =
                          isMini ? containerHeight - miniHeight - 10 : 0.0;
                      final left = isMini
                          ? MediaQuery.of(context).size.width / 2 -
                              miniWidth / 2
                          : 0.0;
                      final width = isMini
                          ? miniWidth
                          : MediaQuery.of(context).size.width;
                      final height = isMini ? miniHeight : containerHeight;

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutExpo,
                        top: top,
                        left: left,
                        width: width,
                        height: height,
                        child: GestureDetector(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutExpo,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(isMini ? 18 : 0),
                              boxShadow: [
                                if (isMini)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(isMini ? 18 : 0),
                              child: _isLoadingVideo
                                  ? Center(
                                      child: AnimatedOpacity(
                                        opacity: 1,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        child: const CircularProgressIndicator(
                                          color: AppColor.primary,
                                        ),
                                      ),
                                    )
                                  : _hasVideoError
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error_outline,
                                                  color: Colors.red[300],
                                                  size: 40),
                                              const SizedBox(height: 8),
                                              Text(
                                                _videoErrorMsg ??
                                                    "Erreur vidéo.",
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white10,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  _checkInternetAndInitVideo();
                                                },
                                                icon: const Icon(Icons.refresh),
                                                label: const Text("Réessayer"),
                                              )
                                            ],
                                          ),
                                        )
                                      : _isPlaying && _chewieController != null
                                          ? Chewie(
                                              controller: _chewieController!)
                                          : Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.network(
                                                  widget.movie.thumbnailUrl,
                                                  fit: BoxFit.cover,
                                                  alignment:
                                                      Alignment.topCenter,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[900],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                        size: 50,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (!_isPlaying)
                                                  Center(
                                                    child: AnimatedScale(
                                                      scale: 1,
                                                      duration: const Duration(
                                                          milliseconds: 400),
                                                      child: PlayButton(
                                                        onTap: _togglePlay,
                                                      ),
                                                    ),
                                                  ),
                                                if (_isVideoEnded)
                                                  Positioned.fill(
                                                    child: Container(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color:
                                                                  Colors.green,
                                                              size: 48,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            const Text(
                                                              "Lecture terminée",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            ElevatedButton.icon(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white10,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              onPressed: () {
                                                                _videoPlayerController
                                                                    .seekTo(
                                                                        Duration
                                                                            .zero);
                                                                _togglePlay();
                                                              },
                                                              icon: const Icon(
                                                                  Icons.replay),
                                                              label: const Text(
                                                                  "Rejouer"),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
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
            if (!_isMiniPlayer)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        color: AppColor.secondary,
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        widget.movie.type!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    AppSpacing.w10,
                                    Text(
                                      widget.movie.title,
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                              blurRadius: 8,
                                              color: Colors.black)
                                        ],
                                      ),
                                    ),
                                    AppSpacing.w20,
                                    ...widget.movie.genres.take(3).map(
                                          (g) => Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.18),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              g,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                                AppSpacing.h15,
                                AppSpacing.h15,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _onLikeTap,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: _isLiked
                                                      ? [
                                                          Colors.pink,
                                                          Colors.red
                                                        ]
                                                      : [
                                                          const Color(
                                                              0xFF232526),
                                                          const Color(
                                                              0xFF414345)
                                                        ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    CupertinoIcons.heart_fill,
                                                    color: _isLiked
                                                        ? Colors.white
                                                        : Colors.white70,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${widget.movie.likeCount ~/ 1000}.${widget.movie.likeCount % 1000 ~/ 100}k",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _onSaveTap,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: _isSaved
                                                      ? [
                                                          Colors.green,
                                                          Colors.teal
                                                        ]
                                                      : [
                                                          const Color(
                                                              0xFF232526),
                                                          const Color(
                                                              0xFF414345)
                                                        ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .bookmark_fill,
                                                    color: _isSaved
                                                        ? Colors.white
                                                        : Colors.white70,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text(
                                                    "Save",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Spacer(),
                                    /*SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.36,
                                    ),*/
                                    GestureDetector(
                                      onTap: _onDownloadTap,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        height: 32,
                                        width: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isDownloaded
                                              ? CupertinoIcons.checkmark_alt
                                              : CupertinoIcons
                                                  .arrow_down_to_line,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const TitleText(title: "Story"),
                        AppSpacing.h5,
                        Text(
                          widget.movie.getDescriptionForLanguage(userLanguage),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        AppSpacing.h20,
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('comments')
                              .where('movieId', isEqualTo: widget.movie.id)
                              .orderBy('createdAt', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final count = widget.movie.commentCount;
                            final lastComment = snapshot.data?.docs.firstOrNull;

                            return GestureDetector(
                              onTap: () => _showCommentsModal(context),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 21,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF232526),
                                      Color(0xFF414345)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          CupertinoIcons.chat_bubble_2_fill,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Comments $count",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (lastComment != null)
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              (lastComment.data() as Map<String,
                                                  dynamic>)['content'],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    AppSpacing.h10,
                                    const Text(
                                      "Tap to view all comments",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        AppSpacing.h20,
                        if (widget.movie.galleryImages != null &&
                            widget.movie.galleryImages!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TitleText(title: "Gallery"),
                              AppSpacing.h10,
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  controller: _galleryScrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.movie.galleryImages!.length,
                                  itemBuilder: (_, i) {
                                    return Container(
                                      width: 300,
                                      margin: EdgeInsets.only(
                                        right: i ==
                                                widget.movie.galleryImages!
                                                        .length -
                                                    1
                                            ? 0
                                            : 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          widget.movie.galleryImages![i],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[900],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                  size: 50,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              AppSpacing.h20,
                            ],
                          ),
                        if (widget.movie.cast != null &&
                            widget.movie.cast!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TitleText(title: "Cast"),
                              AppSpacing.h10,
                              SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.movie.cast!.length,
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
                              ),
                              AppSpacing.h20,
                            ],
                          ),
                        const TitleText(title: "Similar"),
                        AppSpacing.h10,
                        SizedBox(
                          height: 280,
                          child: FutureBuilder<List<MovieModel>>(
                            future:
                                _movieController.getSimilarMovies(widget.movie),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "Aucun film similaire trouvé",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                );
                              }

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (_, i) {
                                  final m = snapshot.data![i];
                                  return MovieCard(
                                    name: m.title,
                                    image: m.thumbnailUrl,
                                    duration: m.formattedDuration,
                                    rating: m.rating.toString(),
                                    onTap: () => _closeVideoAndNavigate(
                                      MovieDetailsScreen(movie: m),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        AppSpacing.h20,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:abbeav/style/app_color.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/database/movie_data.dart';
import 'package:abbeav/view/actor_details/screens/actor_details_screen.dart';
import 'package:abbeav/view/home/widgets/movie_card_widget.dart';
import 'package:abbeav/view/home/widgets/play_button.dart';
import 'package:abbeav/view/movie_details_screen/widgets/title_text.dart';
import 'package:abbeav/view/search/widgets/actors_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({Key? key, required this.image}) : super(key: key);
  final String image;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isLiked = false;
  bool _isSaved = false;
  int _likeCount = 1200;
  bool _isMiniPlayer = false;
  late AnimationController _miniPlayerAnim;
  late Animation<double> _miniPlayerAnimation;

  final String _demoVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  final List<Map<String, dynamic>> _comments = [
    {
      "user": "Alice",
      "date": "2025-07-15",
      "comment": "Incroyable film, j'ai adoré la scène finale !"
    },
    {
      "user": "Bob",
      "date": "2025-07-14",
      "comment": "Super casting et effets spéciaux impressionnants."
    },
    {
      "user": "Charlie",
      "date": "2025-07-13",
      "comment": "L'histoire est prenante du début à la fin."
    },
    {
      "user": "Dina",
      "date": "2025-07-12",
      "comment": "Un chef d'œuvre moderne, à voir absolument."
    },
    {
      "user": "Eve",
      "date": "2025-07-11",
      "comment": "La bande-son est juste parfaite !"
    },
  ];

  bool _isLoadingVideo = false;
  bool _hasVideoError = false;
  String? _videoErrorMsg;
  bool _isVideoEnded = false;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(_demoVideoUrl);
    _videoPlayerController.initialize().then((_) => setState(() {}));
    _miniPlayerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _miniPlayerAnimation =
        CurvedAnimation(parent: _miniPlayerAnim, curve: Curves.easeOutExpo);

    _checkInternetAndInitVideo();
  }

  Future<void> _checkInternetAndInitVideo() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        _hasInternet = false;
        _isLoadingVideo = false;
        _videoErrorMsg = "Aucune connexion Internet.";
      });
      _showSnackBar("Aucune connexion Internet.", Colors.red);
      return;
    }
    setState(() {
      _hasInternet = true;
      _isLoadingVideo = true;
      _videoErrorMsg = null;
    });
    _videoPlayerController = VideoPlayerController.network(_demoVideoUrl)
      ..addListener(_videoListener)
      ..initialize().then((_) {
        setState(() {
          _isLoadingVideo = false;
          _hasVideoError = false;
          _videoErrorMsg = null;
        });
      }).catchError((e) {
        setState(() {
          _isLoadingVideo = false;
          _hasVideoError = true;
          _videoErrorMsg = "Erreur de chargement vidéo.";
        });
        _showSnackBar("Erreur de chargement vidéo.", Colors.red);
      });
  }

  void _videoListener() {
    if (_videoPlayerController.value.hasError) {
      setState(() {
        _hasVideoError = true;
        _videoErrorMsg = _videoPlayerController.value.errorDescription ??
            "Erreur inconnue de la vidéo.";
      });
      _showSnackBar(_videoErrorMsg!, Colors.red);
    }
    if (_videoPlayerController.value.position >=
            _videoPlayerController.value.duration &&
        _videoPlayerController.value.isInitialized &&
        !_isLoadingVideo) {
      setState(() {
        _isVideoEnded = true;
        _isPlaying = false;
      });
      _showSnackBar("Vidéo terminée.", Colors.green);
    }
  }

  @override
  void dispose() {
    try {
      _videoPlayerController.removeListener(_videoListener);
    } catch (_) {}
    try {
      _chewieController?.dispose();
      _chewieController = null;
    } catch (_) {}
    try {
      _videoPlayerController.dispose();
    } catch (_) {}
    try {
      _miniPlayerAnim.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _closeVideoCompletely() {
    try {
      _chewieController?.pause();
      _chewieController?.dispose();
      _chewieController = null;
    } catch (_) {}
    try {
      _videoPlayerController.removeListener(_videoListener);
      _videoPlayerController.pause();
      _videoPlayerController.dispose();
    } catch (_) {}
    _isPlaying = false;
    _isMiniPlayer = false;
    _isLoadingVideo = false;
    _hasVideoError = false;
    _videoErrorMsg = null;
    _isVideoEnded = false;
    _miniPlayerAnim.reset();
  }

  void _initChewieController() {
    _chewieController?.dispose();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColor.primary,
        handleColor: AppColor.primary,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.withOpacity(0.5),
      ),
      errorBuilder: (context, errorMsg) {
        return Center(
          child: Text(
            errorMsg,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
      },
    );
  }

  void _togglePlay() async {
    if (!_hasInternet) {
      _showSnackBar("Aucune connexion Internet.", Colors.red);
      return;
    }
    if (_isLoadingVideo) return;
    if (_hasVideoError) {
      _showSnackBar(_videoErrorMsg ?? "Erreur vidéo.", Colors.red);
      return;
    }
    if (!_videoPlayerController.value.isInitialized) {
      setState(() {
        _isLoadingVideo = true;
      });
      try {
        await _videoPlayerController.initialize();
        setState(() {
          _isLoadingVideo = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingVideo = false;
          _hasVideoError = true;
          _videoErrorMsg = "Erreur d'initialisation vidéo.";
        });
        _showSnackBar(_videoErrorMsg!, Colors.red);
        return;
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
      _isVideoEnded = false;
      if (_isPlaying) {
        _initChewieController();
        _videoPlayerController.play();
      } else {
        _chewieController?.pause();
        _chewieController?.dispose();
        _chewieController = null;
        _videoPlayerController.pause();
      }
    });
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _closeVideoAndNavigate(Widget page) async {
    _closeVideoCompletely();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Ultra moderne animation OTT style
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutExpo,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _onLikeTap() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isLiked ? "Ajouté aux favoris !" : "Retiré des favoris."),
        backgroundColor: _isLiked ? Colors.pink : Colors.grey[800],
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _onSaveTap() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isSaved ? "Film sauvegardé !" : "Film retiré des sauvegardes."),
        backgroundColor: _isSaved ? Colors.green : Colors.grey[800],
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutExpo,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF232526), Color(0xFF414345)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 6,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.chat_bubble_2,
                                color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              "Comments (${_comments.length})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _comments.length,
                          itemBuilder: (context, i) {
                            final c = _comments[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.grey[700],
                                        child: Text(
                                          c["user"][0],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        c["user"],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Text(
                                        c["date"],
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    c["comment"],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  const Divider(
                                      color: Colors.white12, height: 24),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        color: Colors.black.withOpacity(0.7),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Add a comment...",
                                  hintStyle:
                                      const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                  CupertinoIcons.arrow_up_circle_fill,
                                  color: Colors.white,
                                  size: 30),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerHeight = MediaQuery.of(context).size.height * .25;
    final miniHeight = 90.0;
    final miniWidth = 160.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: containerHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _miniPlayerAnimation,
                    builder: (context, child) {
                      final isMini = _isMiniPlayer || _miniPlayerAnim.value > 0;
                      final top =
                          isMini ? containerHeight - miniHeight - 10 : 0.0;
                      final left = isMini
                          ? MediaQuery.of(context).size.width / 2 -
                              miniWidth / 2
                          : 0.0;
                      final width = isMini
                          ? miniWidth
                          : MediaQuery.of(context).size.width;
                      final height = isMini ? miniHeight : containerHeight;
                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutExpo,
                        top: top,
                        left: left,
                        width: width,
                        height: height,
                        child: GestureDetector(
                          //onVerticalDragStart: _onVerticalDragStart,
                          //onVerticalDragUpdate: _onVerticalDragUpdate,
                          //onVerticalDragEnd: _onVerticalDragEnd,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutExpo,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(isMini ? 18 : 0),
                              boxShadow: [
                                if (isMini)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(isMini ? 18 : 0),
                              child: _isLoadingVideo
                                  ? Center(
                                      child: AnimatedOpacity(
                                        opacity: 1,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        child: const CircularProgressIndicator(
                                          color: AppColor.primary,
                                        ),
                                      ),
                                    )
                                  : _hasVideoError
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error_outline,
                                                  color: Colors.red[300],
                                                  size: 40),
                                              const SizedBox(height: 8),
                                              Text(
                                                _videoErrorMsg ??
                                                    "Erreur vidéo.",
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white10,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  _checkInternetAndInitVideo();
                                                },
                                                icon: const Icon(Icons.refresh),
                                                label: const Text("Réessayer"),
                                              )
                                            ],
                                          ),
                                        )
                                      : _isPlaying && _chewieController != null
                                          ? Chewie(
                                              controller: _chewieController!)
                                          : Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.asset(
                                                  widget.image,
                                                  fit: BoxFit.cover,
                                                  alignment:
                                                      Alignment.topCenter,
                                                ),
                                                if (!_isPlaying)
                                                  Center(
                                                    child: AnimatedScale(
                                                      scale: 1,
                                                      duration: const Duration(
                                                          milliseconds: 400),
                                                      child: PlayButton(
                                                        onTap: _togglePlay,
                                                      ),
                                                    ),
                                                  ),
                                                if (_isVideoEnded)
                                                  Positioned.fill(
                                                    child: Container(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color:
                                                                  Colors.green,
                                                              size: 48,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            const Text(
                                                              "Lecture terminée",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            ElevatedButton.icon(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white10,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              onPressed: () {
                                                                _togglePlay();
                                                              },
                                                              icon: const Icon(
                                                                  Icons.replay),
                                                              label: const Text(
                                                                  "Rejouer"),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
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
            if (!_isMiniPlayer)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Mulan',
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                              blurRadius: 8,
                                              color: Colors.black)
                                        ],
                                      ),
                                    ),
                                    AppSpacing.w20,
                                    ...["Action", "Drama", "Adventure"].map(
                                      (g) => Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          g,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.h15,
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _onLikeTap,
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _isLiked
                                                ? [Colors.pink, Colors.red]
                                                : [
                                                    Color(0xFF232526),
                                                    Color(0xFF414345)
                                                  ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.heart_fill,
                                              color: _isLiked
                                                  ? Colors.white
                                                  : Colors.white70,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${_likeCount ~/ 1000}.${_likeCount % 1000 ~/ 100}k",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _onSaveTap,
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _isSaved
                                                ? [Colors.green, Colors.teal]
                                                : [
                                                    Color(0xFF232526),
                                                    Color(0xFF414345)
                                                  ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.bookmark_fill,
                                              color: _isSaved
                                                  ? Colors.white
                                                  : Colors.white70,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Save",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.46,
                                    ), // Spacer for alignment
                                    //Spacer(),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        height: 32,
                                        width: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.arrow_down_to_line,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const TitleText(title: "Story"),
                        AppSpacing.h5,
                        const Text(
                          'In a post-apocalyptic world, Regan and her family learn that the alien predators can be defeated using high-frequency audio. Soon, armed with this knowledge, they set out to look for other survivors.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        AppSpacing.h20,
                        GestureDetector(
                          onTap: () => _showCommentsModal(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 21),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF232526), Color(0xFF414345)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        CupertinoIcons.chat_bubble_2_fill,
                                        color: Colors.white,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Comments ${_comments.length}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        _comments.first["comment"],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.h10,
                                const Text(
                                  "Tap to view all comments",
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.h20,
                        const TitleText(title: "Gallery"),
                        AppSpacing.h10,
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/poster9.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        AppSpacing.h20,
                        const TitleText(title: "Cast"),
                        AppSpacing.h10,
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: MovieData.actors.length,
                            itemBuilder: (_, i) {
                              final actor = MovieData.actors[i];
                              return ActorsCard(
                                onTap: () => _closeVideoAndNavigate(
                                    const ActorDetailsSceen()),

                                /*onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ActorDetailsSceen(),
                                  ),
                                ),*/
                                image: actor.image,
                                name: actor.name,
                              );
                            },
                          ),
                        ),
                        AppSpacing.h20,
                        const TitleText(title: "Similar"),
                        AppSpacing.h10,
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: MovieData.movies2.length,
                            itemBuilder: (_, i) {
                              final m = MovieData.movies2[i];
                              return MovieCard(
                                name: m.name,
                                image: m.image,
                                duration: m.duration,
                                rating: m.rating,
                                onTap: () => _closeVideoAndNavigate(
                                  MovieDetailsScreen(image: m.image),
                                ),
                              );
                            },
                          ),
                        ),
                        AppSpacing.h20,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}*/
