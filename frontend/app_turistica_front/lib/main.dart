import 'package:app_turistica_front/screens/helpcenter/help_center.dart';
import 'package:app_turistica_front/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home/home_screen.dart';
import 'package:app_turistica_front/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');

  if (token == null) {
    await prefs.clear();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: MyApp(initialRoute: token == null ? '/login' : '/home'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'App Turística',
      theme: themeService.currentTheme,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),  
        '/helpcenter': (context) => const HelpCenter(),
      },
    );
  }
}