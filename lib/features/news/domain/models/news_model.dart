class NewsInfo {
  const NewsInfo({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl = '',
    this.source = '',
    this.category = '',
    this.publishedAt,
    this.author = '',
    this.externalUrl = '',
  });

  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String source;
  final String category;
  final DateTime? publishedAt;
  final String author;
  final String externalUrl;

  bool get hasContent => content.trim().isNotEmpty;
  bool get hasImage => imageUrl.trim().isNotEmpty;
  String get displaySource => source.isNotEmpty ? source : 'Fover News';
  String get readTimeLabel {
    final wordCount = content.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final minutes = (wordCount / 220).ceil().clamp(1, 99);
    return '$minutes min read';
  }

  String get publishedTimeLabel {
    if (publishedAt == null) return '';
    final difference = DateTime.now().difference(publishedAt!);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
  }

  factory NewsInfo.fromJson(Map<String, dynamic> json) {
    return NewsInfo(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? json['headline'] as String? ?? '',
      content: json['content'] as String? ?? json['body'] as String? ?? json['summary'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? json['thumbnail'] as String? ?? '',
      source: json['source'] as String? ?? json['publisher'] as String? ?? '',
      category: json['category'] as String? ?? '',
      publishedAt: _parseDate(json['published_at'] ?? json['publishedAt']),
      author: json['author'] as String? ?? '',
      externalUrl: json['external_url'] as String? ?? json['externalUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'source': source,
      'category': category,
      'published_at': publishedAt?.toIso8601String(),
      'author': author,
      'external_url': externalUrl,
    };
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
