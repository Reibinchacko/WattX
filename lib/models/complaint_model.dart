import 'package:firebase_database/firebase_database.dart';

class ComplaintModel {
  final String? id;
  final String consumerUid;
  final String? assignedOfficerUid;
  final String title;
  final String description;
  final String category;
  final String status;
  final String? response;
  final DateTime timestamp;
  final DateTime lastUpdated;

  ComplaintModel({
    this.id,
    required this.consumerUid,
    this.assignedOfficerUid,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'Open',
    this.response,
    required this.timestamp,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'consumerUid': consumerUid,
      'assignedOfficerUid': assignedOfficerUid,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'response': response,
      'timestamp': ServerValue.timestamp,
      'lastUpdated': ServerValue.timestamp,
    };
  }

  factory ComplaintModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ComplaintModel(
      id: id,
      consumerUid: map['consumerUid'] ?? '',
      assignedOfficerUid: map['assignedOfficerUid'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      status: map['status'] ?? 'Open',
      response: map['response'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }
}
