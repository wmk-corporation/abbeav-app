import 'dart:async';
import 'package:abbeav/models/movies_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';

class UserController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Singleton pattern
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal();

  // ========== Authentication Methods ==========

  /// Initialize controller
  void initialize() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        //debugPrint('User signed in: ${user.uid}');
      } else {
        //debugPrint('User signed out');
      }
    });
  }

  /// Email/Password Sign Up
  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        phoneNumber: phoneNumber,
        fullName: fullName,
        provider: 'email',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        languagePreference: 'fr',
        favoriteMovies: [],
        watchingProgress: {},
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } catch (e) {
      //debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for this email',
        );
      }

      return await _getOrCreateUser(userCredential.user!, 'email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'app-check-token-invalid') {
        return loginWithEmail(email: email, password: password);
      }
      rethrow;
    } catch (e) {
      //debugPrint('Login Error: $e');
      throw FirebaseAuthException(
        code: 'login-failed',
        message: 'Login failed. Please try again.',
      );
    }
  }

// Méthode pour réinitialiser le mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      //debugPrint('Error sending reset email: $e');
      rethrow;
    }
  }

  /// Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return await _getOrCreateUser(userCredential.user!, 'google');
    } catch (e) {
      //debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Apple Sign-In
  Future<UserModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'app.devanios.abbeav.services',
          redirectUri:
              Uri.parse('https://abbeav-b780c.firebaseapp.com/__/auth/handler'),
        ),
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Handle first-time Apple sign-in (displayName may be null)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        if (appleCredential.givenName != null) {
          await userCredential.user?.updateDisplayName(
            '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                .trim(),
          );
        }
      }

      return await _getOrCreateUser(userCredential.user!, 'apple');
    } catch (e) {
      //debugPrint('Apple Sign-In Error: $e');
      rethrow;
    }
  }

  /// Phone Number Sign-In
  Future<String> verifyPhoneNumber(String phoneNumber) async {
    try {
      Completer<String> completer = Completer();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _getOrCreateUser(userCredential.user!, 'phone');
          }
          completer.complete('verified');
        },
        verificationFailed: (FirebaseAuthException e) {
          //debugPrint('Phone verification failed: ${e.message}');
          completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          completer.complete(verificationId);
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      //debugPrint('Phone verification error: $e');
      rethrow;
    }
  }

  /// OTP Verification
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return await _getOrCreateUser(userCredential.user!, 'phone');
    } catch (e) {
      //debugPrint('OTP Verification Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // 1. Déconnexion de Firebase Auth
      await _auth.signOut();

      // 2. Déconnexion spécifique pour Google
      try {
        if (_googleSignIn.currentUser != null) {
          await _googleSignIn.signOut();
          await _googleSignIn.disconnect();
        }
      } catch (e) {
        //debugPrint('Google Sign-Out Error: $e');
      }

      // 4. Nettoyage supplémentaire
      try {
        await _firestore.clearPersistence();
      } catch (e) {
        //debugPrint('Error clearing Firestore persistence: $e');
      }
    } catch (e) {
      //debugPrint('Sign-Out Error: $e');
      rethrow;
    }
  }

  // ========== User Management ==========

  /// Get or create user in Firestore
  Future<UserModel> _getOrCreateUser(User firebaseUser, String provider) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        final user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          phoneNumber: firebaseUser.phoneNumber,
          fullName: firebaseUser.displayName ?? 'New User',
          photoUrl: firebaseUser.photoURL,
          provider: provider,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          languagePreference: 'fr',
          favoriteMovies: [],
          watchingProgress: {},
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());
        return user;
      }
    } catch (e) {
      //debugPrint('Error in _getOrCreateUser: $e');
      rethrow;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUser(user.uid);
  }

  /// Get user by ID
  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) throw Exception('User not found');
      return UserModel.fromFirestore(doc);
    } catch (e) {
      //debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) updates['fullName'] = fullName;
      if (email != null) updates['email'] = email;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(userId).update(updates);

      // Update email in Firebase Auth if changed
      if (email != null && _auth.currentUser?.email != email) {
        await _auth.currentUser?.verifyBeforeUpdateEmail(email);
      }
    } catch (e) {
      //debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
// Dans votre UserController - Améliorez la méthode existante changePassword:

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'User not logged in',
        );
      }

      if (user.email == null) {
        throw FirebaseAuthException(
          code: 'no-email-available',
          message: 'No email associated with this account',
        );
      }

      // 1. Réauthentification
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Vérification de la force du nouveau mot de passe
      if (newPassword.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password should be at least 6 characters',
        );
      }

      // 3. Mise à jour du mot de passe
      await user.updatePassword(newPassword);

      // 4. Mise à jour dans Firestore (si vous stockez des infos de sécurité)
      await _firestore.collection('users').doc(user.uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'passwordChangedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      // Gestion spécifique des erreurs Firebase
      if (e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Current password is incorrect',
        );
      }
      rethrow;
    } catch (e) {
      //debugPrint('Error in changePassword: $e');
      throw FirebaseAuthException(
        code: 'password-change-failed',
        message: 'Failed to change password',
      );
    }
  }

