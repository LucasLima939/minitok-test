import 'package:flutter/material.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/files/file_list_page.dart';
import '../pages/files/file_detail_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String fileList = '/files';
  static const String fileDetail = '/file_detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case fileList:
        return MaterialPageRoute(builder: (_) => const FileListPage());
      case fileDetail:
        final String fileId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => FileDetailPage(fileId: fileId));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
