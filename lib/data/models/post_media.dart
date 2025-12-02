class PostMedia {
  final int id;
  final int postId;
  final String mediaUrl;
  final String mediaType; // image | video
  final int position;
  final String? caption;

  const PostMedia({
    required this.id,
    required this.postId,
    required this.mediaUrl,
    required this.mediaType,
    required this.position,
    this.caption,
  });

  factory PostMedia.fromMap(Map<String, dynamic> map) {
    return PostMedia(
      id: map['id'] as int,
      postId: map['post_id'] as int,
      mediaUrl: map['media_url'] as String,
      mediaType: map['media_type'] as String,
      position: map['position'] as int? ?? 0,
      caption: map['caption'] as String?,
    );
  }
}
