import 'package:fading_fame/core/app_routes.dart';
import 'package:fading_fame/ui/screens/admin/manage_admins_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_error_view.dart';
import 'manage_categories_screen.dart';
import 'manage_posts_screen.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminProvider>().loadAllAdminData();
      if (mounted) setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();

    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('You are not allowed to access admin panel')),
      );
    }

    if (!_initialized || admin.isLoading) {
      return const Scaffold(
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
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// ---------------- CATEGORIES ----------------
          admin.categories.isEmpty
              ? _EmptyState(
            image: 'assets/images/empty_categories.svg',
            title: 'No categories yet',
            subtitle:
            'You need at least one category before creating posts.',
            ctaText: 'Create category',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                ),
              );
            },
          )
              : const ManageCategoriesScreen(),

          /// ---------------- POSTS ----------------
          admin.posts.isEmpty
              ? _EmptyState(
            image: 'assets/images/empty_posts.svg',
            title: 'No posts yet',
            subtitle:
            'Once posts are created, they will appear here.',
            ctaText: 'Create post',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createPost);
            },
          )
              : const ManagePostsScreen(),

          /// ---------------- USERS (FIXED) ----------------
          admin.users.isEmpty
              ? _EmptyState(
            image: 'assets/images/empty_admins.svg',
            title: 'No users found',
            subtitle: 'Users will appear here once they sign up.',
            ctaText: 'Okay',
            onPressed: () {},
          )
              : ManageAdminsScreen(),
        ],
      ),
    );
  }
}

class _UsersRoleManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: admin.users.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final user = admin.users[index];

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(user.fullName ?? 'Unnamed user'),
          subtitle: Text(user.role),
          trailing: DropdownButton<String>(
            value: user.role,
            items: const [
              DropdownMenuItem(value: 'visitor', child: Text('Visitor')),
              DropdownMenuItem(value: 'coadmin', child: Text('Co-Admin')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (role) {
              if (role == null) return;
              context
                  .read<AdminProvider>()
                  .changeUserRole(user.id, role);
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback onPressed;

  const _EmptyState({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(image, height: 180,),
            const SizedBox(height: 24),

            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(ctaText),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

