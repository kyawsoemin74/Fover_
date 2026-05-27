class AdInfo {
  const AdInfo({
    required this.id,
    required this.type,
    required this.content,
    this.imageUrl,
    this.targetUrl,
  });

  final String id;
  final String type;
  final String content;
  final String? imageUrl;
  final String? targetUrl;

  factory AdInfo.fromJson(Map<String, dynamic> json) {
    return AdInfo(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image'] as String? ?? json['image_url'] as String?,
      targetUrl: json['target_url'] as String? ?? json['targetUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'image': imageUrl,
      'target_url': targetUrl,
    };
  }
}
