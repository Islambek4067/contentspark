import 'package:cloud_firestore/cloud_firestore.dart';

class ScriptModel {
  const ScriptModel({
    this.id,
    required this.userId,
    required this.title,
    required this.topic,
    required this.platform,
    required this.hook,
    required this.body,
    required this.cta,
    required this.fullScript,
    required this.hashtags,
    required this.createdAt,
  });

  final String? id;
  final String userId;
  final String title;
  final String topic;
  final String platform;
  final String hook;
  final String body;
  final String cta;
  final String fullScript;
  final String hashtags;
  final DateTime createdAt;

  factory ScriptModel.fromMap(Map<String, dynamic> data, String id) {
    final createdAt = data['createdAt'];
    return ScriptModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled script',
      topic: data['topic'] as String? ?? '',
      platform: data['platform'] as String? ?? 'YouTube',
      hook: data['hook'] as String? ?? '',
      body: data['body'] as String? ?? '',
      cta: data['cta'] as String? ?? '',
      fullScript: data['fullScript'] as String? ?? '',
      hashtags: data['hashtags'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'topic': topic,
      'platform': platform,
      'hook': hook,
      'body': body,
      'cta': cta,
      'fullScript': fullScript,
      'hashtags': hashtags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ScriptModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? topic,
    String? platform,
    String? hook,
    String? body,
    String? cta,
    String? fullScript,
    String? hashtags,
    DateTime? createdAt,
  }) {
    return ScriptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      platform: platform ?? this.platform,
      hook: hook ?? this.hook,
      body: body ?? this.body,
      cta: cta ?? this.cta,
      fullScript: fullScript ?? this.fullScript,
      hashtags: hashtags ?? this.hashtags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
