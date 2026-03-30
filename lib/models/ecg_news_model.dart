/// ECG News/Announcement Model
class ECGNews {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? source; // ECG, Government, etc.
  final String? areaAffected; // specific area or 'all' for nationwide
  final bool isActive;

  ECGNews({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.publishedAt,
    this.source = 'ECG',
    this.areaAffected = 'all',
    this.isActive = true,
  });

  factory ECGNews.fromJson(Map<String, dynamic> json, String id) {
    return ECGNews(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      publishedAt: DateTime.fromMillisecondsSinceEpoch(json['publishedAt'] ?? 0),
      source: json['source'] ?? 'ECG',
      areaAffected: json['areaAffected'] ?? 'all',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.millisecondsSinceEpoch,
      'source': source,
      'areaAffected': areaAffected,
      'isActive': isActive,
    };
  }

  String getTimeAgo() {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
  }
}
