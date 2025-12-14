import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

showCreateDialog({required TextEditingController nameController, required TextEditingController descController, required BuildContext context}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create Category'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {nameController.clear();descController.clear();
          Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final admin = context.read<AdminProvider>();
            await admin.createCategory(
              name: nameController.text.trim(),
              description: descController.text.trim().isEmpty
                  ? null
                  : descController.text.trim(),
            );
            nameController.clear();
            descController.clear();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}