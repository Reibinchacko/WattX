class AlertModel {
  final String alertId;
  final String title;
  final String message;
  final String type; // 'critical', 'warning', 'info'
  final DateTime timestamp;
  final bool isRead;

  AlertModel({
    required this.alertId,
    required this.title,
    required this.message,
    this.type = 'info',
    required this.timestamp,
    this.isRead = false,
  });

  factory AlertModel.fromMap(String alertId, Map<dynamic, dynamic> map) {
    return AlertModel(
      alertId: alertId,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }
}
