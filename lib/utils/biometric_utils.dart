import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

class CustomBiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate({
    required BuildContext context,
    required String authMessage,
    String? cancelButtonText,
    Color? backgroundColor,
    Widget? customIcon,
    String? successMessage,
    String? failureMessage,
  }) async {
    try {
      // Vérifier la disponibilité
      final canAuthenticate = await _auth.canCheckBiometrics;
      if (!canAuthenticate) {
        _showCustomDialog(
          context,
          title: 'Non disponible',
          content:
              'Authentification biométrique non disponible sur cet appareil',
          icon: Icons.error_outline,
        );
        return false;
      }

      // Afficher notre UI personnalisée
      bool authResult = false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _BiometricAuthDialog(
          authMessage: authMessage,
          onAuthenticate: () async {
            try {
              final result = await _auth.authenticate(
                localizedReason: authMessage,
                authMessages: [
                  /*AndroidAuthMessages(
                    signInTitle: 'Authentification requise',
                    cancelButton: cancelButtonText ?? 'Annuler',
                  ),*/
                ],
                options: const AuthenticationOptions(
                  biometricOnly: true,
                  sensitiveTransaction: true,
                ),
              );
              if (result) {
                Navigator.pop(context); // Fermer le dialog
                authResult = true;
                _showSuccessFeedback(context, successMessage);
              }
            } on PlatformException catch (e) {
              Navigator.pop(context); // Fermer le dialog
              _showErrorFeedback(context, e.message ?? 'Erreur inconnue');
            }
          },
          backgroundColor: backgroundColor,
          customIcon: customIcon,
        ),
      );

      return authResult;
    } catch (e) {
      _showErrorFeedback(context, e.toString());
      return false;
    }
  }

  static void _showSuccessFeedback(BuildContext context, String? message) {
    _showCustomDialog(
      context,
      title: 'Succès',
      content: message ?? 'Authentification réussie',
      icon: Icons.check_circle,
      iconColor: Colors.green,
    );
  }

  static void _showErrorFeedback(BuildContext context, String error) {
    _showCustomDialog(
      context,
      title: 'Erreur',
      content: _getUserFriendlyError(error),
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  }

  static String _getUserFriendlyError(String error) {
    if (error.contains('NotEnrolled')) {
      return 'Aucune empreinte enregistrée sur cet appareil';
    } else if (error.contains('LockedOut')) {
      return 'Trop de tentatives - Veuillez réessayer plus tard';
    }
    return 'Échec de l\'authentification';
  }

  static void _showCustomDialog(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _BiometricAuthDialog extends StatefulWidget {
  final String authMessage;
  final Future<void> Function() onAuthenticate;
  final Color? backgroundColor;
  final Widget? customIcon;

  const _BiometricAuthDialog({
    required this.authMessage,
    required this.onAuthenticate,
    this.backgroundColor,
    this.customIcon,
  });

  @override
  __BiometricAuthDialogState createState() => __BiometricAuthDialogState();
}

class __BiometricAuthDialogState extends State<_BiometricAuthDialog> {
  bool _isAuthenticating = false;
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _startAuth();
  }

  Future<void> _startAuth() async {
    setState(() {
      _isAuthenticating = true;
      _showRetry = false;
    });
    await widget.onAuthenticate();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor:
            widget.backgroundColor ?? Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueAccent, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              widget.customIcon ??
                  Lottie.asset(
                    'assets/lottie/fingerprint.json',
                    width: 150,
                    height: 150,
                    repeat: _isAuthenticating,
                  ),
              SizedBox(height: 20),
              Text(
                widget.authMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (_showRetry)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: _startAuth,
                  child: Text('Réessayer'),
                ),
              if (!_showRetry && _isAuthenticating)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';

class BiometricUtils {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> verifyFingerprint(
    BuildContext context, {
    required String message,
  }) async {
    try {
      // Check if biometric auth is available
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        _showErrorDialog(context, 'Biometric authentication not available');
        return false;
      }

      // Show fingerprint animation
      /*await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/fingerprint.json',
                width: 200,
                height: 200,
                repeat: true,
              ),
              Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );*/

      // Perform actual authentication
      final didAuthenticate = await _auth.authenticate(
        localizedReason: message,
        options: AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      //Navigator.pop(context); // Close fingerprint dialog

      return didAuthenticate;
    } catch (e) {
      _showErrorDialog(context, 'Authentication failed: ${e.toString()}');
      return false;
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}*/

