class UserProfile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String role;

  const UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'visitor',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isCoAdmin => role == 'coadmin';
  bool get isStaff => isAdmin || isCoAdmin;
}
