import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_error_view.dart';
import 'manage_categories_screen.dart';
import 'manage_posts_screen.dart' hide ManageCategoriesScreen;
import 'manage_admins_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllAdminData().then((_) {
        setState(() {
          _initialized = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();

    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('You are not allowed to access admin panel.'),
        ),
      );
    }


    if (!_initialized || admin.isLoading && admin.categories.isEmpty) {
      return Scaffold(
        body: AppLoader(message: 'Loading admin data...'),
      );
    }

    if (admin.error != null) {
      return Scaffold(
        body: AppErrorView(
          message: admin.error!,
          onRetry: () => admin.loadAllAdminData(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Posts'),
            Tab(text: 'Admins'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ManageCategoriesScreen(),
          ManagePostsScreen(),
          ManageAdminsScreen(),
        ],
      ),
    );
  }
}
