import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivero/models/InvoiceDetail.dart';

enum InvoiceType { cash, credit }

class Invoice {
  String id;
  Timestamp date;
  String customerId;
  String customerName;
  List<InvoiceDetail> details;
  InvoiceType type;
  double total;
  double balance;
  double paidAmount;  // Nuevo campo para cuánto pagó
  double changeGiven;  // Nuevo campo para cuánto se devolvió
  String? firebaseDocId;

  Invoice({
    required this.id,
    required this.date,
    this.customerId = '',
    this.customerName = '',
    required this.details,
    this.type = InvoiceType.cash,
    required this.total,
    required this.balance,
    this.paidAmount = 0.0,  // Inicializa el nuevo campo
    this.changeGiven = 0.0,  // Inicializa el nuevo campo
    this.firebaseDocId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'customerId': customerId,
      'customerName': customerName,
      'details': details.map((detail) => detail.toMap()).toList(),
      'type': type.toString().split('.').last,
      'total': total,
      'balance': balance,
      'paidAmount': paidAmount,  // Incluye el nuevo campo
      'changeGiven': changeGiven,  // Incluye el nuevo campo
      'firebaseDocId': firebaseDocId,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, String id) {
    return Invoice(
      id: map['id'],
      date: map['date'],
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      details: List<InvoiceDetail>.from(
          map['details'].map((detailMap) => InvoiceDetail.fromMap(detailMap))),
      type: InvoiceType.values
          .firstWhere((e) => e.toString() == 'InvoiceType.${map['type']}'),
      total: map['total'],
      balance: map['balance'],
      paidAmount: map['paidAmount'] ?? 0.0,  // Incluye el nuevo campo
      changeGiven: map['changeGiven'] ?? 0.0,  // Incluye el nuevo campo
      firebaseDocId: id,
    );
  }

  Invoice copyWith({
    String? id,
    Timestamp? date,
    String? customerId,
    String? customerName,
    List<InvoiceDetail>? details,
    InvoiceType? type,
    double? total,
    double? balance,
    double? paidAmount,  // Nuevo campo en copyWith
    double? changeGiven,  // Nuevo campo en copyWith
    String? firebaseDocId,
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
      paidAmount: paidAmount ?? this.paidAmount,  // Copia el nuevo campo
      changeGiven: changeGiven ?? this.changeGiven,  // Copia el nuevo campo
      firebaseDocId: firebaseDocId ?? this.firebaseDocId,
    );
  }
}
