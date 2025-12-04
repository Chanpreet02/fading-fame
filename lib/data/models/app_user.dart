// class AppUser {
//   final String id;
//   final String fullName;
//   final String email;
//   final int? age;
//   final String role;
//
//   AppUser({
//     required this.id,
//     required this.fullName,
//     required this.email,
//     this.age,
//     required this.role,
//   });
//
//   factory AppUser.fromMap(Map<String, dynamic> map) {
//     return AppUser(
//       id: map['id'] as String,
//       fullName: map['full_name'] as String? ?? '',
//       email: map['email'] as String? ?? '',
//       age: map['age'] as int?,
//       role: map['role'] as String? ?? 'visitor',
//     );
//   }
//
//   bool get isAdmin => role == 'admin';
//   bool get isClient => role == 'client';
//   bool get isStaff => isAdmin || isClient;
// }

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final int? age;
  final String role;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.age,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: map['age'] as int?,
      role: map['role'] as String? ?? 'visitor',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'age': age,
      'role': role,
    };
  }
}
