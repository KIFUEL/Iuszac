import 'profile.dart';

class Mentor {
  final String id;
  final String specialty;
  final String? whatsappNumber;
  final String? emailContact;
  final int experienceYears;
  final bool isVerified;
  final Profile? profile;

  Mentor({
    required this.id,
    required this.specialty,
    this.whatsappNumber,
    this.emailContact,
    required this.experienceYears,
    this.isVerified = false,
    this.profile,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'],
      specialty: json['specialty'] ?? '',
      whatsappNumber: json['whatsapp_number'],
      emailContact: json['email_contact'],
      experienceYears: json['experience_years'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      profile: json['profiles'] != null 
          ? Profile.fromJson(json['profiles']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specialty': specialty,
      'whatsapp_number': whatsappNumber,
      'email_contact': emailContact,
      'experience_years': experienceYears,
      'is_verified': isVerified,
    };
  }
}
