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
          onPrimary: colors['textDark']!, // Text/icons on primary color
          onSecondary: colors['textLight']!, // Text/icons on secondary color
        ),
        scaffoldBackgroundColor: colors['background'],
        cardColor: colors['card'],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors['accent'],
            foregroundColor: colors['textLight'],
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colors['primary'],
          titleTextStyle: TextStyle(color: colors['textLight'], fontSize: 20),
          iconTheme: IconThemeData(color: colors['textLight']),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SignInPage(),
    );
  }
}
