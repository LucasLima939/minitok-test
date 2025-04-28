import 'package:flutter/material.dart';
import 'package:minitok_test/domain/entities/file_item.dart';
import '../pages/register/login_page.dart';
import '../pages/register/signup_page.dart';
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
        final FileItem file = settings.arguments as FileItem;
        return MaterialPageRoute(builder: (_) => FileDetailPage(file: file));
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
