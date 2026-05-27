class NewsInfo {
  const NewsInfo({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  factory NewsInfo.fromJson(Map<String, dynamic> json) {
    return NewsInfo(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}
