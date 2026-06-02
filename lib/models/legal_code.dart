class LegalCode {
  final String id;
  final String name;
  final String? icon;
  final String status;
  final DateTime createdAt;
  final int? articleCount;

  LegalCode({
    required this.id,
    required this.name,
    this.icon,
    required this.status,
    required this.createdAt,
    this.articleCount,
  });

  factory LegalCode.fromJson(Map<String, dynamic> json) {
    return LegalCode(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      articleCount: json['article_count'],
    );
  }
}
