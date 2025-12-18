import 'package:flutter/material.dart';

import '../ui/screens/admin/create_post_screen.dart';
import '../ui/screens/reset_password_screen/reset_password_screen.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/category/category_posts_screen.dart';
import '../ui/screens/post_detail/post_detail_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/admin/admin_dashboard_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const categoryPosts = '/category-posts';
  static const postDetail = '/post-detail';
  static const profile = '/profile';
  static const adminDashboard = '/admin';
  static const createPost = '/admin/create-post';
  static const resetPassword = '/reset-password';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case categoryPosts:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => CategoryPostsScreen(
              categoryId: args['categoryId'] as int,
              categoryName: args['categoryName'] as String,
            ));
      case postDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final postId = args['postId'] as int;
        return MaterialPageRoute(
            builder: (_) => PostDetailScreen(postId: postId));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case resetPassword:
        return MaterialPageRoute (builder: (_) => const ResetPasswordScreen());
      case createPost:
        return MaterialPageRoute(
          builder: (_) => const CreatePostScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
