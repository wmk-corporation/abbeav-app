/*import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:abbeav/models/movies_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Appeler votre fonction d'upload après l'initialisation
  //await uploadMovieWithStructure();
}

Future<void> uploadMovieWithStructure(String movieId, String basePath) async {
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;

  // 1. Upload des assets vers Firebase Storage
  final urls = await uploadMovieAssets(movieId, basePath);

  // 2. Trouver le modèle correspondant dans allMovies
  final movie = allMovies.firstWhere((m) => m.id == movieId);

  // 3. Mettre à jour le modèle avec les URLs
  final updatedMovie = movie.copyWith(
    thumbnailUrl: urls['thumbnail'] ?? movie.thumbnailUrl,
    videoUrl: urls['video'] ?? movie.videoUrl,
    galleryImages: urls['gallery'] ?? movie.galleryImages,
    cast: movie.cast?.map((cast) {
      final photoUrl = urls['cast_${cast.id}'];
      return photoUrl != null ? cast.copyWith(photoUrl: photoUrl) : cast;
    }).toList(),
  );

  // 4. Sauvegarder dans Firestore
  await firestore.collection('movies').doc(movieId).set(updatedMovie.toMap());
}

Future<Map<String, dynamic>> uploadMovieAssets(
    String movieId, String basePath) async {
  final storage = FirebaseStorage.instance;
  final urls = <String, dynamic>{};
  final storagePath = 'movies/$movieId';
  final localPath = '$basePath$movieId/';

  // 1. Upload thumbnail (dans images/)
  final imagesDir = Directory('${localPath}images');
  if (await imagesDir.exists()) {
    final thumbnailFiles = await imagesDir
        .list()
        .where((f) => f.path.toLowerCase().contains('thumbnail'))
        .where((f) => ['.jpg', '.jpeg', '.png']
            .any((ext) => f.path.toLowerCase().endsWith(ext)))
        .toList();

    if (thumbnailFiles.isNotEmpty) {
      final thumbnailFile = File(thumbnailFiles.first.path);
      final ext = extension(thumbnailFile.path);
      final thumbnailRef = storage.ref('$storagePath/images/thumbnail$ext');
      await thumbnailRef.putFile(thumbnailFile);
      urls['thumbnail'] = await thumbnailRef.getDownloadURL();
    }
  }

  // 2. Upload vidéo (dans videos/)
  final videosDir = Directory('${localPath}videos');
  if (await videosDir.exists()) {
    final videoFiles = await videosDir
        .list()
        .where((f) => f.path.toLowerCase().endsWith('.mp4'))
        .toList();

    if (videoFiles.isNotEmpty) {
      final videoFile = File(videoFiles.first.path);
      final videoRef =
          storage.ref('$storagePath/videos/${basename(videoFile.path)}');
      await videoRef.putFile(videoFile);
      urls['video'] = await videoRef.getDownloadURL();
    }
  }

  // 3. Upload gallery images (dans gallery/)
  final galleryUrls = <String>[];
  final galleryDir = Directory('${localPath}gallery');
  if (await galleryDir.exists()) {
    final galleryFiles = await galleryDir
        .list()
        .where((f) => ['.jpg', '.jpeg', '.png']
            .any((ext) => f.path.toLowerCase().endsWith(ext)))
        .toList();

    for (var file in galleryFiles) {
      final fileName = basename(file.path);
      final ext = extension(file.path);
      final galleryRef =
          storage.ref('$storagePath/gallery/${fileName.split('.').first}$ext');
      await galleryRef.putFile(File(file.path));
      galleryUrls.add(await galleryRef.getDownloadURL());
    }
  }
  urls['gallery'] = galleryUrls;

  // 4. Upload cast images (dans cast/)
  final castDir = Directory('${localPath}cast');
  if (await castDir.exists()) {
    final castFiles = await castDir
        .list()
        .where((f) => ['.jpg', '.jpeg', '.png']
            .any((ext) => f.path.toLowerCase().endsWith(ext)))
        .toList();

    for (var file in castFiles) {
      final fileName = basename(file.path);
      final ext = extension(file.path);
      final castId = fileName.split('.').first;
      final castRef = storage.ref('$storagePath/cast/$castId$ext');
      await castRef.putFile(File(file.path));
      urls['cast_$castId'] = await castRef.getDownloadURL();
    }
  }

  return urls;
}*/

