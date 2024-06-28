import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivero/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear usuario
  Future<void> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  // Consultar usuarios
  Future<List<User>> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Actualizar usuario
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  // Desactivar usuario
  Future<void> deactivateUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).update({'isActive': false});
    } catch (e) {
      print(e.toString());
    }
  }
}
