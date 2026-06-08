class LegalCode {
  final String id;
  final String name;
  final String? icon;
  final String status;
  final DateTime createdAt;
  final int? articleCount;
  final String? shortName;
  final String? scope;
  final String? description;
  final DateTime? lastReformDate;

  LegalCode({
    required this.id,
    required this.name,
    this.icon,
    required this.status,
    required this.createdAt,
    this.articleCount,
    this.shortName,
    this.scope,
    this.description,
    this.lastReformDate,
  });

  factory LegalCode.fromJson(Map<String, dynamic> json) {
    return LegalCode(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      articleCount: json['article_count'],
      shortName: json['short_name'],
      scope: json['scope'],
      description: json['description'],
      lastReformDate: json['last_reform_date'] != null
          ? DateTime.parse(json['last_reform_date'])
          : null,
    );
  }
}
