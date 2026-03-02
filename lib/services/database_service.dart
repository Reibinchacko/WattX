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

  // ── Analytics Demo Seed ─────────────────────────────────────────────────────
  // Writes realistic fake IoT readings once, only when Firebase paths are empty.

  Future<void> seedAnalyticsData(String meterId) async {
    final base = 'EnergyReadings/historical/$meterId';

    // Hourly power curve: low at night, peaks at noon & evening
    double kwForHour(int hour) {
      const curve = [
        0.8,
        0.7,
        0.6,
        0.6,
        0.7,
        0.9,
        1.2,
        1.8,
        2.1,
        2.3,
        2.5,
        2.8,
        2.6,
        2.4,
        2.2,
        2.0,
        2.1,
        2.4,
        2.8,
        3.2,
        3.0,
        2.5,
        1.8,
        1.2,
      ];
      final jitter = (hour * 17 % 10) / 100.0 - 0.05;
      return (curve[hour % 24] + jitter).clamp(0.4, 4.0);
    }

    double vFor(int seed) => 228.0 + (seed % 7);
    double aFor(double kw, double v) => (kw * 1000) / v;

    final now = DateTime.now();

    // 1. RECENT — 24 readings (one per hour) for the Day chart
    final recentSnap = await _db.ref('$base/recent').get();
    if (!recentSnap.exists) {
      debugPrint('[Seed] Writing /recent ...');
      final ref = _db.ref('$base/recent');
      for (int h = 23; h >= 0; h--) {
        final ts = now.subtract(Duration(hours: h));
        final kw = kwForHour(ts.hour);
        final v = vFor(ts.hour);
        await ref.push().set({
          'power': kw,
          'voltage': v,
          'current': double.parse(aFor(kw, v).toStringAsFixed(2)),
          'timestamp': ts.millisecondsSinceEpoch,
        });
      }
    }

    // 2. WEEKLY — 7 readings (one per day) for the Week chart
    final weekSnap = await _db.ref('$base/weekly').get();
    if (!weekSnap.exists) {
      debugPrint('[Seed] Writing /weekly ...');
      final ref = _db.ref('$base/weekly');
      const dailyKWh = [32.4, 28.7, 35.1, 30.9, 38.2, 27.5, 33.8];
      for (int d = 6; d >= 0; d--) {
        final ts = now.subtract(Duration(days: d));
        final kw = dailyKWh[6 - d] / 24;
        final v = vFor(d * 3);
        await ref.push().set({
          'power': double.parse(kw.toStringAsFixed(2)),
          'voltage': v,
          'current': double.parse(aFor(kw, v).toStringAsFixed(2)),
          'timestamp':
              DateTime(ts.year, ts.month, ts.day, 12).millisecondsSinceEpoch,
        });
      }
    }

    // 3. MONTHLY — 30 readings (one per day) for the Month chart
    final monthSnap = await _db.ref('$base/monthly').get();
    if (!monthSnap.exists) {
      debugPrint('[Seed] Writing /monthly ...');
      final ref = _db.ref('$base/monthly');
      for (int d = 29; d >= 0; d--) {
        final ts = now.subtract(Duration(days: d));
        final kw =
            (ts.weekday >= 6) ? 1.1 + (d % 5) * 0.08 : 1.4 + (d % 7) * 0.09;
        final v = vFor(d);
        await ref.push().set({
          'power': double.parse(kw.toStringAsFixed(2)),
          'voltage': v,
          'current': double.parse(aFor(kw, v).toStringAsFixed(2)),
          'timestamp':
              DateTime(ts.year, ts.month, ts.day, 12).millisecondsSinceEpoch,
        });
      }
    }

    // 4. YEARLY — 12 readings (one per month) for the Year chart
    final yearSnap = await _db.ref('$base/yearly').get();
    if (!yearSnap.exists) {
      debugPrint('[Seed] Writing /yearly ...');
      final ref = _db.ref('$base/yearly');
      const monthlyKWh = [
        210.0,
        195.0,
        175.0,
        160.0,
        155.0,
        185.0,
        240.0,
        235.0,
        200.0,
        170.0,
        180.0,
        215.0,
      ];
      for (int m = 11; m >= 0; m--) {
        final monthIdx = ((now.month - m - 1) % 12 + 12) % 12;
        final year = now.year - ((now.month - m <= 0) ? 1 : 0);
        final ts = DateTime(year, monthIdx + 1, 15);
        final kw = monthlyKWh[monthIdx] / (24 * 30);
        final v = vFor(m * 7);
        await ref.push().set({
          'power': double.parse(kw.toStringAsFixed(3)),
          'voltage': v,
          'current': double.parse(aFor(kw, v).toStringAsFixed(2)),
          'timestamp': ts.millisecondsSinceEpoch,
        });
      }
    }

    debugPrint('[Seed] Analytics data ready in Firebase.');
  }
}
