import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import '../models/download_model.dart';
import '../models/movies_model.dart';

class DownloadController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> init() async {
    //await FlutterDownloader.initialize();
  }

  Future<void> startDownload(MovieModel movie) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final existingDownload = await _getActiveDownload(userId, movie.id);
    if (existingDownload != null) {
      throw Exception('Movie already downloaded');
    }

    final downloadRef = await _firestore.collection('downloads').add({
      'movieId': movie.id,
      'userId': userId,
      'startedAt': FieldValue.serverTimestamp(),
      'progress': 0.0,
      'status': 'queued',
      'videoQuality': '720p',
      'expiresAt': DateTime.now().add(const Duration(days: 30)),
      'isPaused': false,
    });

    await _updateUserDownloads(userId, movie.id);
    await _executeDownload(downloadRef.id, movie);
  }

  Future<DownloadModel?> _getActiveDownload(
      String userId, String movieId) async {
    final snapshot = await _firestore
        .collection('downloads')
        .where('userId', isEqualTo: userId)
        .where('movieId', isEqualTo: movieId)
        .where('status', isEqualTo: 'completed')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final download = DownloadModel.fromFirestore(snapshot.docs.first);
      return download.isExpired ? null : download;
    }
    return null;
  }

  Future<void> _updateUserDownloads(String userId, String movieId) async {
    await _firestore.collection('users').doc(userId).update({
      'downloadedMovies': FieldValue.arrayUnion([movieId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _executeDownload(String downloadId, MovieModel movie) async {
    try {
      await _firestore.collection('downloads').doc(downloadId).update({
        'status': 'downloading',
      });

      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/abbeav_offline_${movie.id}.mp4';

      final taskId = await FlutterDownloader.enqueue(
        url: movie.videoUrl,
        savedDir: directory.path,
        fileName: 'abbeav_offline_${movie.id}.mp4',
        showNotification: true,
        openFileFromNotification: false,
      );

      await _firestore.collection('downloads').doc(downloadId).update({
        'taskId': taskId,
        'offlineVideoPath': savePath,
      });

      FlutterDownloader.registerCallback((id, status, progress) {
        if (id == taskId) {
          _updateDownloadProgress(
            downloadId: downloadId,
            status: status,
            progress: progress,
          );
        }
      });
    } catch (e) {
      await _firestore.collection('downloads').doc(downloadId).update({
        'status': 'failed',
        'error': e.toString(),
      });
      rethrow;
    }
  }

  Future<void> _updateDownloadProgress({
    required String downloadId,
    required int status,
    required int progress,
  }) async {
    String downloadStatus;

    switch (status) {
      case 2: // DownloadTaskStatus.running
        downloadStatus = 'downloading';
        break;
      case 3: // DownloadTaskStatus.complete
        downloadStatus = 'completed';
        break;
      case 4: // DownloadTaskStatus.failed
        downloadStatus = 'failed';
        break;
      case 5: // DownloadTaskStatus.canceled
        downloadStatus = 'canceled';
        break;
      case 6: // DownloadTaskStatus.paused
        downloadStatus = 'paused';
        break;
      case 1: // DownloadTaskStatus.enqueued
      default:
        downloadStatus = 'queued';
        break;
    }

    final updates = <String, dynamic>{
      'status': downloadStatus,
      'progress': progress / 100,
      'isPaused': status == 6, // DownloadTaskStatus.paused
    };

    if (status == 3) {
      // DownloadTaskStatus.complete
      updates['completedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('downloads').doc(downloadId).update(updates);
  }

  Stream<List<DownloadModel>> getUserDownloads(String userId) {
    return _firestore
        .collection('downloads')
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DownloadModel.fromFirestore(doc))
            .toList());
  }

  Future<void> resumeDownload(String downloadId) async {
    final doc = await _firestore.collection('downloads').doc(downloadId).get();
    final taskId = doc['taskId'];

    if (taskId == null) throw Exception('Task ID not found');

    await FlutterDownloader.resume(taskId: taskId);
    await _firestore.collection('downloads').doc(downloadId).update({
      'status': 'downloading',
      'isPaused': false,
    });
  }

  Future<void> pauseDownload(String downloadId) async {
    final doc = await _firestore.collection('downloads').doc(downloadId).get();
    final taskId = doc['taskId'];

    if (taskId == null) throw Exception('Task ID not found');

    await FlutterDownloader.pause(taskId: taskId);
    await _firestore.collection('downloads').doc(downloadId).update({
      'status': 'paused',
      'isPaused': true,
    });
  }

  Future<void> cancelDownload(
      String downloadId, String userId, String movieId) async {
    final doc = await _firestore.collection('downloads').doc(downloadId).get();
    final taskId = doc['taskId'];
    final offlinePath = doc['offlineVideoPath'];

    final batch = _firestore.batch();
    final downloadRef = _firestore.collection('downloads').doc(downloadId);
    final userRef = _firestore.collection('users').doc(userId);

    batch.delete(downloadRef);
    batch.update(userRef, {
      'downloadedMovies': FieldValue.arrayRemove([movieId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    if (taskId != null) {
      await FlutterDownloader.cancel(taskId: taskId);
    }

    if (offlinePath != null) {
      try {
        final file = File(offlinePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }

  Future<bool> isMovieDownloaded(String userId, String movieId) async {
    final download = await _getActiveDownload(userId, movieId);
    return download != null;
  }

  Future<void> cleanupExpiredDownloads(String userId) async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('downloads')
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isLessThan: now)
        .get();

    for (final doc in snapshot.docs) {
      final download = DownloadModel.fromFirestore(doc);
      await cancelDownload(download.id, userId, download.movieId);
    }
  }

  Future<String?> getOfflineMoviePath(String userId, String movieId) async {
    final download = await _getActiveDownload(userId, movieId);
    return download?.offlineVideoPath;
  }
}
