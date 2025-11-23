class User {
  final int userId;
  final String userName;
  final String username;
  final int roleId;
  final String token;

  User({
    required this.userId,
    required this.userName,
    required this.username,
    required this.roleId,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      username: json['username'] ?? '',
      roleId: json['role_id'] ?? 0,
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'username': username,
      'role_id': roleId,
      'token': token,
    };
  }
}
