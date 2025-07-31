import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseConfig {
  static late FirebaseApp app;
  static late FirebaseAuth auth;
  static late FirebaseFirestore firestore;
  static late FirebaseStorage storage;

  static Future<void> init() async {
    app = await Firebase.initializeApp();
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;

    // Configuration supplémentaire
    firestore.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Activation de la persistance offline
    await firestore.enablePersistence();
  }

  // Configuration pour les SMS OTP (Vonage)
  static Future<void> configurePhoneAuth() async {
    // Configuration spécifique pour la vérification par téléphone
    auth.setSettings(
      appVerificationDisabledForTesting: false, // Mettre à true pour les tests
    );
  }

  // Configuration des règles de sécurité
  static Future<void> configureSecurityRules() async {
    // Les règles sont configurées côté serveur
    // Cette méthode peut être utilisée pour vérifier les permissions
  }
}
