import 'package:abbeav/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloudfirestore/cloudfirestore.dart';
import 'package:flutter/foundation.dart';
import '../models/movies_model.dart';
import '../models/user_model.dart';

class MovieController with ChangeNotifier {
  final FirebaseFirestore firestore; //= FirebaseFirestore.instance;

  MovieController({required this.firestore});

  // Récupérer tous les films
  Stream<List<MovieModel>> getAllMovies({int? limit}) {
    Query query =
        firestore.collection('movies').orderBy('publishDate', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList());
  }

  // Récupérer les films populaires
  Stream<List<MovieModel>> getPopularMovies({int limit = 1}) {
    return firestore
        .collection('movies')
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList());
  }

  // Récupérer les nouveautés
  Stream<List<MovieModel>> getNewReleases({int limit = 10}) {
    return firestore
        .collection('movies')
        .where('isNewRelease', isEqualTo: true)
        .orderBy('publishDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList());
  }

  // Récupérer les tendances
  Stream<List<MovieModel>> getTrendingMovies({int limit = 10}) {
    return firestore
        .collection('movies')
        .where('isTrending', isEqualTo: true)
        .orderBy('publishDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList());
  }

  // Récupérer les films boostés (pour le carousel)
  Stream<List<MovieModel>> getFeaturedMovies({int limit = 5}) {
    return firestore
        .collection('movies')
        .where('isFeatured', isEqualTo: true)
        .orderBy('publishDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList());
  }

  // Récupérer les détails d'un film
  Future<MovieModel> getMovieDetails(String movieId) async {
    final doc = await firestore.collection('movies').doc(movieId).get();
    if (!doc.exists) throw Exception('Movie not found');
    return MovieModel.fromFirestore(doc);
  }

  // Incrémenter le compteur de vues
  Future<void> incrementViewCount(String movieId) async {
    await firestore.collection('movies').doc(movieId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // Rechercher des films
  Future<List<MovieModel>> searchMovies({
    String? query,
    List<String>? categories,
    List<String>? genres,
    int limit = 20,
  }) async {
    Query queryRef = firestore.collection('movies').limit(limit);

    if (query != null && query.isNotEmpty) {
      queryRef = queryRef.where(
        'title',
        isGreaterThanOrEqualTo: query,
        isLessThan: query + 'z',
      );
    }

    if (categories != null && categories.isNotEmpty) {
      queryRef = queryRef.where('categories', arrayContainsAny: categories);
    }

    if (genres != null && genres.isNotEmpty) {
      queryRef = queryRef.where('genres', arrayContainsAny: genres);
    }

    final snapshot = await queryRef.get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  // Récupérer les films similaires
  Future<List<MovieModel>> getSimilarMovies(MovieModel movie,
      {int limit = 5}) async {
    final snapshot = await firestore
        .collection('movies')
        .where('genres', arrayContainsAny: movie.genres)
        .where(FieldPath.documentId, isNotEqualTo: movie.id)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  // Récupérer les films par catégorie
  Stream<List<MovieModel>> getMoviesByCategory(String category,
      {int limit = 10}) {
    return firestore
        .collection('movies')
        .where('categories', arrayContains: category)
        .orderBy('publishDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList());
  }

  // Récupérer les films par genre
  Stream<List<MovieModel>> getMoviesByGenre(String genre, {int limit = 10}) {
    return firestore
        .collection('movies')
        .where('genres', arrayContains: genre)
        .orderBy('publishDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList());
  }

  // Ajouter/retirer un like
  Future<void> toggleLike(String movieId, String userId) async {
    final batch = firestore.batch();
    final movieRef = firestore.collection('movies').doc(movieId);
    final userRef = firestore.collection('users').doc(userId);

    // Vérifier si l'utilisateur a déjà liké
    final userDoc = await userRef.get();
    final likedMovies = List<String>.from(userDoc['likedMovies'] ?? []);

    if (likedMovies.contains(movieId)) {
      // Retirer le like
      batch.update(movieRef, {'likeCount': FieldValue.increment(-1)});
      batch.update(userRef, {
        'likedMovies': FieldValue.arrayRemove([movieId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Ajouter le like
      batch.update(movieRef, {'likeCount': FieldValue.increment(1)});
      batch.update(userRef, {
        'likedMovies': FieldValue.arrayUnion([movieId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // Vérifier si un film est liké
  Future<bool> isMovieLiked(String movieId, String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    final likedMovies = List<String>.from(doc['likedMovies'] ?? []);
    return likedMovies.contains(movieId);
  }

// Récupérer les commentaires d'un film
  Stream<List<CommentModel>> getMovieComments(String movieId) {
    return firestore
        .collection('comments')
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

// Ajouter un commentaire
  Future<void> addComment({
    required String movieId,
    required String userId,
    required String userFullName,
    required String? userPhotoUrl,
    required String content,
  }) async {
    final batch = firestore.batch();
    final commentRef = firestore.collection('comments').doc();
    final movieRef = firestore.collection('movies').doc(movieId);

    final comment = CommentModel(
      id: commentRef.id,
      movieId: movieId,
      userId: userId,
      userFullName: userFullName,
      userPhotoUrl: userPhotoUrl,
      content: content,
      createdAt: DateTime.now(),
    );

    batch.set(commentRef, comment.toMap());
    batch.update(movieRef, {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Supprimer un commentaire
  Future<void> deleteComment(String commentId, String movieId) async {
    final batch = firestore.batch();
    final commentRef = firestore.collection('comments').doc(commentId);
    final movieRef = firestore.collection('movies').doc(movieId);

    batch.delete(commentRef);
    batch.update(movieRef, {
      'commentCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }
}
