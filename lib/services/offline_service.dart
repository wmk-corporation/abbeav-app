// offline_service.dart
import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/movies_model.dart';
import '../models/download_model.dart';

class OfflineService {
  static const _encryptionKey = 'your_32_byte_encryption_key_here';
  static const _encryptionIV = 'your_16_byte_iv_here';

  // Initialiser le service
  static Future<void> init() async {
    await FlutterDownloader.initialize();
  }

  // Télécharger un film pour le visionnage offline
  static Future<DownloadModel> downloadMovie(MovieModel movie) async {
    // Vérifier si le film est déjà téléchargé
    if (await isMovieDownloaded(movie.id)) {
      throw Exception('Movie already downloaded');
    }

    // Obtenir le répertoire de stockage
    final directory = await getApplicationDocumentsDirectory();
    final encryptedPath = '${directory.path}/abbeav_${movie.id}.enc';

    // Configurer le chiffrement
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    final iv = encrypt.IV.fromUtf8(_encryptionIV);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    // Télécharger et chiffrer le fichier
    final file = File(encryptedPath);
    final sink = file.openWrite();

    // Télécharger depuis Firebase Storage
    final ref = FirebaseStorage.instance.refFromURL(movie.videoUrl);
    final downloadTask = ref.writeToFile(file);

    // Suivre la progression
    downloadTask.snapshotEvents.listen((taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          // Mettre à jour la progression dans Firestore
          break;
        case TaskState.paused:
          // Mettre à jour le statut
          break;
        case TaskState.success:
          // Finaliser le téléchargement
          await sink.close();
          break;
        case TaskState.canceled:
          await sink.close();
          await file.delete();
          break;
        case TaskState.error:
          await sink.close();
          await file.delete();
          break;
      }
    });

    // Créer et retourner le modèle de téléchargement
    return DownloadModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      movieId: movie.id,
      userId: 'current_user_id', // À remplacer par l'ID réel
      startedAt: DateTime.now(),
      progress: 0.0,
      status: 'downloading',
      offlineVideoPath: encryptedPath,
      videoSize: await ref.getMetadata().then((meta) => meta.size),
      expiresAt: DateTime.now().add(Duration(days: 30)),
    );
  }

  // Vérifier si un film est téléchargé
  static Future<bool> isMovieDownloaded(String movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/abbeav_${movieId}.enc');
    return await file.exists();
  }

  // Lire un film offline
  static Future<File> getOfflineMovie(String movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final encryptedPath = '${directory.path}/abbeav_${movieId}.enc';

    // Vérifier si le fichier existe
    final file = File(encryptedPath);
    if (!await file.exists()) {
      throw Exception('Movie not downloaded');
    }

    return file;
  }

  // Supprimer un film offline
  static Future<void> deleteOfflineMovie(String movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/abbeav_${movieId}.enc');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Nettoyer les films expirés
  static Future<void> cleanupExpiredMovies() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().whereType<File>();

    for (final file in files) {
      if (file.path.endsWith('.enc')) {
        final stat = await file.stat();
        final modified = stat.modified;
        if (modified.add(Duration(days: 30)).isBefore(DateTime.now())) {
          await file.delete();
        }
      }
    }
  }
}
