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

  // Consultar usuarios activos
  Future<List<User>> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error al consultar usuarios activos: $e');
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

  // Login usuario
  Future<User?> loginUser(String username, String password) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: username)
          .where('password', isEqualTo: password)
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return User.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al hacer login: $e');
      return null;
    }
  }
}
