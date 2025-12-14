import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/commonMethods/createCategory.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/admin/category_list_item.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Column(
      children: [
        /// 🔹 TOP ACTION
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => showCreateDialog(
                nameController: _nameController,
                descController: _descController,
                context: context,
              ),
              icon: const Icon(Icons.add),
              label: const Text('New Category'),
            ),
          ),
        ),

        /// 🔹 CONTENT
        Expanded(
          child: admin.categories.isEmpty
              ? _EmptyCategoriesView(
            onCreate: () => showCreateDialog(
              nameController: _nameController,
              descController: _descController,
              context: context,
            ),
          )
              : ListView.builder(
            itemCount: admin.categories.length,
            itemBuilder: (context, index) {
              final cat = admin.categories[index];
              return CategoryListItem(
                category: cat,
                onToggleVisibility: () =>
                    admin.toggleCategoryVisibility(cat),
              );
            },
          ),
        ),
      ],
    );
  }
}
class _EmptyCategoriesView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyCategoriesView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_open,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),

            Text(
              'No categories yet',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Text(
              'Create a category to organize your posts.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create category'),
            ),
          ],
        ),
      ),
    );
  }
}
