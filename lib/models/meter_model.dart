class MeterModel {
  final String meterId;
  final String ownerUid;
  final String address;
  final String firmwareVersion;
  final String status;
  final DateTime? lastSync;

  MeterModel({
    required this.meterId,
    required this.ownerUid,
    required this.address,
    required this.firmwareVersion,
    this.status = 'Online',
    this.lastSync,
  });

  factory MeterModel.fromMap(String meterId, Map<dynamic, dynamic> map) {
    return MeterModel(
      meterId: meterId,
      ownerUid: map['ownerUid'] ?? '',
      address: map['address'] ?? '',
      firmwareVersion: map['firmwareVersion'] ?? 'v1.0',
      status: map['status'] ?? 'Online',
      lastSync: map['lastSync'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSync'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'address': address,
      'firmwareVersion': firmwareVersion,
      'status': status,
      'lastSync': lastSync?.millisecondsSinceEpoch,
    };
  }
}
