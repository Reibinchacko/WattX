import 'package:firebase_database/firebase_database.dart';

class ComplaintModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String status;
  final DateTime timestamp;
  final DateTime lastUpdated;

  ComplaintModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'Open',
    required this.timestamp,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'timestamp': ServerValue.timestamp,
      'lastUpdated': ServerValue.timestamp,
    };
  }

  factory ComplaintModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ComplaintModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      status: map['status'] ?? 'Open',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }
}
