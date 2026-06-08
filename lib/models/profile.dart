class Profile {
  final String id;
  final String fullName;
  final String? lastName;
  final String? avatarUrl;
  final String role;
  final String? bio;
  final String? institution;
  final String? semesterDegree;
  // Preferencias de notificación
  final bool notifAlertsReforma;
  final bool notifEmailResumen;
  final bool notifForo;
  final bool notifMentoria;

  Profile({
    required this.id,
    required this.fullName,
    this.lastName,
    this.avatarUrl,
    required this.role,
    this.bio,
    this.institution,
    this.semesterDegree,
    this.notifAlertsReforma = true,
    this.notifEmailResumen = true,
    this.notifForo = true,
    this.notifMentoria = true,
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
      notifAlertsReforma: json['notif_alerts_reforma'] ?? true,
      notifEmailResumen: json['notif_email_resumen'] ?? true,
      notifForo: json['notif_foro'] ?? true,
      notifMentoria: json['notif_mentoria'] ?? true,
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
      'notif_alerts_reforma': notifAlertsReforma,
      'notif_email_resumen': notifEmailResumen,
      'notif_foro': notifForo,
      'notif_mentoria': notifMentoria,
    };
  }

  Profile copyWith({
    String? fullName,
    String? lastName,
    String? bio,
    String? institution,
    String? semesterDegree,
    bool? notifAlertsReforma,
    bool? notifEmailResumen,
    bool? notifForo,
    bool? notifMentoria,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl,
      role: role,
      bio: bio ?? this.bio,
      institution: institution ?? this.institution,
      semesterDegree: semesterDegree ?? this.semesterDegree,
      notifAlertsReforma: notifAlertsReforma ?? this.notifAlertsReforma,
      notifEmailResumen: notifEmailResumen ?? this.notifEmailResumen,
      notifForo: notifForo ?? this.notifForo,
      notifMentoria: notifMentoria ?? this.notifMentoria,
    );
  }
}
