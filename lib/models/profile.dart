class Profile {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String role; // 'admin', 'mentor', 'user'
  final String? bio;

  Profile({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.bio,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'] ?? 'Usuario',
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'user',
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'bio': bio,
    };
  }
}
