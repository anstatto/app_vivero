import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:vivero/models/Invoice.dart';

class InvoiceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final logger = Logger();

  CollectionReference get _invoicesCol => _db.collection('invoices');

  DocumentReference get _counterRef => _db.collection('counters').doc('invoice');

  InvoiceService();

  Future<String> getNextInvoiceId() async {
    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(_counterRef);
      int year = DateTime.now().year;
      int lastNumber = 1;

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int lastYear = data['year'] as int;

        if (lastYear != year) {
          lastNumber = 1;
        } else {
          lastNumber = (data['lastNumber'] as int) + 1;
        }
      }

      transaction.set(_counterRef, {'year': year, 'lastNumber': lastNumber});
      return '$year${lastNumber.toString().padLeft(6, '0')}';
    });
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      String generatedId = await getNextInvoiceId();
      invoice = invoice.copyWith(id: generatedId, date: Timestamp.now());

      DocumentReference docRef = _invoicesCol.doc();
      await docRef.set(invoice.toMap());
      invoice = invoice.copyWith(firebaseDocId: docRef.id);

      await docRef.update(invoice.toMap());

      logger.d("Invoice added with ID: ${invoice.id}");
    } catch (e) {
      logger.e("Error adding invoice: $e");
      throw Exception("Error adding invoice");
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    try {
      if (invoice.firebaseDocId == null) {
        throw Exception("Document ID is null");
      }
      await _invoicesCol.doc(invoice.firebaseDocId).set(invoice.toMap());
      logger.d("Invoice updated with ID: ${invoice.id}");
    } catch (e) {
      logger.e("Error updating invoice: $e");
      throw Exception("Error updating invoice");
    }
  }

  Future<void> deleteInvoice(String firebaseDocId) async {
    try {
      await _invoicesCol.doc(firebaseDocId).delete();
      logger.d("Invoice deleted with Firestore ID: $firebaseDocId");
    } catch (e) {
      logger.e("Error deleting invoice: $e");
      throw Exception("Error deleting invoice");
    }
  }

  Future<Set<Invoice>> filterInvoicesByDateAndIdAndCustomer(
      String startDate, String endDate, String id, String customerName) async {
    try {
      DateTime startDateTime = DateTime.parse(startDate);
      DateTime endDateTime = DateTime.parse(endDate);

      logger.d("Filter Start Date: $startDateTime, End Date: $endDateTime, ID: $id, Customer Name: $customerName");

      Query query = _invoicesCol
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDateTime))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDateTime));

      if (id.isNotEmpty) {
        query = query.where('id', isEqualTo: id);
      }

      if (customerName.isNotEmpty) {
        query = query.where('customerName', isEqualTo: customerName);
      }

      final QuerySnapshot querySnapshot = await query.get();

      logger.d("Number of invoices found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isEmpty) {
        logger.w("No invoices found.");
      }

      Set<Invoice> invoices = {};
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Invoice invoice = Invoice.fromMap(data, doc.id);
        invoices.add(invoice);
      }
      return invoices;
    } catch (e, s) {
      logger.e("Error filtering invoices: $e", error: e, stackTrace: s);
      throw Exception("Failed to filter invoices due to an error: $e");
    }
  }
}
