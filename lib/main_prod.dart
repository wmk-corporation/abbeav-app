import 'package:abbeav/controller/movie_controller.dart';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/firebase_options.dart';
import 'package:abbeav/upload_data.dart';
import 'package:abbeav/view/home/providers/user_provider.dart';
import 'package:abbeav/view/splash/screens/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abbeav/view/auth/providers/auth_provider.dart';
import 'package:abbeav/view/home/providers/landing_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> secureApp() async {
  try {
    await FlutterWindowManagerPlus.addFlags(
        FlutterWindowManagerPlus.FLAG_SECURE);
    await FlutterWindowManagerPlus.addFlags(
        FlutterWindowManagerPlus.FLAG_SECURE |
            FlutterWindowManagerPlus.FLAG_KEEP_SCREEN_ON);
  } catch (e) {
    //debugPrint("Erreur de sécurisation: $e");
  }
}

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'fr'].contains(locale.languageCode)) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  //await uploadAllMovies();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await secureApp();

  await FlutterDownloader.initialize(
      debug: false // optional: set to false for production
      );

  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language') ?? 'en';
  final locale = Locale(languageCode);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => LanguageProvider()..setLocale(locale)),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => LandingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
            create: (_) => UserProvider(firestore: FirebaseFirestore.instance)),
        Provider<MovieController>(
          create: (_) => MovieController(firestore: FirebaseFirestore.instance),
          //lazy: false,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //await secureApp();

  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language') ?? 'en';
  final locale = Locale(languageCode);

  //UserController().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider()..setLocale(locale),
      child: const MyApp(),
    ),
  );
}*/

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    FocusManager.instance.primaryFocus?.unfocus();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LandingProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ABBEAV',
        locale: languageProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: MaterialColor(
            0xFF5C61FF,
            <int, Color>{
              50: Color(0xFFE3E4FB),
              100: Color(0xFFB9BCF5),
              200: Color(0xFF8C91EF),
              300: Color(0xFF5C61FF),
              400: Color(0xFF474CDB),
              500: Color(0xFF3539B7),
              600: Color(0xFF262A93),
              700: Color(0xFF1A1D70),
              800: Color(0xFF10124D),
              900: Color(0xFF08082B),
            },
          ),
        ),
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          textTheme: GoogleFonts.figtreeTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
