import 'legal_code.dart';

class LegalArticle {
  final String id;
  final String codeId;
  final String number;
  final String title;
  final String content;
  final DateTime? lastReformDate;
  final String? sourceOfficial;
  final String? summaryReform;
  final bool hasRecentReform;
  final LegalCode? code;

  LegalArticle({
    required this.id,
    required this.codeId,
    required this.number,
    required this.title,
    required this.content,
    this.lastReformDate,
    this.sourceOfficial,
    this.summaryReform,
    this.hasRecentReform = false,
    this.code,
  });

  factory LegalArticle.fromJson(Map<String, dynamic> json) {
    return LegalArticle(
      id: json['id'],
      codeId: json['code_id'],
      number: json['number'],
      title: json['title'],
      content: json['content'],
      lastReformDate: json['last_reform_date'] != null
          ? DateTime.parse(json['last_reform_date'])
          : null,
      sourceOfficial: json['source_official'],
      summaryReform: json['summary_reform'],
      hasRecentReform: json['has_recent_reform'] ?? false,
      code: json['legal_codes'] != null
          ? LegalCode.fromJson(json['legal_codes'])
          : null,
    );
  }
}
