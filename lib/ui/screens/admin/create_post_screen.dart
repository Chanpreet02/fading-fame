import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/category_provider.dart';
import '../../../data/repositories/post_repository.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _excerptCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int? _selectedCategoryId;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isSubmitting = false;
  final _repo = PostRepository();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _excerptCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _imageName = file.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? coverUrl;
      if (_imageBytes != null && _imageName != null) {
        coverUrl = await _repo.uploadCoverImage(
          _imageBytes!,
          _imageName!,
        );
      }

      await _repo.createPost(
        title: _titleCtrl.text.trim(),
        excerpt: _excerptCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        categoryId: _selectedCategoryId!,
        coverImageUrl: coverUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _excerptCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Short excerpt'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    items: categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedCategoryId = v);
                    },
                    decoration:
                    const InputDecoration(labelText: 'Category'),
                    validator: (v) =>
                    v == null ? 'Select a category' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Content'),
                    maxLines: 8,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pick cover image'),
                      ),
                      const SizedBox(width: 12),
                      if (_imageName != null)
                        Expanded(
                          child: Text(
                            _imageName!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Text(
                        _isSubmitting ? 'Creating...' : 'Create Post',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
