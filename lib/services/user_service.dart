import 'package:abbeav/models/movies_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer ou récupérer un utilisateur à partir d'un Firebase User
  Future<UserModel> getOrCreateUser(User firebaseUser) async {
    final userDoc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (userDoc.exists) {
      return UserModel.fromFirestore(userDoc);
    } else {
      // Créer un nouvel utilisateur
      final newUser = UserModel.fromFirebaseUser(firebaseUser);
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toMap());
      return newUser;
    }
  }

  // Récupérer un utilisateur par son ID
  Future<UserModel> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('User not found');
    return UserModel.fromFirestore(doc);
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fullName != null) updates['fullName'] = fullName;
    if (email != null) updates['email'] = email;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firestore.collection('users').doc(userId).update(updates);

    // Mettre à jour l'email dans Firebase Auth si nécessaire
    if (email != null && _auth.currentUser?.email != email) {
      await _auth.currentUser?.verifyBeforeUpdateEmail(email);
    }
  }

  // Changer la langue de préférence
  Future<void> updateLanguagePreference(String userId, String language) async {
    await _firestore.collection('users').doc(userId).update({
      'languagePreference': language,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Gérer les favoris
  Future<void> toggleFavorite(String userId, String movieId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();

    List<String> favorites = List<String>.from(userDoc['favoriteMovies'] ?? []);

    if (favorites.contains(movieId)) {
      favorites.remove(movieId);
    } else {
      favorites.add(movieId);
    }

    await userRef.update({
      'favoriteMovies': favorites,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Vérifier si un film est dans les favoris
  Future<bool> isMovieFavorite(String userId, String movieId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final favorites = List<String>.from(doc['favoriteMovies'] ?? []);
    return favorites.contains(movieId);
  }

  // Mettre à jour la progression de visionnage
  Future<void> updateWatchingProgress({
    required String userId,
    required String movieId,
    required Duration progress,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'watchingProgress.$movieId': progress.inSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Récupérer l'historique de visionnage
  Future<List<MovieModel>> getWatchingHistory(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final progress = userDoc['watchingProgress'] ?? {};

    if (progress.isEmpty) return [];

    final movies = await _firestore
        .collection('movies')
        .where(FieldPath.documentId, whereIn: progress.keys.toList())
        .get();

    return movies.docs.map((doc) {
      final movie = MovieModel.fromFirestore(doc);
      final watchedDuration = progress[doc.id] ?? 0;
      movie.watchedProgress = watchedDuration / movie.duration.inSeconds;
      return movie;
    }).toList();
  }

  // Activer/désactiver les notifications
  Future<void> toggleNotifications(String userId, bool enabled) async {
    await _firestore.collection('users').doc(userId).update({
      'notificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Ajouter une méthode de paiement
  Future<void> addPaymentMethod({
    required String userId,
    required PaymentMethodModel paymentMethod,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'paymentMethods': FieldValue.arrayUnion([paymentMethod.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Supprimer une méthode de paiement
  Future<void> removePaymentMethod({
    required String userId,
    required PaymentMethodModel paymentMethod,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'paymentMethods': FieldValue.arrayRemove([paymentMethod.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Mettre à jour l'abonnement
  Future<void> updateSubscription({
    required String userId,
    required SubscriptionModel subscription,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'subscription': subscription.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
