import 'post_media.dart';

class Post {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final int categoryId;
  final String authorId;
  final String status;
  final String? coverImageUrl;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PostMedia> media;

  const Post({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    required this.categoryId,
    required this.authorId,
    required this.status,
    this.coverImageUrl,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.media = const [],
  });

  Post copyWith({List<PostMedia>? media}) {
    return Post(
      id: id,
      title: title,
      slug: slug,
      excerpt: excerpt,
      content: content,
      categoryId: categoryId,
      authorId: authorId,
      status: status,
      coverImageUrl: coverImageUrl,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      media: media ?? this.media,
    );
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int,
      title: map['title'] as String,
      slug: map['slug'] as String,
      excerpt: map['excerpt'] as String?,
      content: map['content'] as String?,
      categoryId: map['category_id'] as int,
      authorId: map['author_id'] as String,
      status: map['status'] as String,
      coverImageUrl: map['cover_image_url'] as String?,
      publishedAt: map['published_at'] != null
          ? DateTime.parse(map['published_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      media: const [],
    );
  }
}
