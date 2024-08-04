class User {
  final String id;
  final String name;
  final String? email;
  final String password;
  final bool isActive;
  final Map<String, Map<String, bool>> modulePermissions;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.password,
    this.isActive = true,
    required this.modulePermissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'isActive': isActive,
      'modulePermissions': modulePermissions,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    Map<String, Map<String, bool>> permissions = {};
    if (map['modulePermissions'] != null) {
      map['modulePermissions'].forEach((module, perms) {
        permissions[module] = Map<String, bool>.from(perms);
      });
    }

    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      password: map['password'] ?? '',
      isActive: map['isActive'] ?? true,
      modulePermissions: permissions,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    bool? isActive,
    Map<String, Map<String, bool>>? modulePermissions,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      modulePermissions: modulePermissions ?? this.modulePermissions,
    );
  }
}
