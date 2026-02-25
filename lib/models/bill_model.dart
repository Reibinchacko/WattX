class BillModel {
  final String id;
  final double amount;
  final double unitsConsumed;
  final String billingMonth;
  final DateTime dueDate;
  final String status; // paid, unpaid, overdue
  final String? billDownloadUrl;

  BillModel({
    required this.id,
    required this.amount,
    required this.unitsConsumed,
    required this.billingMonth,
    required this.dueDate,
    required this.status,
    this.billDownloadUrl,
  });

  factory BillModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return BillModel(
      id: id,
      amount: (map['amount'] ?? 0.0).toDouble(),
      unitsConsumed: (map['unitsConsumed'] ?? 0.0).toDouble(),
      billingMonth: map['billingMonth'] ?? '',
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : DateTime.now(),
      status: map['status'] ?? 'unpaid',
      billDownloadUrl: map['billDownloadUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'unitsConsumed': unitsConsumed,
      'billingMonth': billingMonth,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status,
      'billDownloadUrl': billDownloadUrl,
    };
  }
}
