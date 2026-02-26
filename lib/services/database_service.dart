import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/meter_model.dart';
import '../models/reading_model.dart';
import '../models/alert_model.dart';
import '../models/bill_model.dart';
import '../models/payment_model.dart';
import '../models/tariff_model.dart';
import '../models/service_request_model.dart';
import '../models/notice_model.dart';
import '../models/complaint_model.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // --- User Profile Management ---

  Stream<UserModel?> getUserProfile(String uid) {
    return _db.ref('Users/$uid').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return UserModel.fromMap(uid, data);
      }
      return null;
    });
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _db.ref('Users/${user.uid}').update(user.toMap());
  }

  // --- Meter/Device Management ---

  Stream<MeterModel?> getMeterDetails(String meterId) {
    return _db.ref('Devices/$meterId').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return MeterModel.fromMap(meterId, data);
      }
      return null;
    });
  }

  // --- Energy Readings ---

  Stream<ReadingModel?> getLiveReading(String meterId) {
    return _db.ref('EnergyReadings/live/$meterId').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return ReadingModel.fromMap(data);
      }
      return null;
    });
  }

  // NEW: Real-time trend stream for Energy Report and Analytics
  Stream<List<ReadingModel>> getEnergyTrends(String meterId) {
    return _db
        .ref('EnergyReadings/historical/$meterId/recent')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.values
          .map((v) => ReadingModel.fromMap(v as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  Future<List<ReadingModel>> getHistoricalReadings(
      String meterId, String period) async {
    final snapshot =
        await _db.ref('EnergyReadings/historical/$meterId/$period').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => ReadingModel.fromMap(v as Map<dynamic, dynamic>))
          .toList();
    }
    return [];
  }

  // --- Alerts & Notifications ---

  Stream<List<AlertModel>> getAlerts(String uid) {
    return _db.ref('Alerts/$uid').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => AlertModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  Future<void> markAlertAsRead(String uid, String alertId) async {
    await _db.ref('Alerts/$uid/$alertId').update({'isRead': true});
  }

  // --- Officer - Consumer Relationships ---

  Stream<List<UserModel>> getAssignedConsumers(String officerUid) {
    return _db
        .ref('OfficerAssignments/$officerUid')
        .onValue
        .asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      List<UserModel> consumers = [];
      for (var consumerUid in data.keys) {
        final userSnap = await _db.ref('Users/$consumerUid').get();
        if (userSnap.exists) {
          consumers.add(UserModel.fromMap(
              consumerUid, userSnap.value as Map<dynamic, dynamic>));
        }
      }
      return consumers;
    });
  }

  // --- Bills ---

  Stream<List<BillModel>> getBills(String uid) {
    return _db.ref('Bills/$uid').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => BillModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  // --- Payments ---

  Stream<List<PaymentModel>> getPayments(String uid) {
    return _db.ref('Payments/$uid').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => PaymentModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  // --- Tariffs ---

  Stream<List<TariffModel>> getTariffs() {
    return _db.ref('Tariffs').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => TariffModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  // --- Service Requests ---

  Stream<List<ServiceRequestModel>> getServiceRequests(String uid) {
    return _db.ref('ServiceRequests/$uid').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => ServiceRequestModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  // --- System Notices ---

  Stream<List<NoticeModel>> getSystemNotices() {
    return _db.ref('SystemNotices').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => NoticeModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  // --- Complaints ---

  Future<void> submitComplaint(String uid, ComplaintModel complaint) async {
    final ref = _db.ref('Complaints/$uid').push();
    await ref.set(complaint.toMap());
  }

  // --- Initial Data Seeding ---

  Future<void> seedInitialData(String uid, String email, String name) async {
    const String meterId = 'METER001';

    try {
      await _db.ref('Users/$uid').set({
        'name': name,
        'email': email,
        'role': 'user',
        'createdAt': ServerValue.timestamp,
        'isActive': true,
        'currency': '₹',
        'budgetLimit': 125.00,
        'profileImageUrl':
            'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(name)}',
      });

      await _db.ref('Devices/$meterId').set({
        'uid': uid,
        'address': '123 Maple Avenue, Apt 4B',
        'firmwareVersion': 'v2.1',
        'status': 'Online',
        'lastSync': ServerValue.timestamp,
      });

      await _db.ref('EnergyReadings/live/$meterId').set({
        'voltage': 230.0,
        'current': 14.2,
        'power': 3.4,
        'timestamp': ServerValue.timestamp,
      });

      await _db.ref('Alerts/$uid/initial_alert').set({
        'title': 'Welcome to WattX',
        'message': 'Your smart meter has been successfully connected.',
        'type': 'info',
        'timestamp': ServerValue.timestamp,
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Error seeding initial data: $e');
    }
  }
}
