import 'package:cloud_firestore/cloud_firestore.dart';

class DownloadModel {
  final String id;
  final String movieId;
  final String userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double progress; // 0.0 to 1.0
  final String status; // 'queued', 'downloading', 'completed', 'failed'
  final String? error;
  final String? offlineVideoPath;
  final int? videoSize; // en bytes
  final String? videoQuality;
  final DateTime?
      expiresAt; // Date d'expiration (30 jours après le téléchargement)
  final bool isPaused;

  DownloadModel({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    required this.progress,
    required this.status,
    this.error,
    this.offlineVideoPath,
    this.videoSize,
    this.videoQuality,
    this.expiresAt,
    this.isPaused = false,
  });

  factory DownloadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DownloadModel(
      id: doc.id,
      movieId: data['movieId'],
      userId: data['userId'],
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      progress: data['progress']?.toDouble() ?? 0.0,
      status: data['status'],
      error: data['error'],
      offlineVideoPath: data['offlineVideoPath'],
      videoSize: data['videoSize'],
      videoQuality: data['videoQuality'],
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      isPaused: data['isPaused'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieId': movieId,
      'userId': userId,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'progress': progress,
      'status': status,
      'error': error,
      'offlineVideoPath': offlineVideoPath,
      'videoSize': videoSize,
      'videoQuality': videoQuality,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isPaused': isPaused,
    };
  }

  String get formattedStatus {
    switch (status) {
      case 'queued':
        return 'En attente';
      case 'downloading':
        return 'Téléchargement (${(progress * 100).toStringAsFixed(0)}%)';
      case 'completed':
        return 'Terminé';
      case 'failed':
        return 'Échec';
      default:
        return status;
    }
  }

  String get formattedFileSize {
    if (videoSize == null) return 'Inconnu';
    if (videoSize! < 1024) return '$videoSize B';
    if (videoSize! < 1048576)
      return '${(videoSize! / 1024).toStringAsFixed(1)} KB';
    return '${(videoSize! / 1048576).toStringAsFixed(1)} MB';
  }

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  DownloadModel copyWith({
    String? id,
    String? movieId,
    String? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progress,
    String? status,
    String? error,
    String? offlineVideoPath,
    int? videoSize,
    String? videoQuality,
    DateTime? expiresAt,
    bool? isPaused,
  }) {
    return DownloadModel(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
      offlineVideoPath: offlineVideoPath ?? this.offlineVideoPath,
      videoSize: videoSize ?? this.videoSize,
      videoQuality: videoQuality ?? this.videoQuality,
      expiresAt: expiresAt ?? this.expiresAt,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
