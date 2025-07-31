import 'package:abbeav/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Modèle étendu avec les informations de téléchargement
// Liste mise à jour avec les états de téléchargement
final List<MovieModel> movies3 = [
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
    downloadProgress: 10.0,
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

class DownloadedMovieCard extends StatefulWidget {
  const DownloadedMovieCard({
    super.key,
    required this.movie,
    required this.onDelete,
    required this.onRetryDownload,
    required this.onPlay,
  });

  final MovieModel movie;
  final Function(String) onDelete;
  final Function(String) onRetryDownload;
  final Function(String) onPlay;

  @override
  State<DownloadedMovieCard> createState() => _DownloadedMovieCardState();
}

class _DownloadedMovieCardState extends State<DownloadedMovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.movie.downloadProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    if (widget.movie.downloadStatus == 'Downloading') {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant DownloadedMovieCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movie.downloadProgress != oldWidget.movie.downloadProgress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.movie.downloadProgress,
        end: widget.movie.downloadProgress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getProgressColor() {
    if (widget.movie.downloadStatus == 'Failed') return Colors.redAccent;
    if (widget.movie.downloadProgress < 0.3) return Colors.red[400]!;
    if (widget.movie.downloadProgress < 0.6) return Colors.orange[400]!;
    if (widget.movie.downloadProgress < 0.9) return Colors.yellow[600]!;
    if (widget.movie.downloadProgress < 1.0) return Colors.lightGreen[400]!;
    return AppColor.secondary;
  }

  String _getStatusText() {
    switch (widget.movie.downloadStatus) {
      case 'Downloading':
        return 'Downloading: ${(widget.movie.downloadProgress * 100).toStringAsFixed(1)}%';
      case 'Queued':
        return 'Queued for download';
      case 'Failed':
        return 'Download failed - Tap to retry';
      default:
        return 'Downloaded: ${widget.movie.downloadTime}';
    }
  }

  void _showToast(String message, IconData icon, {bool isError = false}) {
    FToast fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isError ? Colors.red[800] : Colors.green[800],
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white),
              AppSpacing.w10,
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          )),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);

    try {
      await widget.onDelete(widget.movie.id);
      _showToast('${widget.movie.name} deleted successfully', Icons.check);
    } catch (e) {
      _showToast('Failed to delete ${widget.movie.name}', Icons.error,
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _handleRetryDownload() async {
    if (widget.movie.downloadStatus == 'Failed') {
      try {
        await widget.onRetryDownload(widget.movie.id);
        _showToast('Download restarted for ${widget.movie.name}', Icons.check);
      } catch (e) {
        _showToast('Failed to restart download', Icons.error, isError: true);
      }
    }
  }

  void _handlePlay() {
    if (widget.movie.downloadProgress < 1.0) {
      _showToast('Download not completed yet', Icons.error, isError: true);
      return;
    }
    widget.onPlay(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _handleRetryDownload,
          child: Container(
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
                        // Image container with progress
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: _handlePlay,
                              child: Container(
                                height: 80,
                                width: 120,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(widget.movie.image),
                                    alignment: Alignment.topCenter,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: widget.movie.downloadProgress < 1.0
                                      ? null
                                      : SvgPicture.asset(
                                          'assets/images/icon_play.svg',
                                          width: 28,
                                          height: 28,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                ),
                              ),
                            ),
                            // Progress bar
                            Positioned(
                              bottom: 2,
                              left: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 3,
                                margin: EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: _getProgressColor(),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getProgressColor()
                                              .withOpacity(0.7),
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
                                widget.movie.duration,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber[400],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.movie.rating,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.movie.downloadSize,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 120,
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getProgressColor(),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  _isDeleting
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _handleDelete,
                          icon: SvgPicture.asset(
                            'assets/images/icon_trash.svg',
                            width: 21,
                            height: 21,
                            color: Colors.grey[400],
                          ),
                          padding: EdgeInsets.zero,
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
