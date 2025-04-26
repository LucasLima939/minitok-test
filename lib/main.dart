import 'package:flutter/material.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/pages/auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniTok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.login,
      home: const LoginPage(),
    );
  }
}
