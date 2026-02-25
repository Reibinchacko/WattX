class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String priority; // high, medium, low
  final DateTime? expiryDate;
  final String authorName;
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    this.expiryDate,
    required this.authorName,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return NoticeModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      priority: map['priority'] ?? 'medium',
      expiryDate: map['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'])
          : null,
      authorName: map['authorName'] ?? 'KSEB Officer',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'priority': priority,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'authorName': authorName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
