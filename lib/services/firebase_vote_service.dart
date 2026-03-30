import 'package:firebase_database/firebase_database.dart';
import '../screens/home_screen.dart';

/// Realtime Database service for managing power status votes
class FirebaseVoteService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Submit a vote for an area
  Future<void> submitVote(
      String areaId, PowerStatus status, String? userId) async {
    final voteRef = _database.child('votes').push();
    await voteRef.set({
      'areaId': areaId,
      'status': status == PowerStatus.on ? 'on' : 'off',
      'timestamp': ServerValue.timestamp,
      'userId': userId ?? 'anonymous',
    });
  }

  /// Get recent votes for an area (last 6 hours)
  Stream<List<VoteData>> getRecentVotes(String areaId) {
    final sixHoursAgo = DateTime.now().subtract(const Duration(hours: 6));
    final sixHoursAgoMillis = sixHoursAgo.millisecondsSinceEpoch;

    return _database.child('votes').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <VoteData>[];

      final votes = data.entries.where((entry) {
        final voteData = entry.value as Map<dynamic, dynamic>;
        final voteAreaId = voteData['areaId'] as String?;
        final timestamp = voteData['timestamp'] as int? ?? 0;
        return voteAreaId == areaId && timestamp > sixHoursAgoMillis;
      }).map((entry) {
        final voteData = entry.value as Map<dynamic, dynamic>;
        final timestamp = voteData['timestamp'] as int? ?? 0;
        return VoteData(
          status: voteData['status'] == 'on' ? PowerStatus.on : PowerStatus.off,
          timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
      }).toList();

      votes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return votes;
    });
  }

  /// Get all recent votes for crowd detection
  Future<List<VoteData>> getVotesForCrowdCheck(String areaId) async {
    final tenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 10));
    final tenMinutesAgoMillis = tenMinutesAgo.millisecondsSinceEpoch;

    final snapshot = await _database.child('votes').get();
    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.where((entry) {
      final voteData = entry.value as Map<dynamic, dynamic>;
      final voteAreaId = voteData['areaId'] as String?;
      final timestamp = voteData['timestamp'] as int? ?? 0;
      return voteAreaId == areaId && timestamp > tenMinutesAgoMillis;
    }).map((entry) {
      final voteData = entry.value as Map<dynamic, dynamic>;
      final timestamp = voteData['timestamp'] as int? ?? 0;
      return VoteData(
        status: voteData['status'] == 'on' ? PowerStatus.on : PowerStatus.off,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
    }).toList();
  }

  /// Remove user's last vote
  Future<void> removeLastVote(String areaId, String? userId) async {
    final snapshot = await _database.child('votes').get();
    if (!snapshot.exists || snapshot.value == null) {
      return;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    String? lastVoteKey;
    int? lastVoteTimestamp;

    for (final entry in data.entries) {
      final voteData = entry.value as Map<dynamic, dynamic>;
      final voteAreaId = voteData['areaId'] as String?;
      final voteUserId = voteData['userId'] as String?;
      final timestamp = voteData['timestamp'] as int? ?? 0;

      if (voteAreaId == areaId && voteUserId == (userId ?? 'anonymous')) {
        if (lastVoteTimestamp == null || timestamp > lastVoteTimestamp) {
          lastVoteTimestamp = timestamp;
          lastVoteKey = entry.key as String;
        }
      }
    }

    if (lastVoteKey != null) {
      await _database.child('votes').child(lastVoteKey).remove();
    }
  }

  /// Get current power status for an area
  Future<PowerStatus> getCurrentStatus(String areaId) async {
    final thirtyMinutesAgo =
        DateTime.now().subtract(const Duration(minutes: 30));
    final thirtyMinutesAgoMillis = thirtyMinutesAgo.millisecondsSinceEpoch;

    final snapshot = await _database.child('votes').get();
    if (!snapshot.exists || snapshot.value == null) {
      return PowerStatus.unknown;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    final recentVotes = data.entries.where((entry) {
      final voteData = entry.value as Map<dynamic, dynamic>;
      final voteAreaId = voteData['areaId'] as String?;
      final timestamp = voteData['timestamp'] as int? ?? 0;
      return voteAreaId == areaId && timestamp > thirtyMinutesAgoMillis;
    }).toList();

    if (recentVotes.isEmpty) {
      return PowerStatus.unknown;
    }

    final onCount = recentVotes.where((entry) {
      final voteData = entry.value as Map<dynamic, dynamic>;
      return voteData['status'] == 'on';
    }).length;

    final offCount = recentVotes.where((entry) {
      final voteData = entry.value as Map<dynamic, dynamic>;
      return voteData['status'] == 'off';
    }).length;

    return onCount >= offCount ? PowerStatus.on : PowerStatus.off;
  }
}
