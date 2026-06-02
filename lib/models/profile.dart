class Profile {
  final String id;
  final String fullName;
  final String? lastName;
  final String? avatarUrl;
  final String role;
  final String? bio;
  final String? institution;
  final String? semesterDegree;

  Profile({
    required this.id,
    required this.fullName,
    this.lastName,
    this.avatarUrl,
    required this.role,
    this.bio,
    this.institution,
    this.semesterDegree,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'] ?? 'Usuario',
      lastName: json['last_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'user',
      bio: json['bio'],
      institution: json['institution'],
      semesterDegree: json['semester_degree'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'role': role,
      'bio': bio,
      'institution': institution,
      'semester_degree': semesterDegree,
    };
  }
}
