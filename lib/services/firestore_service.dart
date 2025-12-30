import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Seed initial data for a new user
  Future<void> seedInitialData(String uid, String email, String name) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final meterId = 'SN-849201-XJ'; // Standard mock meter ID

    // 1. Update User Document with extra fields from design
    await userDoc.set({
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'currency': '₹',
      'budgetLimit': 125.00,
    }, SetOptions(merge: true));

    // 2. Create Meter
    final meterDoc = _firestore.collection('meters').doc(meterId);
    await meterDoc.set({
      'userId': uid,
      'address': '123 Maple Avenue, Apt 4B',
      'firmwareVersion': 'v2.1',
      'connectionStatus': 'Strong',
      'lastSync': FieldValue.serverTimestamp(),
    });

    // 3. Seed Readings (Small set for current dashboard metrics)
    final readingsCol = meterDoc.collection('readings');
    await readingsCol.add({
      'voltage': 230.0,
      'current': 14.2,
      'powerFactor': 0.95,
      'activePower': 3.4,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 4. Seed Bills
    final billsCol = userDoc.collection('bills');

    // Current Pending Bill
    await billsCol.add({
      'periodStart': '2025-10-01',
      'periodEnd': '2025-10-31',
      'dueDate': '2025-11-05',
      'totalAmount': 84.50,
      'projectedAmount': 110.00,
      'status': 'Pending',
      'breakdown': [
        {
          'category': 'Usage Charges',
          'amount': 57.68,
          'desc': '412 kWh × ₹0.14'
        },
        {
          'category': 'Service Fee',
          'amount': 15.00,
          'desc': 'Fixed daily rate'
        },
        {
          'category': 'Taxes & Levies',
          'amount': 11.82,
          'desc': 'State & Local'
        },
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Billing History (Paid bills)
    await billsCol.add({
      'periodStart': '2025-09-01',
      'periodEnd': '2025-09-30',
      'totalAmount': 92.40,
      'status': 'Paid',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 5. Seed Recommendations
    final recommendationsCol = userDoc.collection('recommendations');
    await recommendationsCol.add({
      'title': 'Phantom Power',
      'description': 'Unplug unused devices to save on standby energy.',
      'impact_text': '+₹12/mo',
      'icon_key': 'savings_outlined',
      'color_theme': 'green',
      'isActive': true,
    });

    await recommendationsCol.add({
      'title': 'AC Schedule',
      'description': 'Optimizing your thermostat can cut costs significantly.',
      'impact_text': 'High Impact',
      'icon_key': 'lightbulb_outline',
      'color_theme': 'yellow',
      'isActive': true,
    });
  }
}