/*Future<void> uploadAllMovies() async {
  try {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    WriteBatch batch = firestore.batch();
    List<Future> uploadFutures = [];

    for (var movie in allMovies) {
      uploadFutures.add(uploadMovieAssets(movie.id, storage).then((urls) {
        final updatedMovie = movie.copyWith(
          thumbnailUrl: urls['thumbnail'],
          videoUrl: urls['video'],
          galleryImages: urls['gallery'],
        );

        // Mise à jour des photos des acteurs
        if (movie.cast != null) {
          updatedMovie.cast = movie.cast!.map((cast) {
            final photoUrl = urls['cast_${cast.id}'];
            return photoUrl != null
                ? CastModel(
                    id: cast.id,
                    name: cast.name,
                    photoUrl: photoUrl,
                    role: cast.role,
                    bio: cast.bio,
                  )
                : cast;
          }).toList();
        }

        final docRef = firestore.collection('movies').doc(movie.id);
        batch.set(docRef, updatedMovie.toMap());
      }));
    }

    await Future.wait(uploadFutures);
    await batch.commit();
    print('Tous les films et assets ont été uploadés avec succès!');
  } catch (e) {
    print('Erreur lors de l\'upload: $e');
  }
}*/

/*Future<void> uploadAllMovies() async {
  try {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    WriteBatch batch = firestore.batch();
    List<Future> uploadFutures = [];

    for (var movie in allMovies) {
      uploadFutures.add(uploadMovieAssets(movie.id, storage).then((urls) async {
        // Créer une copie mise à jour du film avec les URLs
        final updatedMovie = movie.copyWith(
          thumbnailUrl: urls['thumbnail'] ?? movie.thumbnailUrl,
          videoUrl: urls['video'] ?? movie.videoUrl,
          galleryImages: urls['gallery'] ?? movie.galleryImages,
        );

        // Mise à jour des photos des acteurs
        if (movie.cast != null) {
          updatedMovie.cast = movie.cast!.map((cast) {
            final photoUrl = urls['cast_${cast.id}'];
            return photoUrl != null ? cast.copyWith(photoUrl: photoUrl) : cast;
          }).toList();
        }

        final docRef = firestore.collection('movies').doc(movie.id);
        batch.set(docRef, updatedMovie.toMap());
      }));
    }

    await Future.wait(uploadFutures);
    await batch.commit();
    print('Tous les films et assets ont été uploadés avec succès!');
  } catch (e) {
    print('Erreur lors de l\'upload: $e');
    rethrow; // Important pour que le SnackBar puisse afficher l'erreur
  }
}*/

/*Future<void> uploadAllMovies() async {
  try {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    WriteBatch batch = firestore.batch();
    List<Future> uploadFutures = [];

    for (var movie in allMovies) {
      uploadFutures.add(uploadMovieAssets(movie.id, storage).then((urls) async {
        // Mise à jour des photos des acteurs
        final updatedCast = movie.cast?.map((cast) {
          final photoUrl = urls['cast_${cast.id}'];
          return photoUrl != null ? cast.copyWith(photoUrl: photoUrl) : cast;
        }).toList();

        // Créer une copie mise à jour du film avec TOUTES les modifications
        final updatedMovie = movie.copyWith(
          thumbnailUrl: urls['thumbnail'] ?? movie.thumbnailUrl,
          videoUrl: urls['video'] ?? movie.videoUrl,
          galleryImages: urls['gallery'] ?? movie.galleryImages,
          cast: updatedCast ?? movie.cast, // On passe la liste mise à jour ici
        );

        final docRef = firestore.collection('movies').doc(movie.id);
        batch.set(docRef, updatedMovie.toMap());
      }));
    }

    await Future.wait(uploadFutures);
    await batch.commit();
    print('Tous les films et assets ont été uploadés avec succès!');
  } catch (e) {
    print('Erreur lors de l\'upload: $e');
    rethrow;
  }
}*/

