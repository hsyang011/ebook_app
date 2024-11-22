import 'package:ebook_app/screens/global_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebook_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebase 초기화
  // SharedPreferences를 이용하여 저장된 테마 모드를 가져옵니다.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false; // 기본값을 설정할 수 있습니다.

  runApp(MyApp(initialDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool initialDarkMode;
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  const MyApp({super.key, required this.initialDarkMode});

  @override
  Widget build(BuildContext context) {
    // 초기 모드 설정
    themeNotifier.value = initialDarkMode ? ThemeMode.dark : ThemeMode.light;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          home: const Scaffold(
            body: Authentication(),
          ),
          // theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
        );
      },
    );
  }
}

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image(
                    image: AssetImage('assets/images/login.gif'),
                  ),
                ),
              );
            },
            providerConfigs: const [
              EmailProviderConfiguration()
            ],
          );
        }
        return const GlobalPage();
      },
    );
  }
}