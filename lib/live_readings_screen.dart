import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LiveReadingsScreen extends StatelessWidget {
  final String meterId; // pass meter id

  const LiveReadingsScreen({super.key, required this.meterId});

  @override
  Widget build(BuildContext context) {
    // Assuming structure: /EnergyReadings/{uid}/{meterId}/live
    // For now, using a direct reference to the meter's reading node
    final DatabaseReference _readingsRef =
        FirebaseDatabase.instance.ref("EnergyReadings/$meterId");

    return Scaffold(
      appBar: AppBar(title: const Text("Live Energy Monitor")),
      body: StreamBuilder(
        stream: _readingsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
                child: Text("No readings found for this meter."));
          }

          // In RTDB, snapshots can be maps
          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Voltage:  ${data['voltage'] ?? '0'} V",
                    style: const TextStyle(fontSize: 20)),
                Text("Current:  ${data['current'] ?? '0'} A",
                    style: const TextStyle(fontSize: 20)),
                Text("Power:  ${data['power'] ?? '0'} kW",
                    style: const TextStyle(fontSize: 20)),
                Text("Energy:  ${data['energy'] ?? '0'} kWh",
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Text("Device ID: ${data['deviceId'] ?? meterId}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