/*Future<Map<String, dynamic>> uploadMovieAssets(
    String movieId, FirebaseStorage storage) async {
  final Map<String, dynamic> urls = {};
  final storagePath = 'movies/$movieId';

  // 1. Upload thumbnail
  final imagesDir = Directory('assets/movies/$movieId/images');
  if (await imagesDir.exists()) {
    final thumbnailFiles = await imagesDir
        .list()
        .where((f) => f.path.toLowerCase().contains('thumbnail'))
        .where((f) => ['.jpg', '.jpeg', '.png']
            .any((ext) => f.path.toLowerCase().endsWith(ext)))
        .toList();

    if (thumbnailFiles.isNotEmpty) {
      final thumbnailFile = File(thumbnailFiles.first.path);
      final ext = extension(thumbnailFile.path);
      final thumbnailRef = storage.ref('$storagePath/images/thumbnail$ext');
      await thumbnailRef.putFile(thumbnailFile);
      urls['thumbnail'] = await thumbnailRef.getDownloadURL();
    }
  }

  // 2. Upload vidéo
  final videosDir = Directory('assets/movies/$movieId/videos');
  if (await videosDir.exists()) {
    final videoFiles = await videosDir
        .list()
        .where((f) => f.path.toLowerCase().endsWith('.mp4'))
        .toList();

    if (videoFiles.isNotEmpty) {
      final videoFile = File(videoFiles.first.path);
      final videoRef =
          storage.ref('$storagePath/videos/${basename(videoFile.path)}');
      await videoRef.putFile(videoFile);
      urls['video'] = await videoRef.getDownloadURL();
    }
  }

  // 3. Upload gallery images
  urls['gallery'] = [];
  final galleryDir = Directory('assets/movies/$movieId/gallery');
  if (await galleryDir.exists()) {
    final galleryFiles = await galleryDir
        .list()
        .where((f) => ['.jpg', '.jpeg', '.png']
            .any((ext) => f.path.toLowerCase().endsWith(ext)))
        .toList();

    for (var file in galleryFiles) {
      final fileName = basename(file.path);
      final ext = extension(file.path);
      final galleryRef =
          storage.ref('$storagePath/gallery/${fileName.split('.').first}$ext');
      await galleryRef.putFile(File(file.path));
      urls['gallery'].add(await galleryRef.getDownloadURL());
    }
  }

  // 4. Upload cast images
  final castDir = Directory('assets/movies/$movieId/cast');
  if (await castDir.exists()) {
    final castFiles = await castDir
        .list()
        .where((f) => ['.jpg', '.jpeg', '.png']
            .any((ext) => f.path.toLowerCase().endsWith(ext)))
        .toList();

    for (var file in castFiles) {
      final fileName = basename(file.path);
      final ext = extension(file.path);
      final castId = fileName.split('.').first;
      final castRef = storage.ref('$storagePath/cast/$castId$ext');
      await castRef.putFile(File(file.path));
      urls['cast_$castId'] = await castRef.getDownloadURL();
    }
  }

  return urls;
}*/

