// responsive_helper.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Classe principale qui gère tout le responsive design de l'application
class ABBEAVResponsive {
  // Singleton
  static final ABBEAVResponsive _instance = ABBEAVResponsive._internal();
  factory ABBEAVResponsive() => _instance;
  ABBEAVResponsive._internal();

  // Variables de dimension
  static late MediaQueryData _mediaQueryData;
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double _safeBlockHorizontal;
  static late double _safeBlockVertical;
  static late Orientation _orientation;
  static late double _devicePixelRatio;
  static late double _textScaleFactor;
  static late bool _isTablet;
  static late bool _isSmallDevice;
  static late bool _isMediumDevice;
  static late bool _isLargeDevice;
  static late EdgeInsets _devicePadding;

  /// Initialisation obligatoire dans le widget racine
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _orientation = _mediaQueryData.orientation;
    _devicePixelRatio = _mediaQueryData.devicePixelRatio;
    _textScaleFactor = _mediaQueryData.textScaleFactor;
    _devicePadding = _mediaQueryData.padding;

    // Calcul des tailles de base
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    // Zones sûres (safe area)
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    _safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    _safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;

    // Détection du type d'appareil
    _isTablet = _screenWidth >= 600;
    _isSmallDevice = _screenWidth < 350;
    _isMediumDevice = _screenWidth >= 350 && _screenWidth < 400;
    _isLargeDevice = _screenWidth >= 400;
  }

  //--------------------------------------------------
  // MÉTHODES FONDAMENTALES
  //--------------------------------------------------

  /// Adapte la taille de police en fonction de l'écran
  static double fontSize(double size) {
    // Base sur iPhone 13 mini (375x812)
    final double scaleFactor = _screenWidth / 375;

    // Limites pour éviter les tailles extrêmes
    if (scaleFactor > 1.5) return size * 1.5;
    if (scaleFactor < 0.8) return size * 0.8;

    return size * scaleFactor;
  }

  /// Adapte une dimension horizontale (largeur)
  static double w(double width) {
    return width * (_screenWidth / 375);
  }

  /// Adapte une dimension verticale (hauteur)
  static double h(double height) {
    return height * (_screenHeight / 812);
  }

  /// Adapte un padding/margin uniforme
  static EdgeInsets all(double value) {
    return EdgeInsets.all(value * (_screenWidth / 375));
  }

  /// Adapte un padding/margin symétrique
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal * (_screenWidth / 375),
      vertical: vertical * (_screenHeight / 812),
    );
  }

  /// Adapte un padding/margin seulement pour certains côtés
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left * (_screenWidth / 375),
      top: top * (_screenHeight / 812),
      right: right * (_screenWidth / 375),
      bottom: bottom * (_screenHeight / 812),
    );
  }

  //--------------------------------------------------
  // MÉTHODES AVANCÉES
  //--------------------------------------------------

  /// Widget responsive qui s'adapte automatiquement
  static Widget responsiveWidget({
    required Widget small,
    required Widget medium,
    required Widget large,
    Widget? tablet,
  }) {
    if (_isTablet && tablet != null) return tablet;
    if (_isSmallDevice) return small;
    if (_isMediumDevice) return medium;
    return large;
  }

  /// Nombre de colonnes adaptatif pour les grilles
  static int gridCrossAxisCount() {
    if (_screenWidth < 400) return 2;
    if (_screenWidth < 600) return 3;
    if (_screenWidth < 900) return 4;
    return 5;
  }

  /// Ratio d'aspect adaptatif pour les cartes
  static double gridChildAspectRatio() {
    if (_screenWidth < 400) return 0.65;
    if (_screenWidth < 600) return 0.7;
    if (_screenWidth < 900) return 0.75;
    return 0.8;
  }

  /// Espacement entre les éléments de grille
  static double gridSpacing() {
    return w(8);
  }

  //--------------------------------------------------
  // PLATEFORME SPÉCIFIQUE (iOS/Android)
  //--------------------------------------------------

  /// Adapte la taille en fonction de la plateforme
  static double platformSize(double iosSize, double androidSize) {
    return defaultTargetPlatform == TargetPlatform.iOS ? iosSize : androidSize;
  }

  /// Padding spécifique à la plateforme
  static EdgeInsets platformPadding({
    double iosTop = 0,
    double androidTop = 0,
    double iosBottom = 0,
    double androidBottom = 0,
    double iosLeft = 0,
    double androidLeft = 0,
    double iosRight = 0,
    double androidRight = 0,
  }) {
    return EdgeInsets.only(
      top: defaultTargetPlatform == TargetPlatform.iOS
          ? h(iosTop)
          : h(androidTop),
      bottom: defaultTargetPlatform == TargetPlatform.iOS
          ? h(iosBottom)
          : h(androidBottom),
      left: defaultTargetPlatform == TargetPlatform.iOS
          ? w(iosLeft)
          : w(androidLeft),
      right: defaultTargetPlatform == TargetPlatform.iOS
          ? w(iosRight)
          : w(androidRight),
    );
  }

  /// Style de texte adapté à la plateforme
  static TextStyle platformTextStyle({
    double? iosFontSize,
    double? androidFontSize,
    FontWeight? iosFontWeight,
    FontWeight? androidFontWeight,
    Color? color,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize(
        defaultTargetPlatform == TargetPlatform.iOS
            ? iosFontSize!
            : androidFontSize!,
      ),
      fontWeight: defaultTargetPlatform == TargetPlatform.iOS
          ? iosFontWeight
          : androidFontWeight,
      color: color,
      fontFamily: fontFamily,
    );
  }

  //--------------------------------------------------
  // STYLES PRÉDÉFINIS (Pour une cohérence globale)
  //--------------------------------------------------

  /// Style de texte pour les titres principaux
  static TextStyle headlineTextStyle({Color? color}) {
    return platformTextStyle(
      iosFontSize: 24,
      androidFontSize: 22,
      iosFontWeight: FontWeight.w600,
      androidFontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Style de texte pour les sous-titres
  static TextStyle subtitleTextStyle({Color? color}) {
    return platformTextStyle(
      iosFontSize: 18,
      androidFontSize: 16,
      iosFontWeight: FontWeight.w500,
      androidFontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Style de texte pour le corps
  static TextStyle bodyTextStyle({Color? color}) {
    return platformTextStyle(
      iosFontSize: 16,
      androidFontSize: 14,
      iosFontWeight: FontWeight.w400,
      androidFontWeight: FontWeight.normal,
      color: color,
    );
  }

  /// Style de texte pour les boutons
  static TextStyle buttonTextStyle({Color? color}) {
    return platformTextStyle(
      iosFontSize: 17,
      androidFontSize: 15,
      iosFontWeight: FontWeight.w500,
      androidFontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Style de texte pour les légendes
  static TextStyle captionTextStyle({Color? color}) {
    return platformTextStyle(
      iosFontSize: 12,
      androidFontSize: 11,
      iosFontWeight: FontWeight.w400,
      androidFontWeight: FontWeight.normal,
      color: color,
    );
  }

  //--------------------------------------------------
  // WIDGETS PRÉDÉFINIS (Pour une cohérence globale)
  //--------------------------------------------------

  /// Bouton adaptatif pour toute l'application
  static Widget adaptiveButton({
    required VoidCallback onPressed,
    required String text,
    Color? backgroundColor,
    Color? textColor,
    double? width,
  }) {
    return SizedBox(
      width: width != null ? w(width) : double.infinity,
      height: h(50),
      child: defaultTargetPlatform == TargetPlatform.iOS
          ? CupertinoButton(
              onPressed: onPressed,
              color: backgroundColor ?? Colors.blue,
              borderRadius: BorderRadius.circular(w(10)),
              child: Text(
                text,
                style: buttonTextStyle(color: textColor ?? Colors.white),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w(10)),
                ),
              ),
              child: Text(
                text,
                style: buttonTextStyle(color: textColor ?? Colors.white),
              ),
            ),
    );
  }

  /// AppBar adaptative pour toute l'application
  static PreferredSizeWidget adaptiveAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool? centerTitle,
  }) {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? CupertinoNavigationBar(
            middle: Text(
              title,
              style: headlineTextStyle(),
            ),
            leading: leading,
            trailing: actions != null ? Row(children: actions) : null,
          )
        : AppBar(
            title: Text(
              title,
              style: headlineTextStyle(),
            ),
            centerTitle: centerTitle,
            leading: leading,
            actions: actions,
            elevation: h(2),
          );
  }

  /// Card adaptative pour les films/séries
  static Widget movieCard({
    required String imageUrl,
    required String title,
    required double rating,
    required VoidCallback onTap,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width != null ? w(width) : w(150),
        height: height != null ? h(height) : h(220),
        margin: symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(w(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: w(4),
              spreadRadius: w(1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du film
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(w(12))),
              child: Image.network(
                imageUrl,
                width: width != null ? w(width) : w(150),
                height: height != null ? h(height! * 0.8) : h(176),
                fit: BoxFit.cover,
              ),
            ),

            // Infos du film
            Padding(
              padding: all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: bodyTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: h(4)),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: fontSize(16),
                      ),
                      SizedBox(width: w(4)),
                      Text(
                        rating.toString(),
                        style: captionTextStyle(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grille responsive pour les listes de films
  static Widget moviesGrid({
    required List<Movie> movies,
    required VoidCallback onItemTap,
  }) {
    return GridView.builder(
      padding: all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossAxisCount(),
        childAspectRatio: gridChildAspectRatio(),
        crossAxisSpacing: gridSpacing(),
        mainAxisSpacing: gridSpacing(),
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return movieCard(
          imageUrl: movies[index].imageUrl,
          title: movies[index].title,
          rating: movies[index].rating,
          onTap: () => onItemTap(),
        );
      },
    );
  }
}

/// Modèle exemple pour le film (à adapter selon vos besoins)
class Movie {
  final String title;
  final String imageUrl;
  final double rating;

  Movie({
    required this.title,
    required this.imageUrl,
    required this.rating,
  });
}
