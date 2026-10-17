class LegalDocumentModel {
  final int id;
  final String slug;
  final String title;
  final String category;
  final String? version;
  final String? effectiveDate;
  final String? effectiveDateFormatted;
  final String? summary;
  final String? contentMarkdown;
  final String? contentHtml;
  final DateTime? updatedAt;

  LegalDocumentModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    this.version,
    this.effectiveDate,
    this.effectiveDateFormatted,
    this.summary,
    this.contentMarkdown,
    this.contentHtml,
    this.updatedAt,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Legal Policy',
      category: json['category']?.toString() ?? 'Governance',
      version: json['version']?.toString() ?? json['current_version']?.toString(),
      effectiveDate: json['effective_date']?.toString(),
      effectiveDateFormatted: json['effective_date_formatted']?.toString(),
      summary: json['summary']?.toString(),
      contentMarkdown: json['content_markdown']?.toString() ?? json['content']?.toString(),
      contentHtml: json['content_html']?.toString(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}
