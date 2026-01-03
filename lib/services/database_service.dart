import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Seed initial data for a new user in Realtime Database
  Future<void> seedInitialData(String uid, String email, String name) async {
    final String meterId = 'METER001';

    try {
      // 1. User Creation (Profile data)
      await _db.ref('Users/$uid').set({
        'name': name,
        'email': email,
        'role': 'user',
        'createdAt': ServerValue.timestamp,
        'isActive': true,
        'currency': '₹',
        'budgetLimit': 125.00,
      });
    } catch (e) {
      print('Warning: Failed to seed User profile: $e');
    }

    try {
      // 2. Device Registration and Mapping
      await _db.ref('Devices/$meterId').set({
        'uid': uid,
        'address': '123 Maple Avenue, Apt 4B',
        'firmwareVersion': 'v2.1',
        'connectionStatus': 'Strong',
        'lastSync': ServerValue.timestamp,
      });
    } catch (e) {
      print('Warning: Failed to seed Device data: $e');
    }

    try {
      // 3. Publishing Live Data (Initial/Mock)
      await _db.ref('EnergyReadings/$uid/$meterId/live').set({
        'voltage': 230.0,
        'current': 14.2,
        'power': 3.4,
        'energy': 1.2,
        'timestamp': ServerValue.timestamp,
        'deviceId': meterId,
        'status': 'Normal',
        'estimatedBill': 45.20,
      });
    } catch (e) {
      print('Warning: Failed to seed Energy Readings: $e');
    }

    try {
      // 4. Daily Energy Aggregation (Placeholder)
      final String today = DateTime.now().toIso8601String().split('T')[0];
      await _db.ref('DailyConsumption/$uid/$meterId/$today').set({
        'totalEnergy': 5.6,
        'estimatedBill': 45.20,
      });
    } catch (e) {
      print('Warning: Failed to seed Daily Consumption: $e');
    }

    try {
      // 5. Tariff Details (Global - might fail due to permissions)
      await _db.ref('Tariffs').update({
        'baseRate': 0.14,
        'taxRate': 0.05,
      });
    } catch (e) {
      // This is expected to fail if user doesn't have global write access
      print('Note: Could not update global Tariffs (this is usually fine): $e');
    }
  }
}
