import 'profile.dart';

class MentorshipSession {
  final String id;
  final String mentorId;
  final String title;
  final String? description;
  final String specialty;
  final double price;
  final int availableSlots;
  final dynamic schedule;
  final bool isCommunityVerified;
  final DateTime createdAt;
  final DateTime sessionDate;
  final DateTime? expiresAt;
  final Profile? mentor;
  final double rating;
  final int reviewCount;

  MentorshipSession({
    required this.id,
    required this.mentorId,
    required this.title,
    this.description,
    required this.specialty,
    this.price = 0,
    this.availableSlots = 10,
    this.schedule,
    this.isCommunityVerified = false,
    required this.createdAt,
    required this.sessionDate,
    this.expiresAt,
    this.mentor,
    this.rating = 0,
    this.reviewCount = 0,
  });

  factory MentorshipSession.fromJson(Map<String, dynamic> json) {
    return MentorshipSession(
      id: json['id'],
      mentorId: json['mentor_id'],
      title: json['title'] ?? '',
      description: json['description'],
      specialty: json['specialty'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      availableSlots: json['available_slots'] ?? 0,
      schedule: json['schedule'],
      isCommunityVerified: json['is_community_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      sessionDate: json['session_date'] != null 
          ? DateTime.parse(json['session_date']) 
          : (json['expires_at'] != null ? DateTime.parse(json['expires_at']) : DateTime.now()),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      mentor: json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  String get scheduleDisplay {
    if (schedule == null) return '';

    const dayAbbreviations = {
      'Lunes': 'Lun',
      'Martes': 'Mar',
      'Miércoles': 'Mié',
      'Jueves': 'Jue',
      'Viernes': 'Vie',
      'Sábado': 'Sáb',
      'Domingo': 'Dom',
    };

    // New format: List of slots (for custom/split daily schedules)
    if (schedule is List) {
      final list = schedule as List;
      final Map<String, List<String>> grouped = {};
      
      for (var item in list) {
        if (item is Map) {
          final day = item['day'] as String?;
          final start = item['startTime'] as String?;
          final end = item['endTime'] as String?;
          if (day != null && start != null && end != null) {
            grouped.putIfAbsent(day, () => []).add('$start-$end');
          }
        }
      }

      if (grouped.isEmpty) return '';

      final daysOrder = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      final List<String> parts = [];
      for (var day in daysOrder) {
        if (grouped.containsKey(day)) {
          final abbr = dayAbbreviations[day] ?? day;
          final times = grouped[day]!.join(', ');
          parts.add('$abbr: $times');
        }
      }
      return parts.join(' | ');
    }

    // Legacy format: Map {"days": [], "startTime": "", "endTime": ""}
    if (schedule is Map) {
      final days = (schedule!['days'] as List<dynamic>?)
          ?.map((d) => dayAbbreviations[d] ?? d.toString())
          .join(', ');
      final startTime = schedule!['startTime'] as String?;
      final endTime = schedule!['endTime'] as String?;

      if (days == null || days.isEmpty) return '';
      if (startTime != null && endTime != null) {
        return '$days · $startTime - $endTime';
      }
      return days;
    }

    return '';
  }
}
