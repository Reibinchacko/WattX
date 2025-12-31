import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Seed initial data for a new user in Realtime Database
  Future<void> seedInitialData(String uid, String email, String name) async {
    final String meterId = 'METER001';

    // 1. User Creation (Profile data)
    // Path: /Users/{uid}
    await _db.ref('Users/$uid').set({
      'name': name,
      'email': email,
      'role': 'user',
      'createdAt': ServerValue.timestamp,
      'isActive': true,
      'currency': '₹',
      'budgetLimit': 125.00,
    });

    // 2. Device Registration and Mapping
    // Path: /Devices/{deviceId}
    await _db.ref('Devices/$meterId').set({
      'uid': uid,
      'address': '123 Maple Avenue, Apt 4B',
      'firmwareVersion': 'v2.1',
      'connectionStatus': 'Strong',
      'lastSync': ServerValue.timestamp,
    });

    // 3. Publishing Live Data (Initial/Mock)
    // Path: /EnergyReadings/{uid}/{meterId}
    await _db.ref('EnergyReadings/$uid/$meterId/live').set({
      'voltage': 230.0,
      'current': 14.2,
      'power': 3.4,
      'energy': 1.2,
      'timestamp': ServerValue.timestamp,
      'deviceId': meterId,
    });

    // 4. Daily Energy Aggregation (Placeholder)
    // Path: /DailyConsumption/{uid}/{meterId}/{date}
    final String today = DateTime.now().toIso8601String().split('T')[0];
    await _db.ref('DailyConsumption/$uid/$meterId/$today').set({
      'totalEnergy': 5.6,
      'estimatedBill': 0.78,
    });

    // 5. Tariff Details
    // Path: /Tariffs
    await _db.ref('Tariffs').update({
      'baseRate': 0.14,
      'taxRate': 0.05,
    });
  }
}
