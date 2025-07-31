import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? heroTag;
  final bool fullScreen;

  const VideoPlayerScreen({
    required this.videoUrl,
    this.heroTag,
    this.fullScreen = false,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isFullScreen = false;
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    _isFullScreen = widget.fullScreen;
    _initializePlayer();
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
        ..addListener(() {
          if (_videoPlayerController.value.hasError && mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          }
        });

      await _videoPlayerController.initialize().catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
        //debugPrint('Video player initialization error: $error');
      });

      if (!mounted) return;

      if (!_videoPlayerController.value.hasError) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          allowMuting: true,
          showControlsOnInitialize: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColor.primary,
            handleColor: AppColor.primary,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey.withOpacity(0.5),
          ),
          cupertinoProgressColors: ChewieProgressColors(
            playedColor: AppColor.primary,
            handleColor: AppColor.primary,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey.withOpacity(0.5),
          ),
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: CupertinoActivityIndicator(
                radius: 15,
                color: AppColor.primary,
              ),
            ),
          ),
          customControls: _buildCustomControls(),
          overlay: _buildOverlay(),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Text(
                    'Échec du chargement',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    color: AppColor.primary,
                    onPressed: _retryLoading,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          },
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      //debugPrint('Video player initialization error: $e');
    }
  }

  Widget _buildCustomControls() {
    return CupertinoControls(
      backgroundColor: Colors.black.withOpacity(0.7),
      iconColor: Colors.white,
      showPlayButton: true,
    );
  }

  Widget _buildOverlay() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(_isFullScreen ? 0.8 : 0.5),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(_isFullScreen ? 0.8 : 0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            if (!_isFullScreen)
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      Navigator.pop(context);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoUrl: widget.videoUrl,
            heroTag: widget.heroTag,
            fullScreen: true,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  void _retryLoading() {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
    _initializePlayer();
  }

  void _toggleControls() {
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
        if (_showControls) {
          _startHideControlsTimer();
        }
      });
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          if (_isFullScreen) {
            _toggleFullScreen();
            return false;
          }
          return true;
        },
        child: GestureDetector(
          onTap: _toggleControls,
          child: _isFullScreen
              ? _buildFullScreenPlayer()
              : SafeArea(child: _buildNormalPlayer()),
        ),
      ),
    );
  }

  Widget _buildNormalPlayer() {
    return Stack(
      children: [
        if (_isLoading)
          Center(
            child: CupertinoActivityIndicator(
              radius: 15,
              color: AppColor.primary,
            ),
          )
        else if (_hasError)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 20),
                Text(
                  'Échec du chargement',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  color: AppColor.primary,
                  onPressed: _retryLoading,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          )
        else
          Hero(
            tag: widget.heroTag ?? 'video-player',
            child: Chewie(
              controller: _chewieController ??
                  ChewieController(
                    videoPlayerController: _videoPlayerController,
                    autoPlay: false,
                    customControls: _buildCustomControls(),
                    errorBuilder: (context, errorMessage) {
                      return Center(
                        child: Text(
                          'Échec de l\'initialisation',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildFullScreenPlayer() {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          ),
        ),
        if (_showControls) _buildOverlay(),
        if (_isLoading)
          Center(
            child: CupertinoActivityIndicator(
              radius: 15,
              color: AppColor.primary,
            ),
          ),
      ],
    );
  }
}
