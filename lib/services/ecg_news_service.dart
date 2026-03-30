import 'package:firebase_database/firebase_database.dart';
import '../models/ecg_news_model.dart';

/// Service for fetching ECG news from Realtime Database
class ECGNewsService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Stream of all active news (real-time updates)
  Stream<List<ECGNews>> getActiveNews() {
    return _database
        .child('ecg_news')
        .orderByChild('isActive')
        .equalTo(true)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final news = data.entries
          .map((e) => ECGNews.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                e.key as String,
              ))
          .toList();

      // Sort by published date (newest first)
      news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return news;
    });
  }

  /// Get news for a specific area + nationwide news
  Stream<List<ECGNews>> getNewsForArea(String areaId) {
    return _database.child('ecg_news').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final news = data.entries
          .where((e) {
            final value = e.value as Map<dynamic, dynamic>;
            final isActive = value['isActive'] ?? false;
            final areaAffected = value['areaAffected'] as String? ?? 'all';
            return isActive &&
                (areaAffected == 'all' ||
                    areaAffected.toLowerCase().replaceAll(' ', '_') == areaId);
          })
          .map((e) => ECGNews.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                e.key as String,
              ))
          .toList();

      news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return news;
    });
  }

  /// Get single news item by ID
  Future<ECGNews?> getNewsById(String newsId) async {
    final snapshot = await _database.child('ecg_news').child(newsId).get();
    if (snapshot.exists && snapshot.value != null) {
      return ECGNews.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        newsId,
      );
    }
    return null;
  }
}
