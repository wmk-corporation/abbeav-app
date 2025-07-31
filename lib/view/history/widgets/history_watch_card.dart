import 'package:abbeav/models/movie_model.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/view/movie_details_screen/screens/movie_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryWatchCard extends StatefulWidget {
  const HistoryWatchCard({
    super.key,
    required this.movie,
  });

  final MovieModel movie;

  @override
  State<HistoryWatchCard> createState() => _HistoryWatchCardState();
}

class _HistoryWatchCardState extends State<HistoryWatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Convertir le temps de visionnage en pourcentage
    final progress = _calculateWatchProgress();
    _progressAnimation = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _animationController.forward();
  }

  double _calculateWatchProgress() {
    try {
      final parts = widget.movie.watchProgress?.split('/') ?? ['0', '0'];
      final current = _timeToSeconds(parts[0]);
      final total = _timeToSeconds(parts[1]);
      return total > 0 ? current / total : 0;
    } catch (e) {
      return 0;
    }
  }

  int _timeToSeconds(String time) {
    final parts = time.split(':');
    if (parts.length == 3) {
      return int.parse(parts[0]) * 3600 +
          int.parse(parts[1]) * 60 +
          int.parse(parts[2]);
    } else if (parts.length == 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }

  String _formatLastWatched(String? time) {
    return time != null ? 'Last watched: $time' : 'Not watched yet';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[900]!.withOpacity(0.5),
                Colors.grey[850]!.withOpacity(0.3),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Conteneur de l'image avec progression
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsScreen(
                                    image: widget.movie.image,
                                  ),
                                ),
                              );*/
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width * 0.36,
                              // height: 80,
                              //width: 150,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(widget.movie.image),
                                  alignment: Alignment.topCenter,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/icon_play.svg',
                                  width: 28,
                                  height: 28,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          // Barre de progression du visionnage
                          Positioned(
                            bottom: 2,
                            left: 0,
                            right: 0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: AppColor.primary.withOpacity(0.3),
                                //color: Colors.black.withOpacity(0.5),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: AppColor.secondary,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColor.primary.withOpacity(0.7),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.w15,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.movie.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.movie.watchProgress ?? '00:00 / 00:00',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatLastWatched(widget.movie.lastWatched),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/images/icon_play.svg', // Nouvelle icône pour continuer
                    width: 24,
                    height: 24,
                    color: AppColor.secondary,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/view/movie_details_screen/screens/movie_details_screen.dart';

class HistoryWatchCard extends StatelessWidget {
  const HistoryWatchCard({
    super.key,
    required this.image,
    required this.title,
  });
  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailsScreen(image: image)));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 80,
                width: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        image,
                      ),
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 35,
                  ),
                ),
              ),
            ),
            AppSpacing.w20,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  '00:32:52 / 02:25:00',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Text(
                  'Last Watched: 2h ago',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            )
          ],
        ),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey,
        )
      ],
    );
  }
}*/
