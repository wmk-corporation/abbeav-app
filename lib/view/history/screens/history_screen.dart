import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/database/movie_data.dart';
import 'package:abbeav/models/movie_model.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/history/widgets/download_movie_card.dart';
import 'package:abbeav/view/history/widgets/history_watch_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<MovieModel> watchingHistory = [
    MovieModel(
      'assets/images/poster4.jpg',
      name: 'A Quiet Place 2',
      duration: '1h 37m',
      rating: '4.2',
      watchProgress: '00:32:52 / 02:25:00',
      lastWatched: '2h ago',
    ),
    MovieModel(
      'assets/images/poster3.png',
      name: 'The Flash',
      duration: '8 seasons',
      rating: '4.0',
      watchProgress: '01:15:00 / 01:45:00',
      lastWatched: '1d ago',
    ),
    MovieModel(
      'assets/images/poster5.jpg',
      name: 'Money Heist',
      duration: '5 seasons',
      rating: '8.2',
      watchProgress: '00:42:30 / 00:50:00',
      lastWatched: '3h ago',
    ),
    MovieModel(
      'assets/images/poster8.jpg',
      name: 'Furie',
      duration: '1h 38m',
      rating: '4.0',
      watchProgress: '00:12:15 / 01:38:00',
      lastWatched: '5d ago',
    ),
    MovieModel(
      'assets/images/poster6.jpg',
      name: 'Joker',
      duration: '2h 2m',
      rating: '4.2',
      watchProgress: '01:45:30 / 02:02:00',
      lastWatched: '1w ago',
    ),
  ];

  final List<MovieModel> moviesDownload = [
    MovieModel(
      'assets/images/poster4.jpg',
      name: 'A Quiet Place 2',
      duration: '1h 37m',
      rating: '4.2',
      downloadProgress: 0.65,
      downloadStatus: 'Downloading',
      downloadSize: '2.1GB',
    ),
    MovieModel(
      'assets/images/poster3.png',
      name: 'The Flash',
      duration: '8 seasons',
      rating: '4.0',
      downloadProgress: 1.0,
      downloadStatus: 'Downloaded',
      downloadSize: '4.8GB',
      downloadTime: '3h ago',
    ),
    MovieModel(
      'assets/images/poster5.jpg',
      name: 'Money Heist',
      duration: '5 seasons',
      rating: '8.2',
      downloadProgress: 0.0,
      downloadStatus: 'Queued',
      downloadSize: '6.5GB',
    ),
    MovieModel(
      'assets/images/poster8.jpg',
      name: 'Furie',
      duration: '1h 38m',
      rating: '4.0',
      downloadProgress: 0.32,
      downloadStatus: 'Downloading',
      downloadSize: '1.8GB',
    ),
    MovieModel(
      'assets/images/poster6.jpg',
      name: 'Joker',
      duration: '2h 2m',
      rating: '4.2',
      downloadProgress: 0.89,
      downloadStatus: 'Downloading',
      downloadSize: '2.4GB',
    ),
    MovieModel(
      'assets/images/poster7.jpg',
      name: 'Leo',
      duration: '2h 44m',
      rating: '7.2',
      downloadProgress: 0.0,
      downloadStatus: 'Failed',
      downloadSize: '3.2GB',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                // TabBar personnalisé
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[900],
                  ),
                  /*child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[400],
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColor.primary,
                    ),
                    tabs: const [
                      Tab(text: 'Watching'),
                      Tab(text: 'Downloaded'),
                    ],
                  ),*/
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[400],
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      //color: AppColor.secondary.withOpacity(.4),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3DCBFF).withOpacity(0.3),
                          Color(0xFF7D3CF8).withOpacity(0.8)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return states.contains(MaterialState.pressed)
                            ? Colors.white.withOpacity(0.1)
                            : null;
                      },
                    ),
                    tabs: const [
                      Tab(
                        iconMargin: EdgeInsets.zero,
                        child: Text(
                          'Watching',
                          style: TextStyle(
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        iconMargin: EdgeInsets.zero,
                        child: Text(
                          'Downloaded',
                          style: TextStyle(
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.h20,

                Expanded(
                  child: TabBarView(
                    children: [
                      // Onglet Watching avec animations
                      _buildAnimatedListView(watchingHistory, isWatching: true),

                      // Onglet Downloaded avec animations
                      _buildAnimatedListView(moviesDownload, isWatching: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedListView(List<MovieModel> items,
      {required bool isWatching}) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          child: isWatching
              ? HistoryWatchCard(movie: items[index])
              : DownloadedMovieCard(
                  movie: items[index],
                  onDelete: (String) {},
                  onRetryDownload: (String) {},
                  onPlay: (String) {},
                ),
        );
      },
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: AnimationController(
          vsync: Scaffold.of(context),
          duration: const Duration(milliseconds: 500),
        )..forward(),
        curve: Interval(
          0.1 * index,
          0.3 + 0.1 * index,
          curve: Curves.easeOutQuart,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/database/movie_data.dart';
import 'package:abbeav/models/movie_model.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/history/widgets/download_movie_card.dart';
import 'package:abbeav/view/history/widgets/history_watch_card.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final List<MovieModel> watchingHistory = [
    MovieModel(
      'assets/images/poster4.jpg',
      name: 'A Quiet Place 2',
      duration: '1h 37m',
      rating: '4.2',
      watchProgress: '00:32:52 / 02:25:00',
      lastWatched: '2h ago',
    ),
    MovieModel(
      'assets/images/poster3.png',
      name: 'The Flash',
      duration: '8 seasons',
      rating: '4.0',
      watchProgress: '01:15:00 / 01:45:00',
      lastWatched: '1d ago',
    ),
    MovieModel(
      'assets/images/poster5.jpg',
      name: 'Money Heist',
      duration: '5 seasons',
      rating: '8.2',
      watchProgress: '00:42:30 / 00:50:00',
      lastWatched: '3h ago',
    ),
    MovieModel(
      'assets/images/poster8.jpg',
      name: 'Furie',
      duration: '1h 38m',
      rating: '4.0',
      watchProgress: '00:12:15 / 01:38:00',
      lastWatched: '5d ago',
    ),
    MovieModel(
      'assets/images/poster6.jpg',
      name: 'Joker',
      duration: '2h 2m',
      rating: '4.2',
      watchProgress: '01:45:30 / 02:02:00',
      lastWatched: '1w ago',
    ),
  ];

  final List<MovieModel> moviesDownload = [
    MovieModel(
      'assets/images/poster4.jpg',
      name: 'A Quiet Place 2',
      duration: '1h 37m',
      rating: '4.2',
      downloadProgress: 0.65,
      downloadStatus: 'Downloading',
      downloadSize: '2.1GB',
    ),
    MovieModel(
      'assets/images/poster3.png',
      name: 'The Flash',
      duration: '8 seasons',
      rating: '4.0',
      downloadProgress: 1.0,
      downloadStatus: 'Downloaded',
      downloadSize: '4.8GB',
      downloadTime: '3h ago',
    ),
    MovieModel(
      'assets/images/poster5.jpg',
      name: 'Money Heist',
      duration: '5 seasons',
      rating: '8.2',
      downloadProgress: 0.0,
      downloadStatus: 'Queued',
      downloadSize: '6.5GB',
    ),
    MovieModel(
      'assets/images/poster8.jpg',
      name: 'Furie',
      duration: '1h 38m',
      rating: '4.0',
      downloadProgress: 0.32,
      downloadStatus: 'Downloading',
      downloadSize: '1.8GB',
    ),
    MovieModel(
      'assets/images/poster6.jpg',
      name: 'Joker',
      duration: '2h 2m',
      rating: '4.2',
      downloadProgress: 0.89,
      downloadStatus: 'Downloading',
      downloadSize: '2.4GB',
    ),
    MovieModel(
      'assets/images/poster7.jpg',
      name: 'Leo',
      duration: '2h 44m',
      rating: '7.2',
      downloadProgress: 0.0,
      downloadStatus: 'Failed',
      downloadSize: '3.2GB',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Watching and Downloaded
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.red,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    border: null,
                    color:
                        AppColor.primary, // Background color for selected tab
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        width: MediaQuery.of(context).copyWith().size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColor.primary), // Border color
                        ),
                        child: const Center(child: Text('Watching')),
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: MediaQuery.of(context).copyWith().size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColor.primary), // Border color
                        ),
                        child: const Center(child: Text('Downloaded')),
                      ),
                    ),
                  ],
                ),
                AppSpacing.h20,
                Expanded(
                  child: TabBarView(
                    children: [
                      /*ListView.builder(
                        itemCount: MovieData.movies3.length,
                        itemBuilder: (context, i) {
                          return HistoryWatchCard(
                              image: MovieData.movies3[i].image,
                              title: MovieData.movies3[i].name);
                        },
                      ),*/
                      ListView.builder(
                        itemCount: watchingHistory.length,
                        itemBuilder: (context, index) {
                          return HistoryWatchCard(
                            movie: watchingHistory[index],
                          );
                        },
                      ),
                      ListView.builder(
                          itemCount: moviesDownload.length,
                          itemBuilder: (context, i) {
                            return DownloadedMovieCard(
                                movie: moviesDownload[i]);
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
