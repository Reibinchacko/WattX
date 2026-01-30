import 'dart:async';
import 'dart:math';
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

  Future<void> submitComplaint(ComplaintModel complaint) async {
    final ref = _db.ref('Complaints').push();
    await ref.set(complaint.toMap());
  }

  Stream<List<ComplaintModel>> getAllComplaints() {
    return _db.ref('Complaints').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => ComplaintModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _db.ref('Users').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        return UserModel.fromMap(e.key, e.value as Map<dynamic, dynamic>);
      }).toList();
    }
    return [];
  }

  Future<void> generateMonthlyBill(
      String uid, String meterId, String month) async {
    // 1. Fetch consumption (simulation: random value between 350-550 kWh)
    final Random random = Random();
    final unitsConsumed = 350.0 + random.nextDouble() * 200.0;

    // 2. Simple calculation (rate can be fetched from Tariffs)
    const ratePerUnit = 8.5; // Example rate in ₹
    const fixedCharge = 50.0;
    final amount = (unitsConsumed * ratePerUnit) + fixedCharge;

    final bill = BillModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      unitsConsumed: unitsConsumed,
      billingMonth: month,
      dueDate: DateTime.now().add(const Duration(days: 15)),
      status: 'unpaid',
    );

    await _db.ref('Bills/$uid/${bill.id}').set(bill.toMap());
  }

  Stream<List<ComplaintModel>> getAssignedComplaints(String officerUid) {
    return _db
        .ref('Complaints')
        .orderByChild('assignedOfficerUid')
        .equalTo(officerUid)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => ComplaintModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  Stream<List<ComplaintModel>> getUserComplaints(String uid) {
    return _db
        .ref('Complaints')
        .orderByChild('consumerUid')
        .equalTo(uid)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return data.entries
            .map((e) => ComplaintModel.fromMap(e.key, e.value))
            .toList();
      }
      return [];
    });
  }

  Future<void> updateComplaintStatus(String complaintId, String status,
      {String? response}) async {
    final updates = {
      'status': status,
      'lastUpdated': ServerValue.timestamp,
    };
    if (response != null) updates['response'] = response;
    await _db.ref('Complaints/$complaintId').update(updates);
  }

  Future<void> updateComplaintAssignment(
      String complaintId, String officerUid) async {
    await _db.ref('Complaints/$complaintId').update({
      'assignedOfficerUid': officerUid,
      'status': 'In Progress',
      'lastUpdated': ServerValue.timestamp,
    });
  }

  // --- Initial Data Seeding ---

  Future<void> seedInitialData(String uid, String email, String name) async {
    const String meterId = 'METER001';

    try {
      // 1. User Creation
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

      // 2. Device Registration
      await _db.ref('Devices/$meterId').set({
        'uid': uid,
        'address': '123 Maple Avenue, Apt 4B',
        'firmwareVersion': 'v2.1',
        'status': 'Online',
        'lastSync': ServerValue.timestamp,
      });

      // 3. Initial Live Reading
      await _db.ref('EnergyReadings/live/$meterId').set({
        'voltage': 230.0,
        'current': 14.2,
        'power': 3.4,
        'timestamp': ServerValue.timestamp,
      });

      // 4. Start Simulation
      startReadingSimulation(meterId);

      // 4. Initial Alert
      await _db.ref('Alerts/$uid/initial_alert').set({
        'title': 'Welcome to WattX',
        'message': 'Your smart meter has been successfully connected.',
        'type': 'info',
        'timestamp': ServerValue.timestamp,
        'isRead': false,
      });

      // 5. Initial Bill
      await generateMonthlyBill(uid, meterId, 'JANUARY 2026');
    } catch (e) {
      debugPrint('Error seeding initial data: $e');
    }
  }

  // --- Meter Simulation ---

  void startReadingSimulation(String meterId) {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final random = Random();
      final double voltage = 220.0 + random.nextDouble() * 20.0; // 220V - 240V
      final double current = random.nextDouble() * 15.0; // 0A - 15A
      final double power = (voltage * current) / 1000.0; // kW

      _db.ref('EnergyReadings/live/$meterId').set({
        'voltage': voltage,
        'current': current,
        'power': power,
        'timestamp': ServerValue.timestamp,
      });
    });
  }
}
