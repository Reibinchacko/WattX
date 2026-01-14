class PaymentModel {
  final String id;
  final double amount;
  final String paymentMethod;
  final String billId;
  final DateTime timestamp;
  final String status; // success, failed, pending
  final String receiptNumber;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.billId,
    required this.timestamp,
    required this.status,
    required this.receiptNumber,
  });

  factory PaymentModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return PaymentModel(
      id: id,
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      billId: map['billId'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      receiptNumber: map['receiptNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'paymentMethod': paymentMethod,
      'billId': billId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'receiptNumber': receiptNumber,
    };
  }
}
