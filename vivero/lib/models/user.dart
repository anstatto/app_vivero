class User {
  final String id;
  final String name;
  final String email;
  final bool isActive;
  final Map<String, bool> permissions;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.isActive = true,
    required this.permissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      isActive: map['isActive'],
      permissions: Map<String, bool>.from(map['permissions']),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isActive,
    Map<String, bool>? permissions,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }
}
