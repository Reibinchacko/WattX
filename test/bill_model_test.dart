import 'package:flutter_test/flutter_test.dart';
import 'package:wattx/models/bill_model.dart';

void main() {
  group('BillModel.fromMap', () {
    test('parses complete bill data correctly', () {
      final bill = BillModel.fromMap('bill-1', {
        'amount': 842.50,
        'unitsConsumed': 129.6,
        'billingMonth': 'March 2026',
        'dueDate': 1741180320000,
        'status': 'paid',
        'billDownloadUrl': 'https://example.com/bill.pdf',
      });

      expect(bill.id, 'bill-1');
      expect(bill.amount, 842.50);
      expect(bill.unitsConsumed, 129.6);
      expect(bill.billingMonth, 'March 2026');
      expect(bill.status, 'paid');
      expect(bill.billDownloadUrl, 'https://example.com/bill.pdf');
      expect(
        bill.dueDate,
        DateTime.fromMillisecondsSinceEpoch(1741180320000),
      );
    });

    test('uses safe defaults for missing values', () {
      final bill = BillModel.fromMap('bill-2', {});

      expect(bill.amount, 0.0);
      expect(bill.unitsConsumed, 0.0);
      expect(bill.billingMonth, '');
      expect(bill.status, 'unpaid');
      expect(bill.billDownloadUrl, isNull);
    });
  });

  test('BillModel.toMap serializes bill fields', () {
    final bill = BillModel(
      id: 'bill-3',
      amount: 500.0,
      unitsConsumed: 75.0,
      billingMonth: 'April 2026',
      dueDate: DateTime.fromMillisecondsSinceEpoch(1741180320000),
      status: 'overdue',
    );

    expect(bill.toMap(), {
      'amount': 500.0,
      'unitsConsumed': 75.0,
      'billingMonth': 'April 2026',
      'dueDate': 1741180320000,
      'status': 'overdue',
      'billDownloadUrl': null,
    });
  });
}