// Ajoutez cette méthode à votre UserController pour la gestion des erreurs:
  String getPasswordError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Mot de passe actuel incorrect';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      case 'requires-recent-login':
        return 'Authentification récente requise - veuillez vous reconnecter';
      case 'user-not-logged-in':
        return 'Utilisateur non connecté';
      case 'no-email-available':
        return 'Aucun email associé à ce compte';
      default:
        return 'Erreur lors du changement de mot de passe: ${e.message}';
    }
  }

  // ========== User Content Methods ==========

  /// Toggle favorite movie
  Future<void> toggleFavorite(String userId, String movieId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      List<String> favorites =
          List<String>.from(userDoc['favoriteMovies'] ?? []);

      if (favorites.contains(movieId)) {
        favorites.remove(movieId);
      } else {
        favorites.add(movieId);
      }

      await userRef.update({
        'favoriteMovies': favorites,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Check if movie is favorite
  Future<bool> isMovieFavorite(String userId, String movieId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final favorites = List<String>.from(doc['favoriteMovies'] ?? []);
      return favorites.contains(movieId);
    } catch (e) {
      //debugPrint('Error checking favorite: $e');
      rethrow;
    }
  }

  /// Update watching progress
  Future<void> updateWatchingProgress({
    required String userId,
    required String movieId,
    required Duration progress,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'watchingProgress.$movieId': progress.inSeconds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //debugPrint('Error updating progress: $e');
      rethrow;
    }
  }

  /// Get watching history
  Future<List<MovieModel>> getWatchingHistory(String userId) async {
    try {
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
    } catch (e) {
      //debugPrint('Error getting watching history: $e');
      rethrow;
    }
  }

  // ========== User Settings ==========

  /// Update language preference
  Future<void> updateLanguagePreference(String userId, String language) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'languagePreference': language,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //debugPrint('Error updating language: $e');
      rethrow;
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(String userId, bool enabled) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'notificationsEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //debugPrint('Error toggling notifications: $e');
      rethrow;
    }
  }

  // ========== Payment Methods ==========

  /// Add payment method
  Future<void> addPaymentMethod({
    required String userId,
    required PaymentMethodModel paymentMethod,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'paymentMethods': FieldValue.arrayUnion([paymentMethod.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //debugPrint('Error adding payment method: $e');
      rethrow;
    }
  }

  /// Remove payment method
  Future<void> removePaymentMethod({
    required String userId,
    required PaymentMethodModel paymentMethod,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'paymentMethods': FieldValue.arrayRemove([paymentMethod.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //debugPrint('Error removing payment method: $e');
      rethrow;
    }
  }

  /// Update subscription
  Future<void> updateSubscription({
    required String userId,
    required SubscriptionModel subscription,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'subscription': subscription.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //debugPrint('Error updating subscription: $e');
      rethrow;
    }
  }

  // ========== Helper Methods ==========

  /// Get friendly error message
  String getFriendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Invalid OTP. Please try again.';
      case 'quota-exceeded':
        return 'Too many requests. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this credential.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'session-expired':
        return 'The session has expired. Please try again.';
      case 'credential-already-in-use':
        return 'This account is already linked with another sign-in method.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

/*import 'dart:async';

import 'package:abbeav/models/movies_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ========== Méthodes d'authentification ==========

  // Méthode pour obtenir l'instance
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal();

  // ========== Méthodes d'authentification ==========

  /// Connexion avec Google (optimisée)
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Démarrer le processus de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');

      // 2. Obtenir les authentifications
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Créer les credentials Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Connecter avec Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // 5. Vérifier si l'utilisateur existe
      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // 6. Récupérer ou créer l'utilisateur
      return await _getOrCreateUser(userCredential.user!, 'google');
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Connexion avec Apple (optimisée)
  Future<UserModel> signInWithApple() async {
    try {
      // 1. Démarrer le processus de connexion Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'app.devanios.abbeav.services',
          redirectUri:
              Uri.parse('https://abbeav-b780c.firebaseapp.com/__/auth/handler'),
        ),
      );

      // 2. Créer les credentials OAuth
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3. Connecter avec Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // 4. Vérifier si l'utilisateur existe
      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Apple');
      }

      // 5. Gérer le nom complet pour Apple (peut être null au premier login)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        if (appleCredential.givenName != null) {
          await userCredential.user?.updateDisplayName(
            '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                .trim(),
          );
        }
      }

      // 6. Récupérer ou créer l'utilisateur
      return await _getOrCreateUser(userCredential.user!, 'apple');
    } catch (e) {
      print('Apple Sign-In Error: $e');
      rethrow;
    }
  }

  /// Connexion avec numéro de téléphone (optimisée)
  Future<String> verifyPhoneNumber(String phoneNumber) async {
    try {
      Completer<String> completer = Completer();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-validation si le SMS est détecté automatiquement
          final userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _getOrCreateUser(userCredential.user!, 'phone');
          }
          completer.complete('verified');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: ${e.message}');
          completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          completer.complete(verificationId);
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      print('Phone verification error: $e');
      rethrow;
    }
  }

  /// Vérification OTP (optimisée)
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw Exception('Failed to verify OTP');
      }

      return await _getOrCreateUser(userCredential.user!, 'phone');
    } catch (e) {
      print('OTP Verification Error: $e');
      rethrow;
    }
  }

  // ========== Méthodes utilitaires ==========

  /// Récupérer ou créer un utilisateur (optimisée)
  Future<UserModel> _getOrCreateUser(User firebaseUser, String provider) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Créer un nouvel utilisateur
        final user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          phoneNumber: firebaseUser.phoneNumber,
          fullName: firebaseUser.displayName ?? 'New User',
          photoUrl: firebaseUser.photoURL,
          provider: provider,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          languagePreference: 'fr',
          favoriteMovies: [],
          watchingProgress: {},
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());
        return user;
      }
    } catch (e) {
      print('Error in _getOrCreateUser: $e');
      rethrow;
    }
  }

  /// Créer un utilisateur avec email/mot de passe
  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        phoneNumber: phoneNumber,
        fullName: fullName,
        provider: 'email',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        languagePreference: 'fr',
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  /// Connexion avec numéro de téléphone
  Future<void> phoneSignIn(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        // Stocker verificationId pour l'utiliser plus tard
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Connexion avec email/mot de passe
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await getUser(userCredential.user!.uid);
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Récupérer l'utilisateur actuel
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUser(user.uid);
  }

  /// Récupérer un utilisateur par son ID
  Future<UserModel> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('User not found');
    return UserModel.fromFirestore(doc);
  }

  /// Mettre à jour le profil utilisateur
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

    if (email != null && _auth.currentUser?.email != email) {
      await _auth.currentUser?.verifyBeforeUpdateEmail(email);
    }
  }

  /// Changer le mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    if (user.email == null) throw Exception('Email not available');

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  // ========== Méthodes de contenu utilisateur ==========

  /// Gérer les favoris
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

  /// Vérifier si un film est dans les favoris
  Future<bool> isMovieFavorite(String userId, String movieId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final favorites = List<String>.from(doc['favoriteMovies'] ?? []);
    return favorites.contains(movieId);
  }

  /// Mettre à jour la progression de visionnage
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

  /// Récupérer l'historique de visionnage
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

  // ========== Méthodes de paramètres utilisateur ==========

  /// Changer la langue de préférence
  Future<void> updateLanguagePreference(String userId, String language) async {
    await _firestore.collection('users').doc(userId).update({
      'languagePreference': language,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Activer/désactiver les notifications
  Future<void> toggleNotifications(String userId, bool enabled) async {
    await _firestore.collection('users').doc(userId).update({
      'notificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== Méthodes de paiement ==========

  /// Ajouter une méthode de paiement
  Future<void> addPaymentMethod({
    required String userId,
    required PaymentMethodModel paymentMethod,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'paymentMethods': FieldValue.arrayUnion([paymentMethod.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Supprimer une méthode de paiement
  Future<void> removePaymentMethod({
    required String userId,
    required PaymentMethodModel paymentMethod,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'paymentMethods': FieldValue.arrayRemove([paymentMethod.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mettre à jour l'abonnement
  Future<void> updateSubscription({
    required String userId,
    required SubscriptionModel subscription,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'subscription': subscription.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}*/
