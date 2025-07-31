import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

class GcpConfig {
  static final _scopes = [StorageApi.devstorageReadWriteScope];
  static AutoRefreshingAuthClient? _authClient;

  // Initialiser le client GCP
  static Future<void> init() async {
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      // Ajouter les informations d'identification du compte de service
    });

    _authClient = await clientViaServiceAccount(
      accountCredentials,
      _scopes,
    );
  }

  // Obtenir le client authentifié
  static AutoRefreshingAuthClient? get authClient {
    if (_authClient == null) {
      throw Exception('GCP client not initialized');
    }
    return _authClient;
  }

  // Configuration du transcodage vidéo
  static Future<void> configureVideoTranscoding() async {
    // Configuration pour utiliser Google Cloud Transcoder API
  }

  // Configuration du CDN
  static Future<void> configureCdn() async {
    // Configuration pour utiliser Google Cloud CDN
  }
}