/*Future<Map<String, dynamic>> uploadMovieAssets(
    String movieId, FirebaseStorage storage) async {
  final Map<String, dynamic> urls = {};
  final storagePath = 'movies/$movieId';

  try {
    // 1. Upload thumbnail
    final imagesDir = Directory('assets/movies/$movieId/images');
    if (await imagesDir.exists()) {
      final thumbnailFiles = await imagesDir
          .list()
          .where((f) => f.path.toLowerCase().contains('thumbnail'))
          .where((f) => ['.jpg', '.jpeg', '.png']
              .any((ext) => f.path.toLowerCase().endsWith(ext)))
          .toList();

      if (thumbnailFiles.isNotEmpty) {
        final thumbnailFile = File(thumbnailFiles.first.path);
        final ext = extension(thumbnailFile.path);
        final thumbnailRef = storage.ref('$storagePath/images/thumbnail$ext');
        await thumbnailRef.putFile(thumbnailFile);
        urls['thumbnail'] = await thumbnailRef.getDownloadURL();
      }
    }

    // 2. Upload vidéo
    final videosDir = Directory('assets/movies/$movieId/videos');
    if (await videosDir.exists()) {
      final videoFiles = await videosDir
          .list()
          .where((f) => f.path.toLowerCase().endsWith('.mp4'))
          .toList();

      if (videoFiles.isNotEmpty) {
        final videoFile = File(videoFiles.first.path);
        final videoRef =
            storage.ref('$storagePath/videos/${basename(videoFile.path)}');
        await videoRef.putFile(videoFile);
        urls['video'] = await videoRef.getDownloadURL();
      }
    }

    // 3. Upload gallery images
    final galleryUrls = <String>[];
    final galleryDir = Directory('assets/movies/$movieId/gallery');
    if (await galleryDir.exists()) {
      final galleryFiles = await galleryDir
          .list()
          .where((f) => ['.jpg', '.jpeg', '.png']
              .any((ext) => f.path.toLowerCase().endsWith(ext)))
          .toList();

      for (var file in galleryFiles) {
        final fileName = basename(file.path);
        final ext = extension(file.path);
        final galleryRef = storage
            .ref('$storagePath/gallery/${fileName.split('.').first}$ext');
        await galleryRef.putFile(File(file.path));
        galleryUrls.add(await galleryRef.getDownloadURL());
      }
    }
    urls['gallery'] = galleryUrls;

    // 4. Upload cast images
    final castDir = Directory('assets/movies/$movieId/cast');
    if (await castDir.exists()) {
      final castFiles = await castDir
          .list()
          .where((f) => ['.jpg', '.jpeg', '.png']
              .any((ext) => f.path.toLowerCase().endsWith(ext)))
          .toList();

      for (var file in castFiles) {
        final fileName = basename(file.path);
        final ext = extension(file.path);
        final castId = fileName.split('.').first;
        final castRef = storage.ref('$storagePath/cast/$castId$ext');
        await castRef.putFile(File(file.path));
        urls['cast_$castId'] = await castRef.getDownloadURL();
      }
    }

    return urls;
  } catch (e) {
    print('Erreur lors de l\'upload des assets pour $movieId: $e');
    rethrow;
  }
}

String extension(String path) {
  final ext = path.split('.').last.toLowerCase();
  return '.$ext';
}*/

// [Vos modèles MovieModel restent inchangés...]

/*import 'dart:io';
import 'package:abbeav/models/movies_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> uploadAllMovies() async {
  WriteBatch batch = firestore.batch();
  List<Future> uploadFutures = [];

  for (var movie in allMovies) {
    uploadFutures.add(uploadMovieAssets(movie.id).then((urls) {
      final updatedMovie = movie.copyWith(
        thumbnailUrl: urls['thumbnail'],
        videoUrl: urls['video'],
        galleryImages: urls['gallery'],
        cast: movie.cast
            ?.map((cast) => cast.copyWith(photoUrl: urls['cast_${cast.id}']))
            .toList(),
      );

      final docRef = firestore.collection('movies').doc(movie.id);
      batch.set(docRef, updatedMovie.toMap());
    }));
  }

  await Future.wait(uploadFutures);
  await batch.commit();
  print('Tous les films et assets ont été uploadés avec succès!');
}

Future<Map<String, dynamic>> uploadMovieAssets(String movieId) async {
  final Map<String, dynamic> urls = {};
  final storagePath = 'movies/$movieId';

  // 1. Upload thumbnail (gère plusieurs extensions)
  final imagesDir = Directory('assets/movies/$movieId/images');
  if (await imagesDir.exists()) {
    final thumbnailFiles = await imagesDir
        .list()
        .where((f) => f.path.toLowerCase().contains('thumbnail.'))
        .where((f) =>
            f.path.toLowerCase().endsWith('.jpg') ||
            f.path.toLowerCase().endsWith('.jpeg') ||
            f.path.toLowerCase().endsWith('.png'))
        .toList();

    if (thumbnailFiles.isNotEmpty) {
      final thumbnailFile = File(thumbnailFiles.first.path);
      final ext = extension(thumbnailFile.path).toLowerCase();
      final thumbnailRef = storage.ref('$storagePath/images/thumbnail$ext');
      await thumbnailRef.putFile(thumbnailFile);
      urls['thumbnail'] = await thumbnailRef.getDownloadURL();
    }
  }

  // 2. Upload vidéo
  final videosDir = Directory('assets/movies/$movieId/videos');
  if (await videosDir.exists()) {
    final videoFiles = await videosDir
        .list()
        .where((f) => f.path.toLowerCase().endsWith('.mp4'))
        .toList();

    if (videoFiles.isNotEmpty) {
      final videoFile = File(videoFiles.first.path);
      final videoRef =
          storage.ref('$storagePath/videos/${basename(videoFile.path)}');
      await videoRef.putFile(videoFile);
      urls['video'] = await videoRef.getDownloadURL();
    }
  }

  // 3. Upload gallery images
  urls['gallery'] = [];
  final galleryDir = Directory('assets/movies/$movieId/gallery');
  if (await galleryDir.exists()) {
    final galleryFiles = await galleryDir
        .list()
        .where((f) =>
            f.path.toLowerCase().endsWith('.jpg') ||
            f.path.toLowerCase().endsWith('.jpeg') ||
            f.path.toLowerCase().endsWith('.png'))
        .toList();

    for (var file in galleryFiles) {
      final fileName = basename(file.path);
      final ext = extension(file.path).toLowerCase();
      final galleryRef =
          storage.ref('$storagePath/gallery/${fileName.split('.').first}$ext');
      await galleryRef.putFile(File(file.path));
      urls['gallery'].add(await galleryRef.getDownloadURL());
    }
  }

  // 4. Upload cast images
  final castDir = Directory('assets/movies/$movieId/cast');
  if (await castDir.exists()) {
    final castFiles = await castDir
        .list()
        .where((f) =>
            f.path.toLowerCase().endsWith('.jpg') ||
            f.path.toLowerCase().endsWith('.jpeg') ||
            f.path.toLowerCase().endsWith('.png'))
        .toList();

    for (var file in castFiles) {
      final fileName = basename(file.path);
      final ext = extension(file.path).toLowerCase();
      final castRef =
          storage.ref('$storagePath/cast/${fileName.split('.').first}$ext');
      await castRef.putFile(File(file.path));
      urls['cast_${fileName.split('.').first}'] =
          await castRef.getDownloadURL();
    }
  }

  return urls;
}

// Fonction helper pour obtenir l'extension d'un fichier
String extension(String path) {
  final ext = path.split('.').last.toLowerCase();
  return '.$ext';
}*/

