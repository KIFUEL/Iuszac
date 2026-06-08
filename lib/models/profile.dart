class Profile {
  final String id;
  final String fullName;
  final String? lastName;
  final String? avatarUrl;
  final String userType;
  final String? label;
  final String? bio;
  final String? institution;
  final String? semesterDegree;
  final String? phoneWhatsapp;
  final bool isSuspended;
  final DateTime? suspendedUntil;
  final String? suspensionReason;
  // Preferencias de notificación
  final bool notifAlertsReforma;
  final bool notifEmailResumen;
  final bool notifForo;
  final bool notifMentoria;
  // Calificación agregada (para mentores)
  final double rating;
  final int reviewCount;

  Profile({
    required this.id,
    required this.fullName,
    this.lastName,
    this.avatarUrl,
    required this.userType,
    this.label,
    this.bio,
    this.institution,
    this.semesterDegree,
    this.phoneWhatsapp,
    this.isSuspended = false,
    this.suspendedUntil,
    this.suspensionReason,
    this.notifAlertsReforma = true,
    this.notifEmailResumen = true,
    this.notifForo = true,
    this.notifMentoria = true,
    this.rating = 0,
    this.reviewCount = 0,
  });

  String get role => userType;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'] ?? 'Usuario',
      lastName: json['last_name'],
      avatarUrl: json['avatar_url'],
      userType: json['user_type'] ?? json['role'] ?? 'user',
      label: json['label'],
      bio: json['bio'],
      institution: json['institution'],
      semesterDegree: json['semester_degree'],
      phoneWhatsapp: json['phone_whatsapp'],
      isSuspended: json['is_suspended'] ?? false,
      suspendedUntil: json['suspended_until'] != null
          ? DateTime.parse(json['suspended_until'])
          : null,
      suspensionReason: json['suspension_reason'],
      notifAlertsReforma: json['notif_alerts_reforma'] ?? true,
      notifEmailResumen: json['notif_email_resumen'] ?? true,
      notifForo: json['notif_foro'] ?? true,
      notifMentoria: json['notif_mentoria'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'user_type': userType,
      'label': label,
      'bio': bio,
      'institution': institution,
      'semester_degree': semesterDegree,
      'phone_whatsapp': phoneWhatsapp,
      'is_suspended': isSuspended,
      'suspended_until': suspendedUntil?.toIso8601String(),
      'suspension_reason': suspensionReason,
      'notif_alerts_reforma': notifAlertsReforma,
      'notif_email_resumen': notifEmailResumen,
      'notif_foro': notifForo,
      'notif_mentoria': notifMentoria,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  Profile copyWith({
    String? fullName,
    String? lastName,
    String? bio,
    String? institution,
    String? semesterDegree,
    String? phoneWhatsapp,
    String? userType,
    String? label,
    bool? isSuspended,
    DateTime? suspendedUntil,
    String? suspensionReason,
    bool? notifAlertsReforma,
    bool? notifEmailResumen,
    bool? notifForo,
    bool? notifMentoria,
    double? rating,
    int? reviewCount,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl,
      userType: userType ?? this.userType,
      label: label ?? this.label,
      bio: bio ?? this.bio,
      institution: institution ?? this.institution,
      semesterDegree: semesterDegree ?? this.semesterDegree,
      phoneWhatsapp: phoneWhatsapp ?? this.phoneWhatsapp,
      isSuspended: isSuspended ?? this.isSuspended,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      notifAlertsReforma: notifAlertsReforma ?? this.notifAlertsReforma,
      notifEmailResumen: notifEmailResumen ?? this.notifEmailResumen,
      notifForo: notifForo ?? this.notifForo,
      notifMentoria: notifMentoria ?? this.notifMentoria,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
