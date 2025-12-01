class AdminModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? createdAt;

  AdminModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.createdAt,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}