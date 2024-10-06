import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_page.dart';
import 'models/user_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => UserData()), // Provide user data across the app
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Erasmus Money Manager',
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: const AuthPage(),
      ),
    );
  }
}
