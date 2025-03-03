import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/sign_in_page.dart';
import 'theme/color_palettes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = getSelectedPalette(); // Get the manually selected theme

    return MaterialApp(
      title: 'Herd',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: colors['primary']!,
          secondary: colors['secondary']!,
          surface: colors['card']!,
          background: colors['background']!,
          onPrimary: Colors.white, // Text/icons on primary color
          onSecondary: Colors.black, // Text/icons on secondary color
        ),
        scaffoldBackgroundColor: colors['background'],
        cardColor: colors['card'],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors['accent'],
            foregroundColor: Colors.black,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colors['primary'],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: SignInPage(),
    );
  }
}
