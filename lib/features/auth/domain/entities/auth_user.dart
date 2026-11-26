import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.loggedInAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime loggedInAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'logged_in_at': loggedInAt.toIso8601String(),
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Pengguna',
        email: json['email']?.toString() ?? '',
        loggedInAt: DateTime.tryParse(json['logged_in_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  @override
  List<Object?> get props => [id, name, email, loggedInAt];
}