// Liste de tous vos MovieModel (exemple pour 1 film)
/*final List<MovieModel> allMovies = [
  MovieModel(
      id: "mov_01",
      title: "Big Buck Bunny",
      description: {
        'en': "A large and lovable rabbit deals with three tiny bullies.",
        'fr': "Un gros lapin adorable face à trois petits tyrans."
      },
      categories: ["Film"],
      genres: ["Animation", "Comedy"],
      type: "movie",
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_01/images/thumbnail.jpg",
      videoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_01/videos/main.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_01/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_01/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast01",
            name: "Sacha Goedegebure",
            role: "Director",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_01/cast/cast1.jpg")
      ],
      releaseDate: DateTime(2008, 4, 10),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 9, seconds: 56),
      isFree: true,
      rating: 4.2,
      viewCount: 1500000,
      likeCount: 89000,
      commentCount: 4500,
      metadata: {"resolution": "1080p", "size": "250MB"},
      isFeatured: true,
      isTrending: false,
      isNewRelease: false,
      director: "Sacha Goedegebure",
      languages: ["en"],
      subtitles: ["fr", "es", "de"]),
  MovieModel(
      id: "mov_02",
      title: "The Elephant Warrior",
      description: {
        'en':
            "In a dystopian future, a warrior rides a cybernetic elephant to save his tribe.",
        'fr':
            "Dans un futur dystopique, un guerrier monte un éléphant cybernétique pour sauver sa tribu."
      },
      categories: ["Film"],
      genres: ["Action", "Sci-Fi"],
      type: "movie",
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_02/images/thumbnail.jpg",
      videoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_02/videos/main.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_02/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_02/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast02",
            name: "Idris Elba",
            role: "Kael",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_02/cast/cast1.jpg"),
        CastModel(
            id: "cast03",
            name: "Lupita Nyong'o",
            role: "Zara",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_02/cast/cast2.jpg")
      ],
      releaseDate: DateTime(2022, 11, 15),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 128),
      isFree: false,
      rating: 4.5,
      viewCount: 850000,
      likeCount: 67000,
      commentCount: 3200,
      metadata: {"resolution": "4K", "size": "3.2GB"},
      isFeatured: true,
      isTrending: false,
      isNewRelease: false,
      director: "Ava DuVernay",
      languages: ["en", "fr"],
      subtitles: ["fr", "es", "de", "zh"]),
  MovieModel(
      id: "mov_03",
      title: "Quantum Shadows",
      description: {
        'en':
            "A physicist discovers a way to see 24 hours into the future with deadly consequences.",
        'fr':
            "Un physicien découvre un moyen de voir 24 heures dans le futur avec des conséquences mortelles."
      },
      categories: ["Film"],
      genres: ["Sci-Fi", "Thriller"],
      type: "movie",
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_03/images/thumbnail.jpg",
      videoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_03/videos/main.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_03/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_03/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast04",
            name: "Dev Patel",
            role: "Dr. Arjun Rao",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_03/cast/cast1.jpg")
      ],
      releaseDate: DateTime(2023, 3, 8),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 112),
      isFree: false,
      rating: 4.7,
      viewCount: 920000,
      likeCount: 78000,
      commentCount: 4100,
      metadata: {"resolution": "1080p", "size": "2.1GB"},
      isFeatured: true,
      isTrending: false,
      isNewRelease: false,
      director: "Denis Villeneuve",
      languages: ["en", "fr"],
      subtitles: ["fr", "es", "de"]),
  MovieModel(
      id: "mov_04",
      title: "Neon Hunters",
      description: {
        'en': "In 2145, bounty hunters track criminals in a cyberpunk Tokyo.",
        'fr':
            "En 2145, des chasseurs de primes traquent des criminels dans un Tokyo cyberpunk."
      },
      categories: ["Série"],
      genres: ["Action", "Sci-Fi"],
      type: "series",
      seasonNumber: 1,
      episodeNumber: 8,
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_04/images/thumbnail.jpg",
      videoUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_04/videos/s01e01.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_04/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_04/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast05",
            name: "Rinko Kikuchi",
            role: "Hana",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_04/cast/cast1.jpg")
      ],
      releaseDate: DateTime(2023, 1, 15),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 45),
      isFree: true,
      rating: 4.8,
      viewCount: 3200000,
      likeCount: 210000,
      commentCount: 12500,
      metadata: {"resolution": "4K", "size": "1.8GB"},
      isFeatured: false,
      isTrending: true,
      isNewRelease: false,
      director: "Leos Carax",
      languages: ["en", "fr", "jp"],
      subtitles: ["fr", "es", "de", "zh"]),
  MovieModel(
      id: "mov_05",
      title: "The Silent Protocol",
      description: {
        'en':
            "A whistleblower uncovers a global conspiracy of silenced assassinations.",
        'fr':
            "Un lanceur d'alerte découvre une conspiration mondiale d'assassinats silencieux."
      },
      categories: ["Film"],
      genres: ["Thriller"],
      type: "movie",
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_05/images/thumbnail.jpg",
      videoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_05/videos/main.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_05/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_05/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast06",
            name: "Jodie Comer",
            role: "Elena Voss",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_05/cast/cast1.jpg")
      ],
      releaseDate: DateTime(2023, 5, 22),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 118),
      isFree: false,
      rating: 4.6,
      viewCount: 2800000,
      likeCount: 190000,
      commentCount: 9800,
      metadata: {"resolution": "1080p", "size": "2.4GB"},
      isFeatured: false,
      isTrending: true,
      isNewRelease: false,
      director: "David Fincher",
      languages: ["en", "fr"],
      subtitles: ["fr", "es", "de"]),
  MovieModel(
      id: "mov_06",
      title: "Mars Underground",
      description: {
        'en':
            "Scientists discover a vast underground network of caves on Mars that could harbor life.",
        'fr':
            "Des scientifiques découvrent un vaste réseau de grottes souterraines sur Mars qui pourrait abriter la vie."
      },
      categories: ["Documentaire"],
      genres: ["Sci-Fi", "Documentary"],
      type: "movie",
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_06/images/thumbnail.jpg",
      videoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_06/videos/main.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_06/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_06/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast07",
            name: "Neil deGrasse Tyson",
            role: "Narrator",
            photoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_06/cas.jpg")
      ],
      releaseDate: DateTime(2023, 2, 14),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 92),
      isFree: true,
      rating: 4.4,
      viewCount: 1800000,
      likeCount: 95000,
      commentCount: 5600,
      metadata: {"resolution": "1080p", "size": "1.5GB"},
      isFeatured: false,
      isTrending: true,
      isNewRelease: false,
      director: "Werner Herzog",
      languages: ["en", "fr"],
      subtitles: ["fr", "es", "de"]),
  MovieModel(
      id: "mov_07",
      title: "Project Gemini",
      description: {
        'en':
            "Twin astronauts on a deep space mission discover they're part of a secret experiment.",
        'fr':
            "Des astronautes jumeaux en mission spatiale découvrent qu'ils font partie d'une expérience secrète."
      },
      categories: ["Film"],
      genres: ["Sci-Fi", "Thriller"],
      type: "movie",
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_07/images/thumbnail.jpg",
      videoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_07/videos/main.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_07/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_07/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast08",
            name: "Florence Pugh",
            role: "Dr. Ava / Dr. Zoe",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_07/cast/cast1/fl.jpg")
      ],
      releaseDate: DateTime(2023, 7, 1),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 105),
      isFree: false,
      rating: 4.9,
      viewCount: 420000,
      likeCount: 38000,
      commentCount: 2100,
      metadata: {"resolution": "4K", "size": "3.5GB"},
      isFeatured: false,
      isTrending: false,
      isNewRelease: true,
      director: "Claire Denis",
      languages: ["en", "fr"],
      subtitles: ["fr", "es", "de"]),
  MovieModel(
      id: "mov_08",
      title: "The Last Drop",
      description: {
        'en':
            "A water smuggler in a drought-ravaged future must protect the last freshwater source.",
        'fr':
            "Un trafiquant d'eau dans un futur ravagé par la sécheresse doit protéger la dernière source d'eau douce."
      },
      categories: ["Film"],
      genres: ["Action", "Thriller"],
      type: "movie",
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_08/images/thumbnail.jpg",
      videoUrl: "gs://abbeav-b780c.firebasestorage.app/mov_08/videos/main.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_08/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_08/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast09",
            name: "Oscar Isaac",
            role: "Kai",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_08/cast/cast1.jpg")
      ],
      releaseDate: DateTime(2023, 6, 15),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 97),
      isFree: true,
      rating: 4.3,
      viewCount: 580000,
      likeCount: 42000,
      commentCount: 2900,
      metadata: {"resolution": "1080p", "size": "2.2GB"},
      isFeatured: false,
      isTrending: false,
      isNewRelease: true,
      director: "George Miller",
      languages: ["en", "fr"],
      subtitles: ["fr", "es", "de"]),
  MovieModel(
      id: "mov_09",
      title: "Cybernetic Dawn",
      description: {
        'en':
            "In 2089, the first human-cyborg hybrid awakens with no memory but incredible abilities.",
        'fr':
            "En 2089, le premier hybride humain-cyborg se réveille sans mémoire mais avec des capacités incroyables."
      },
      categories: ["Série"],
      genres: ["Sci-Fi", "Thriller"],
      type: "series",
      seasonNumber: 1,
      episodeNumber: 6,
      thumbnailUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_09/images/thumbnail.jpg",
      videoUrl:
          "gs://abbeav-b780c.firebasestorage.app/mov_09/videos/s01e01.mp4",
      galleryImages: [
        "gs://abbeav-b780c.firebasestorage.app/mov_09/images/gallery1.jpg",
        "gs://abbeav-b780c.firebasestorage.app/mov_09/images/gallery2.jpg"
      ],
      cast: [
        CastModel(
            id: "cast10",
            name: "Letitia Wright",
            role: "Nexus-7",
            photoUrl:
                "gs://abbeav-b780c.firebasestorage.app/mov_09/cast/cast1/l.jpg")
      ],
      releaseDate: DateTime(2023, 7, 10),
      publishDate: DateTime.now(),
      duration: Duration(minutes: 52),
      isFree: false,
      rating: 4.7,
      viewCount: 720000,
      likeCount: 65000,
      commentCount: 3800,
      metadata: {"resolution": "4K", "size": "2.8GB"},
      isFeatured: false,
      isTrending: false,
      isNewRelease: true,
      director: "Lana Wachowski",
      languages: ["en", "fr"],
      subtitles: ["fr", "es", "de", "zh"]),
];*/
