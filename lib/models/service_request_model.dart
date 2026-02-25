class ServiceRequestModel {
  final String id;
  final String uid;
  final String subject;
  final String description;
  final String type; // Fault, Billing, Installation, Other
  final String status; // Open, InProgress, Resolved
  final DateTime createdAt;

  ServiceRequestModel({
    required this.id,
    required this.uid,
    required this.subject,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRequestModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ServiceRequestModel(
      id: id,
      uid: map['uid'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'Other',
      status: map['status'] ?? 'Open',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'subject': subject,
      'description': description,
      'type': type,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
