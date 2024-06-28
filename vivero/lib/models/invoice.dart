import 'package:vivero/models/InvoiceDetail.dart';

enum InvoiceType { cash, credit }

class Invoice {
  String id;
  DateTime date;
  String customerId;
  String customerName;
  List<InvoiceDetail> details;
  InvoiceType type;
  double total;
  double balance;

  Invoice({
    required this.id,
    required this.date,
    this.customerId = '',
    this.customerName = '',
    required this.details,
    this.type = InvoiceType.cash,
    required this.total,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'details': details.map((detail) => detail.toMap()).toList(),
      'type': type.toString().split('.').last,
      'total': total,
      'balance': balance,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, String id) {
    return Invoice(
      id: map['id'],
      date: DateTime.parse(map['date']),
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      details: List<InvoiceDetail>.from(
          map['details'].map((detailMap) => InvoiceDetail.fromMap(detailMap))),
      type: InvoiceType.values
          .firstWhere((e) => e.toString() == 'InvoiceType.${map['type']}'),
      total: map['total'],
      balance: map['balance'],
    );
  }

  Invoice copyWith({
    String? id,
    DateTime? date,
    String? customerId,
    String? customerName,
    List<InvoiceDetail>? details,
    InvoiceType? type,
    double? total,
    double? balance,
  }) {
    return Invoice(
      id: id ?? this.id,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      details: details ?? this.details,
      type: type ?? this.type,
      total: total ?? this.total,
      balance: balance ?? this.balance,
    );
  }
}
