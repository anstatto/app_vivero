import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivero/models/customer.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _customerCol => _db.collection('Customer');

  Future<List<Customer>> getCustomers() async {
    try {
      final querySnapshot = await _customerCol.get();
      return querySnapshot.docs.map((doc) {
        return Customer.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching customers: $e");
      throw Exception("Failed to fetch customers");
    }
  }

Future<void> addCustomer(Customer customer) async {
  try {
    DocumentReference docRef = await _customerCol.add(customer.toMap());
    String id = docRef.id; // Obtener el ID generado por Firestore
    // Crear una nueva instancia de cliente con el ID generado
    Customer newCustomer = customer.copyWith(id: id);
    // Actualizar el cliente en Firestore con el ID generado
    await _customerCol.doc(id).set(newCustomer.toMap());
  } catch (e) {
    print("Error adding customer: $e");
    throw Exception("Error adding customer");
  }
}


  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customerCol.doc(customer.id).set(customer.toMap());
    } catch (e) {
      print("Error updating customer: $e");
      throw Exception("Error updating customer");
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _customerCol.doc(id).delete();
    } catch (e) {
      print("Error deleting customer: $e");
      throw Exception("Error deleting customer");
    }
  }
}
