import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Unlimited Movies',
      'subtitle': 'Watch anywhere. Cancel anytime.',
      'description':
          'Ready to watch? Tap the button below to start your membership.',
      'popular': 'Popular on ABBEAV',
      'login': 'Sign In',
      'changeLanguage': 'English',
      'latests': 'Latests',

      'seeAll': 'See All',
      'trending': 'Trending',

      'topMovies': 'Top Movies',
      'newMovies': 'New Movies',
      'downloads': 'Downloads',
      'settings': 'Settings',
      'language': 'Language',
      'darkMode': 'Dark Mode',
      'seasons': 'Seasons',
      'episodes': 'Episodes',
      'watchNow': 'Watch Now',
      'continueWatching': 'Continue Watching',
      'noResultsFound': 'No results found',

      // Action Buttons
      'play': 'Play',
      'pause': 'Pause',
      'stop': 'Stop',
      'replay': 'Replay',
      'addToList': 'Add to List',

      // Navigation
      'home': 'Home',
      'search': 'Search',
      'myList': 'My List',
      'profile': 'Profile',

      // Home
      'homeTitle': 'Welcome to ABBEAV',
      'popularsActors': 'Populars Actors',

      // Tickets
      'buyYourTickets': 'Buy your tickets',
      'bodyMessage':
          'Immerse yourself in the magical world of cinema! Book your tickets online at ABBEAV and enjoy an unforgettable experience. From blockbusters to auteur films, there\'s something for everyone. Find your next adventure on the big screen.',

      // Search
      'searchHint': 'Search for movies, series, or actors',
      'actors': 'Actors',
      'moviesSeries': 'Movies & Series',

      // Filters
      'category': 'Category',
      'all': 'All',
      'movies': 'Movies',
      'series': 'Series',
      'documentaries': 'Documentaries',
      'genre': 'Genre',
      'action': 'Action',
      'scienceFiction': 'Sci-Fiction',
      'thriller': 'Thriller',

      'reset': 'Reset',
      'apply': 'Apply',

      // My List
      'myListEmpty': 'Your list is empty',
      'addToMyList': 'Add to My List',
      'watching': 'Watching',
      'watched': 'Watched',
      'watchingList': 'Watching List',
      'watchedList': 'Watched List',
      'downloaded': 'Downloaded',
      'downloadedList': 'Downloaded List',
      'downloading': 'Downloading',
      'queuedForDownload': 'Queued for Download',
      'downloadFailed': 'Download Failed',
      'downloadSuccess': 'Download Successful',
      'tapToDownload': 'Tap to Download',
      'tapToRetry': 'Tap to Retry',
      'removeFromList': 'Remove from List',
      'removeFromWatchingList': 'Remove from Watching List',
      'removeFromMyList': 'Remove from My List',

      // Message Toasts
      'deletedSuccessfully': 'Deleted Successfully',
      'downloadNotCompletedYet': 'Download not completed yet',
      'downloadInProgress': 'Download in Progress',

      // Profile Settings
      'editProfilePicture': 'Edit Profile Picture',
      'settingsTitle': 'Settings',

      // Profile Options -> Settings
      'account': 'Account',
      'editProfile': 'Edit Profile',
      'languageChange': 'Change Language',
      'changePassword': 'Change Password',

      'notifications': 'Notifications',

      'logout': 'Logout',
      'confirmLogout': 'Confirm Logout',
      'logoutMessage': 'Are you sure you want to logout?',
      'cancel': 'Cancel',

      // Edit Profile Options
      'fullName': 'Full Name',
      'emailAddress': 'Email Address',
      'phoneNumber': 'Phone Number',
      'saveChanges': 'Save Changes',

      // Notifications
      'enableNotifications': 'Notifications enabled',
      'disableNotifications': 'Notifications disabled',

      // Change Password
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmNewPassword': 'Confirm New Password',
      'updatePassword': 'Update Password',

      // Error Messages Change Password
      'errorCurrentPasswordRequired': 'Current password required',
      'errorNewPasswordRequired': 'New password required',
      'errorConfirmNewPasswordRequired': 'Please confirm password',
      'errorNewPasswordMismatch': 'Passwords don\'t match',

      // Success Messages Change Password
      'passwordChangeSuccess': 'Password changed successfully!',
      'passwordUpdateSuccess': 'Password updated successfully!',
      'passwordUpdated': 'Password updated successfully!',

      'about': 'About',
      'termsOfService': 'Terms of Service',
      'privacyPolicy': 'Privacy Policy',
      'yes': 'Yes',
      'no': 'No',

      // Login
      'loginTitle': 'Sign In to Your Account',
      'loginSubtitle':
          'Sign in to your existing account to entering your details.',
      'loginNumber': 'Phone Number',
      'loginPassword': 'Password',
      'loginButton': 'Sign In',
      'loginForgotPassword': 'Forgot Password?',
      'loginCreateAccount': 'Create a New Account',
      'dontHaveAccount': 'Don\'t have an account?',
      'orContinueWith': 'Or continue with',

      // Error Messages Login
      'errorPhoneNumberRequired': 'Phone number is required',
      'errorPasswordRequired': 'Password is required',

      // Sign Up
      'signupTitle': 'Create your Account',
      'signupSubtitle': 'Create a new account to start enjoying our services.',
      'signupFullName': 'Full Name',
      'signupEmail': 'Email Address',
      'signupPhoneNumber': 'Phone Number',
      'signupPassword': 'Password',
      'signupConfirmPassword': 'Confirm Password',
      'signupButton': 'Sign Up',
      'signupAlreadyHaveAccount': 'Already have an account?',
      'signupLogin': 'Sign In',

      // Error Messages Sign Up
      'errorFullNameRequired': 'Full name is required',
      'errorEmailRequired': 'Email address is required',

      // Invalid
      'invalidEmail': 'Invalid email address',
      'invalidPhoneNumber': 'Invalid phone number',
      'invalidPassword': 'Invalid password',
      'invalidPhoneOrPassword': 'Invalid phone or password',

      // Min Characters
      'min6Characters': 'Minimum 6 characters required',

      // Error Toast
      'errorGeneral': 'Please correct the errors above.',

      // Welcome Message
      'welcomeBack': 'Welcome Back!',
      'welcomeMessage': 'We are glad to see you again.',

      // Varification Code
      'verificationCode': 'Verification Code',
      'verificationSubTitle': 'Please enter the verification code sent to',
      'dontReceiveCode': 'Didn\'t receive code?',
      'resendCode': 'Resend Code',
      'enterCode': 'Please enter the full code.',
      'invalidCode': 'Invalid code, please try again.',
      'verificationCodeRequired': 'Verification code is required',
      'resendIn': 'Resend in',
      'verifyYourNumber': 'Verify your number',

      // Language
      'languageChangedTo': 'Language changed to',

      // Premium
      'premiumSubscription': 'Premium Subscription',
      'premium': 'Premium',
      'bodyPremium':
          'Full HD movies without ads, unlimited access, previews of new releases.',
      'bodyPremium2': 'Enjoy Full HD movies without any restrictions or ads.',
      'fullHD': 'Full HD movies',
      'NoAds': 'No ads,',
      'UnlimitedAccess': 'Unlimited access,',
      'Previews': 'Previews of new releases,',
      'subscribeNow': 'Subscribe now',
      'month': 'month',

      "profilePictureUpdated": "Profile picture updated successfully",
      "profilePictureUpdateFailed": "Failed to update profile picture",
      "profilePicturePickFailed": "Failed to pick image"
    },
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------
    'fr': {
      "title": "Films Illimités",
      "subtitle": "Regardez partout. Annulez à tout moment.",
      "description":
          "Prêt à regarder ? Appuyez sur le bouton ci-dessous pour commencer votre abonnement.",
      "popular": "Populaire sur ABBEAV",
      "login": "Se Connecter",
      "changeLanguage": "Français",
      "latests": "Nouveautés",
      "seeAll": "Voir Tout",
      "trending": "Tendances",
      "topMovies": "Meilleurs Films",
      "newMovies": "Nouveaux Films",
      "downloads": "Téléchargements",
      "settings": "Paramètres",
      "language": "Langue",
      "darkMode": "Mode Sombre",
      "seasons": "Saisons",
      "episodes": "Épisodes",
      "watchNow": "Regarder Maintenant",
      "continueWatching": "Continuer à Regarder",
      "noResultsFound": "Aucun résultat trouvé",
      "play": "Lire",
      "pause": "Pause",
      "stop": "Arrêter",
      "replay": "Revoir",
      "addToList": "Ajouter à la Liste",
      "home": "Accueil",
      "search": "Recherche",
      "myList": "Ma Liste",
      "profile": "Profil",
      "homeTitle": "Bienvenue sur ABBEAV",
      'popularsActors': 'Acteurs populaires',
      "buyYourTickets": "Achetez vos billets",
      "bodyMessage":
          "Plongez dans le monde magique du cinéma ! Réservez vos billets en ligne sur ABBEAV et profitez d'une expérience inoubliable. Des blockbusters aux films d'auteur, il y en a pour tous les goûts. Trouvez votre prochaine aventure sur grand écran.",
      "searchHint": "Rechercher des films, séries ou acteurs",
      "actors": "Acteurs",
      "moviesSeries": "Films & Séries",
      "category": "Catégorie",
      "all": "Tous",
      "movies": "Films",
      "series": "Séries",
      "documentaries": "Documentaires",
      "genre": "Genre",
      "action": "Action",
      "scienceFiction": "Science-Fiction",
      "thriller": "Thriller",
      "reset": "Réinitialiser",
      "apply": "Appliquer",
      "myListEmpty": "Votre liste est vide",
      "addToMyList": "Ajouter à Ma Liste",
      "watching": "En cours",
      "watched": "Vu",
      "watchingList": "Liste En Cours",
      "watchedList": "Liste des Vus",
      "downloaded": "Téléchargé",
      "downloadedList": "Liste des Téléchargements",
      "downloading": "Téléchargement",
      "queuedForDownload": "En attente de Téléchargement",
      "downloadFailed": "Échec du Téléchargement",
      "downloadSuccess": "Téléchargement Réussi",
      "tapToDownload": "Appuyer pour Télécharger",
      "tapToRetry": "Appuyer pour Réessayer",
      "removeFromList": "Retirer de la Liste",
      "removeFromWatchingList": "Retirer de la Liste En Cours",
      "removeFromMyList": "Retirer de Ma Liste",
      "deletedSuccessfully": "Supprimé avec Succès",
      "downloadNotCompletedYet": "Téléchargement pas encore terminé",
      "downloadInProgress": "Téléchargement en Cours",
      "editProfilePicture": "Modifier la Photo de Profil",
      "settingsTitle": "Paramètres",
      "account": "Compte",
      "editProfile": "Modifier le Profil",
      "languageChange": "Changer de Langue",
      "changePassword": "Changer le Mot de Passe",
      "notifications": "Notifications",
      "logout": "Déconnexion",
      "confirmLogout": "Confirmer la Déconnexion",
      "logoutMessage": "Êtes-vous sûr de vouloir vous déconnecter ?",
      "cancel": "Annuler",
      "fullName": "Nom Complet",
      "emailAddress": "Adresse Email",
      "phoneNumber": "Numéro de Téléphone",
      "saveChanges": "Enregistrer les Modifications",
      "enableNotifications": "Notifications activées",
      "disableNotifications": "Notifications désactivées",
      "currentPassword": "Mot de Passe Actuel",
      "newPassword": "Nouveau Mot de Passe",
      "confirmNewPassword": "Confirmer le Nouveau Mot de Passe",
      "updatePassword": "Mettre à Jour le Mot de Passe",
      "errorCurrentPasswordRequired": "Mot de passe actuel requis",
      "errorNewPasswordRequired": "Nouveau mot de passe requis",
      "errorConfirmNewPasswordRequired": "Veuillez confirmer le mot de passe",
      "errorNewPasswordMismatch": "Les mots de passe ne correspondent pas",
      "passwordChangeSuccess": "Mot de passe changé avec succès !",
      "passwordUpdateSuccess": "Mot de passe mis à jour avec succès !",
      "passwordUpdated": "Mot de passe mis à jour avec succès !",
      "about": "À Propos",
      "termsOfService": "Conditions d'Utilisation",
      "privacyPolicy": "Politique de Confidentialité",
      "yes": "Oui",
      "no": "Non",
      "loginTitle": "Connectez-vous à Votre Compte",
      "loginSubtitle":
          "Connectez-vous à votre compte existant en entrant vos informations.",
      "loginNumber": "Numéro de Téléphone",
      "loginPassword": "Mot de Passe",
      "loginButton": "Se Connecter",
      "loginForgotPassword": "Mot de Passe Oublié ?",
      "loginCreateAccount": "Créer un Nouveau Compte",
      "dontHaveAccount": "Vous n'avez pas de compte ?",
      "orContinueWith": "Ou continuer avec",
      "errorPhoneNumberRequired": "Le numéro de téléphone est requis",
      "errorPasswordRequired": "Le mot de passe est requis",
      "signupTitle": "Créez votre Compte",
      "signupSubtitle":
          "Créez un nouveau compte pour commencer à profiter de nos services.",
      "signupFullName": "Nom Complet",
      "signupEmail": "Adresse Email",
      "signupPhoneNumber": "Numéro de Téléphone",
      "signupPassword": "Mot de Passe",
      "signupConfirmPassword": "Confirmer le Mot de Passe",
      "signupButton": "S'inscrire",
      "signupAlreadyHaveAccount": "Vous avez déjà un compte ?",
      "signupLogin": "Se Connecter",
      "errorFullNameRequired": "Le nom complet est requis",
      "errorEmailRequired": "L'adresse email est requise",

      // Invalid
      'invalidEmail': 'Adresse Email invalide',
      'invalidPhoneNumber': 'Numéro de Téléphone invalide',
      'invalidPassword': 'Mot de Passe invalide',
      'invalidPhoneOrPassword': 'Numéro de Téléphone ou Mot de Passe invalide',

      // Min Characters
      'min6Characters': 'Minimum 6 caractères requis',

      // Error Toast
      'errorGeneral': 'Veuillez corriger les erreurs ci-dessus.',

      // Welcome Message
      'welcomeBack': 'Bienvenue de nouveau !',
      'welcomeMessage': 'Nous sommes heureux de vous revoir.',

      // Varification Code
      'verificationCode': 'Code de Vérification',
      'verificationSubTitle':
          'Veuillez entrer le code de vérification envoyé à',
      'dontReceiveCode': 'Vous n\'avez pas reçu de code ?',
      'resendCode': 'Renvoyer le Code',
      'enterCode': 'Veuillez entrer le code complet.',
      'invalidCode': 'Code invalide, veuillez réessayer.',
      'verificationCodeRequired': 'Le code de vérification est requis.',
      'resendIn': 'Renvoyer dans',
      'verifyYourNumber': 'Vérifier votre Numéro',

      // Language
      'languageChangedTo': 'Langue modifiée en',

      // Premium
      'premiumSubscription': 'Abonnement Premium',
      'premium': 'Premium',
      'bodyPremium':
          'Films en Full HD sans publicité, accès illimité, avant-premières des nouvelles sorties.',
      'bodyPremium2':
          'Profitez de films en Full HD sans restrictions ni publicités.',
      'fullHD': 'Films en Full HD',
      'NoAds': 'Sans publicité,',
      'UnlimitedAccess': 'Accès illimité,',
      'Previews': 'Avant-premières des nouveautés,',
      'subscribeNow': 'S\'abonner maintenant',
      'month': 'mois',

      "profilePictureUpdated": "Photo de profil mise à jour avec succès",
      "profilePictureUpdateFailed":
          "Échec de la mise à jour de la photo de profil",
      "profilePicturePickFailed": "Échec de la sélection de l’image"
    },
  };

  String? get profilePictureUpdated {
    return _localizedValues[locale.languageCode]?['profilePictureUpdated'];
  }

  String? get profilePictureUpdateFailed {
    return _localizedValues[locale.languageCode]?['profilePictureUpdateFailed'];
  }

  String? get profilePicturePickFailed {
    return _localizedValues[locale.languageCode]?['profilePicturePickFailed'];
  }

  String? get title {
    return _localizedValues[locale.languageCode]?['title'];
  }

  String? get subtitle {
    return _localizedValues[locale.languageCode]?['subtitle'];
  }

  String? get description {
    return _localizedValues[locale.languageCode]?['description'];
  }

  String? get popular {
    return _localizedValues[locale.languageCode]?['popular'];
  }

  String? get login {
    return _localizedValues[locale.languageCode]?['login'];
  }

  String? get changeLanguage {
    return _localizedValues[locale.languageCode]?['changeLanguage'];
  }

  String? get latests {
    return _localizedValues[locale.languageCode]?['latests'];
  }

  String? get seeAll {
    return _localizedValues[locale.languageCode]?['seeAll'];
  }

  String? get trending {
    return _localizedValues[locale.languageCode]?['trending'];
  }

  String? get topMovies {
    return _localizedValues[locale.languageCode]?['topMovies'];
  }

  String? get newMovies {
    return _localizedValues[locale.languageCode]?['newMovies'];
  }

  String? get downloads {
    return _localizedValues[locale.languageCode]?['downloads'];
  }

  String? get settings {
    return _localizedValues[locale.languageCode]?['settings'];
  }

  String? get language {
    return _localizedValues[locale.languageCode]?['language'];
  }

  String? get darkMode {
    return _localizedValues[locale.languageCode]?['darkMode'];
  }

  String? get seasons {
    return _localizedValues[locale.languageCode]?['seasons'];
  }

  String? get episodes {
    return _localizedValues[locale.languageCode]?['episodes'];
  }

  String? get watchNow {
    return _localizedValues[locale.languageCode]?['watchNow'];
  }

  String? get continueWatching {
    return _localizedValues[locale.languageCode]?['continueWatching'];
  }

  String? get noResultsFound {
    return _localizedValues[locale.languageCode]?['noResultsFound'];
  }

  String? get play {
    return _localizedValues[locale.languageCode]?['play'];
  }

  String? get pause {
    return _localizedValues[locale.languageCode]?['pause'];
  }

  String? get stop {
    return _localizedValues[locale.languageCode]?['stop'];
  }

  String? get replay {
    return _localizedValues[locale.languageCode]?['replay'];
  }

  String? get addToList {
    return _localizedValues[locale.languageCode]?['addToList'];
  }

  String? get home {
    return _localizedValues[locale.languageCode]?['home'];
  }

  String? get search {
    return _localizedValues[locale.languageCode]?['search'];
  }

  String? get myList {
    return _localizedValues[locale.languageCode]?['myList'];
  }

  String? get profile {
    return _localizedValues[locale.languageCode]?['profile'];
  }

  String? get homeTitle {
    return _localizedValues[locale.languageCode]?['homeTitle'];
  }

  String? get buyYourTickets {
    return _localizedValues[locale.languageCode]?['buyYourTickets'];
  }

  String? get bodyMessage {
    return _localizedValues[locale.languageCode]?['bodyMessage'];
  }

  String? get searchHint {
    return _localizedValues[locale.languageCode]?['searchHint'];
  }

  String? get actors {
    return _localizedValues[locale.languageCode]?['actors'];
  }

  String? get moviesSeries {
    return _localizedValues[locale.languageCode]?['moviesSeries'];
  }

  String? get category {
    return _localizedValues[locale.languageCode]?['category'];
  }

  String? get all {
    return _localizedValues[locale.languageCode]?['all'];
  }

  String? get movies {
    return _localizedValues[locale.languageCode]?['movies'];
  }

  String? get series {
    return _localizedValues[locale.languageCode]?['series'];
  }

  String? get documentaries {
    return _localizedValues[locale.languageCode]?['documentaries'];
  }

  String? get genre {
    return _localizedValues[locale.languageCode]?['genre'];
  }

  String? get action {
    return _localizedValues[locale.languageCode]?['action'];
  }

  String? get scienceFiction {
    return _localizedValues[locale.languageCode]?['scienceFiction'];
  }

  String? get thriller {
    return _localizedValues[locale.languageCode]?['thriller'];
  }

  String? get reset {
    return _localizedValues[locale.languageCode]?['reset'];
  }

  String? get apply {
    return _localizedValues[locale.languageCode]?['apply'];
  }

  String? get myListEmpty {
    return _localizedValues[locale.languageCode]?['myListEmpty'];
  }

  String? get addToMyList {
    return _localizedValues[locale.languageCode]?['addToMyList'];
  }

  String? get watching {
    return _localizedValues[locale.languageCode]?['watching'];
  }

  String? get watched {
    return _localizedValues[locale.languageCode]?['watched'];
  }

  String? get watchingList {
    return _localizedValues[locale.languageCode]?['watchingList'];
  }

  String? get watchedList {
    return _localizedValues[locale.languageCode]?['watchedList'];
  }

  String? get downloaded {
    return _localizedValues[locale.languageCode]?['downloaded'];
  }

  String? get downloadedList {
    return _localizedValues[locale.languageCode]?['downloadedList'];
  }

  String? get downloading {
    return _localizedValues[locale.languageCode]?['downloading'];
  }

  String? get queuedForDownload {
    return _localizedValues[locale.languageCode]?['queuedForDownload'];
  }

  String? get downloadFailed {
    return _localizedValues[locale.languageCode]?['downloadFailed'];
  }

  String? get downloadSuccess {
    return _localizedValues[locale.languageCode]?['downloadSuccess'];
  }

  String? get tapToDownload {
    return _localizedValues[locale.languageCode]?['tapToDownload'];
  }

  String? get tapToRetry {
    return _localizedValues[locale.languageCode]?['tapToRetry'];
  }

  String? get removeFromList {
    return _localizedValues[locale.languageCode]?['removeFromList'];
  }

  String? get removeFromWatchingList {
    return _localizedValues[locale.languageCode]?['removeFromWatchingList'];
  }

  String? get removeFromMyList {
    return _localizedValues[locale.languageCode]?['removeFromMyList'];
  }

  String? get deletedSuccessfully {
    return _localizedValues[locale.languageCode]?['deletedSuccessfully'];
  }

  String? get downloadNotCompletedYet {
    return _localizedValues[locale.languageCode]?['downloadNotCompletedYet'];
  }

  String? get downloadInProgress {
    return _localizedValues[locale.languageCode]?['downloadInProgress'];
  }

  String? get editProfilePicture {
    return _localizedValues[locale.languageCode]?['editProfilePicture'];
  }

  String? get settingsTitle {
    return _localizedValues[locale.languageCode]?['settingsTitle'];
  }

  String? get account {
    return _localizedValues[locale.languageCode]?['account'];
  }

  String? get editProfile {
    return _localizedValues[locale.languageCode]?['editProfile'];
  }

  String? get languageChange {
    return _localizedValues[locale.languageCode]?['languageChange'];
  }

  String? get changePassword {
    return _localizedValues[locale.languageCode]?['changePassword'];
  }

  String? get notifications {
    return _localizedValues[locale.languageCode]?['notifications'];
  }

  String? get logout {
    return _localizedValues[locale.languageCode]?['logout'];
  }

  String? get confirmLogout {
    return _localizedValues[locale.languageCode]?['confirmLogout'];
  }

  String? get logoutMessage {
    return _localizedValues[locale.languageCode]?['logoutMessage'];
  }

  String? get cancel {
    return _localizedValues[locale.languageCode]?['cancel'];
  }

  String? get fullName {
    return _localizedValues[locale.languageCode]?['fullName'];
  }

  String? get emailAddress {
    return _localizedValues[locale.languageCode]?['emailAddress'];
  }

  String? get phoneNumber {
    return _localizedValues[locale.languageCode]?['phoneNumber'];
  }

  String? get saveChanges {
    return _localizedValues[locale.languageCode]?['saveChanges'];
  }

  String? get enableNotifications {
    return _localizedValues[locale.languageCode]?['enableNotifications'];
  }

  String? get disableNotifications {
    return _localizedValues[locale.languageCode]?['disableNotifications'];
  }

  String? get currentPassword {
    return _localizedValues[locale.languageCode]?['currentPassword'];
  }

  String? get newPassword {
    return _localizedValues[locale.languageCode]?['newPassword'];
  }

  String? get confirmNewPassword {
    return _localizedValues[locale.languageCode]?['confirmNewPassword'];
  }

  String? get updatePassword {
    return _localizedValues[locale.languageCode]?['updatePassword'];
  }

  String? get errorCurrentPasswordRequired {
    return _localizedValues[locale.languageCode]
        ?['errorCurrentPasswordRequired'];
  }

  String? get errorNewPasswordRequired {
    return _localizedValues[locale.languageCode]?['errorNewPasswordRequired'];
  }

  String? get errorConfirmNewPasswordRequired {
    return _localizedValues[locale.languageCode]
        ?['errorConfirmNewPasswordRequired'];
  }

  String? get errorNewPasswordMismatch {
    return _localizedValues[locale.languageCode]?['errorNewPasswordMismatch'];
  }

  String? get passwordChangeSuccess {
    return _localizedValues[locale.languageCode]?['passwordChangeSuccess'];
  }

  String? get passwordUpdateSuccess {
    return _localizedValues[locale.languageCode]?['passwordUpdateSuccess'];
  }

  String? get passwordUpdated {
    return _localizedValues[locale.languageCode]?['passwordUpdated'];
  }

  String? get about {
    return _localizedValues[locale.languageCode]?['about'];
  }

  String? get termsOfService {
    return _localizedValues[locale.languageCode]?['termsOfService'];
  }

  String? get privacyPolicy {
    return _localizedValues[locale.languageCode]?['privacyPolicy'];
  }

  String? get yes {
    return _localizedValues[locale.languageCode]?['yes'];
  }

  String? get no {
    return _localizedValues[locale.languageCode]?['no'];
  }

  String? get loginTitle {
    return _localizedValues[locale.languageCode]?['loginTitle'];
  }

  String? get loginSubtitle {
    return _localizedValues[locale.languageCode]?['loginSubtitle'];
  }

  String? get loginNumber {
    return _localizedValues[locale.languageCode]?['loginNumber'];
  }

  String? get loginPassword {
    return _localizedValues[locale.languageCode]?['loginPassword'];
  }

  String? get loginButton {
    return _localizedValues[locale.languageCode]?['loginButton'];
  }

  String? get loginForgotPassword {
    return _localizedValues[locale.languageCode]?['loginForgotPassword'];
  }

  String? get loginCreateAccount {
    return _localizedValues[locale.languageCode]?['loginCreateAccount'];
  }

  String? get dontHaveAccount {
    return _localizedValues[locale.languageCode]?['dontHaveAccount'];
  }

  String? get orContinueWith {
    return _localizedValues[locale.languageCode]?['orContinueWith'];
  }

  String? get errorPhoneNumberRequired {
    return _localizedValues[locale.languageCode]?['errorPhoneNumberRequired'];
  }

  String? get errorPasswordRequired {
    return _localizedValues[locale.languageCode]?['errorPasswordRequired'];
  }

  String? get errorConfirmPasswordRequired {
    return _localizedValues[locale.languageCode]
        ?['errorConfirmPasswordRequired'];
  }

  String? get errorEmailAddressRequired {
    return _localizedValues[locale.languageCode]?['errorEmailAddressRequired'];
  }

  String? get signupTitle {
    return _localizedValues[locale.languageCode]?['signupTitle'];
  }

  String? get signupSubtitle {
    return _localizedValues[locale.languageCode]?['signupSubtitle'];
  }

  String? get signupButton {
    return _localizedValues[locale.languageCode]?['signupButton'];
  }

  String? get signupFullName {
    return _localizedValues[locale.languageCode]?['signupFullName'];
  }

  String? get signupEmail {
    return _localizedValues[locale.languageCode]?['signupEmail'];
  }

  String? get signupPhoneNumber {
    return _localizedValues[locale.languageCode]?['signupPhoneNumber'];
  }

  String? get signupPassword {
    return _localizedValues[locale.languageCode]?['signupPassword'];
  }

  String? get signupConfirmPassword {
    return _localizedValues[locale.languageCode]?['signupConfirmPassword'];
  }

  String? get signupAlreadyHaveAccount {
    return _localizedValues[locale.languageCode]?['signupAlreadyHaveAccount'];
  }

  String? get signupLogin {
    return _localizedValues[locale.languageCode]?['signupLogin'];
  }

  String? get errorFullNameRequired {
    return _localizedValues[locale.languageCode]?['errorFullNameRequired'];
  }

  String? get errorEmailRequired {
    return _localizedValues[locale.languageCode]?['errorEmailRequired'];
  }

  String? get invalidEmail {
    return _localizedValues[locale.languageCode]?['invalidEmail'];
  }

  String? get invalidPhoneNumber {
    return _localizedValues[locale.languageCode]?['invalidPhoneNumber'];
  }

  String? get min6Characters {
    return _localizedValues[locale.languageCode]?['min6Characters'];
  }

  String? get errorGeneral {
    return _localizedValues[locale.languageCode]?['errorGeneral'];
  }

  String? get invalidPassword {
    return _localizedValues[locale.languageCode]?['invalidPassword'];
  }

  String? get invalidPhoneOrPassword {
    return _localizedValues[locale.languageCode]?['invalidPhoneOrPassword'];
  }

  String? get welcomeBack {
    return _localizedValues[locale.languageCode]?['welcomeBack'];
  }

  String? get welcomeMessage {
    return _localizedValues[locale.languageCode]?['welcomeMessage'];
  }

  String? get verificationCode {
    return _localizedValues[locale.languageCode]?['verificationCode'];
  }

  String? get verificationSubTitle {
    return _localizedValues[locale.languageCode]?['verificationSubTitle'];
  }

  String? get dontReceiveCode {
    return _localizedValues[locale.languageCode]?['dontReceiveCode'];
  }

  String? get resendCode {
    return _localizedValues[locale.languageCode]?['resendCode'];
  }

  String? get enterCode {
    return _localizedValues[locale.languageCode]?['enterCode'];
  }

  String? get invalidCode {
    return _localizedValues[locale.languageCode]?['invalidCode'];
  }

  String? get verificationCodeRequired {
    return _localizedValues[locale.languageCode]?['verificationCodeRequired'];
  }

  String? get resendIn {
    return _localizedValues[locale.languageCode]?['resendIn'];
  }

  String? get verifyYourNumber {
    return _localizedValues[locale.languageCode]?['verifyYourNumber'];
  }

  String? get popularsActors {
    return _localizedValues[locale.languageCode]?['popularsActors'];
  }

  String? get languageChangeTo {
    return _localizedValues[locale.languageCode]?['languageChangedTo'];
  }

  String? get premiumSubscription {
    return _localizedValues[locale.languageCode]?['premiumSubscription'];
  }

  String? get premium {
    return _localizedValues[locale.languageCode]?['premium'];
  }

  String? get bodyPremium {
    return _localizedValues[locale.languageCode]?['bodyPremium'];
  }

  String? get bodyPremium2 {
    return _localizedValues[locale.languageCode]?['bodyPremium2'];
  }

  String? get fullHD {
    return _localizedValues[locale.languageCode]?['fullHD'];
  }

  String? get noAds {
    return _localizedValues[locale.languageCode]?['NoAds'];
  }

  String? get unlimitedAccess {
    return _localizedValues[locale.languageCode]?['UnlimitedAccess'];
  }

  String? get previews {
    return _localizedValues[locale.languageCode]?['Previews'];
  }

  String? get subscribeNow {
    return _localizedValues[locale.languageCode]?['subscribeNow'];
  }

  String? get month {
    return _localizedValues[locale.languageCode]?['month'];
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
