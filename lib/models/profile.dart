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
  // Permissions
  final bool canMentor;
  final bool canPublish;
  final bool canModerate;
  final bool canManageUsers;
  // Suspension
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
    this.canMentor = false,
    this.canPublish = false,
    this.canModerate = false,
    this.canManageUsers = false,
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
  bool get isAdmin => userType == 'admin';
  bool get isActivelySuspended => isSuspended && (suspendedUntil?.isAfter(DateTime.now()) ?? true);

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
      canMentor: json['can_mentor'] ?? false,
      canPublish: json['can_publish'] ?? false,
      canModerate: json['can_moderate'] ?? false,
      canManageUsers: json['can_manage_users'] ?? false,
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
      'can_mentor': canMentor,
      'can_publish': canPublish,
      'can_moderate': canModerate,
      'can_manage_users': canManageUsers,
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
    bool? canMentor,
    bool? canPublish,
    bool? canModerate,
    bool? canManageUsers,
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
      canMentor: canMentor ?? this.canMentor,
      canPublish: canPublish ?? this.canPublish,
      canModerate: canModerate ?? this.canModerate,
      canManageUsers: canManageUsers ?? this.canManageUsers,
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
