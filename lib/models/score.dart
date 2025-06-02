import 'package:cloud_firestore/cloud_firestore.dart';

class Score {
  final String id;
  final String userId;
  final String userName;
  final String subjectId;
  final String subjectName;
  final String activityId;
  final String activityType; // 'game', 'note', 'video'
  final String activityName;
  final int points;
  final DateTime timestamp;
  final int ageGroup;

  Score({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subjectId,
    required this.subjectName,
    required this.activityId,
    required this.activityType,
    required this.activityName,
    required this.points,
    required this.timestamp,
    required this.ageGroup,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'activityId': activityId,
        'activityType': activityType,
        'activityName': activityName,
        'points': points,
        'timestamp': Timestamp.fromDate(timestamp),
        'ageGroup': ageGroup,
      };

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      activityId: json['activityId'] as String,
      activityType: json['activityType'] as String,
      activityName: json['activityName'] as String,
      points: json['points'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      ageGroup: json['ageGroup'] as int,
    );
  }

  factory Score.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Score.fromJson({
      'id': doc.id,
      ...data,
    });
  }
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final int totalPoints;
  final int rank;
  final int ageGroup;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.totalPoints,
    required this.rank,
    required this.ageGroup,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      totalPoints: json['totalPoints'] as int,
      rank: json['rank'] as int,
      ageGroup: json['ageGroup'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'totalPoints': totalPoints,
        'rank': rank,
        'ageGroup': ageGroup,
      };
}
