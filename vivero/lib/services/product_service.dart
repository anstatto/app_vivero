import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:vivero/models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  CollectionReference get _productCol => _db.collection('Product');

  // ignore: unused_field
  DocumentSnapshot? _lastVisibleProductSnapshot;

  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _productCol.get();
      return querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error al obtener productos: $e");
      throw Exception("Error al obtener productos");
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      Query query = _productCol.orderBy('name');
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching products: $e");
      throw Exception("Failed to fetch products");
    }
  }

  Future<bool> isProductNameUnique(String name,
      [String? excludingProductId]) async {
    try {
      final snapshot =
          await _productCol.where('name', isEqualTo: name).limit(1).get();
      if (snapshot.docs.isEmpty) {
        return true; // No existe ningún producto con ese nombre, es único
      }

      if (excludingProductId != null &&
          snapshot.docs.any((doc) => doc.id == excludingProductId)) {
        return true;
      }

      return false; // Existe al menos un producto con ese nombre
    } catch (e) {
      print("Error al verificar la unicidad del nombre del producto: $e");
      throw Exception("Error al verificar la unicidad del nombre del producto");
    }
  }

  Future<Product?> getProductByName(String name) async {
    try {
      final docSnapshot = await _productCol.doc(name).get();
      if (docSnapshot.exists) {
        return Product.fromMap(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
      }
      return null;
    } catch (e) {
      print("Error al obtener el producto por nombre: $e");
      throw Exception("Error al obtener el producto por nombre");
    }
  }

  Future<List<Product>> getProductsStartingWith(String prefix) async {
    try {
      final endPrefix = prefix.substring(0, prefix.length - 1) +
          String.fromCharCode(prefix.codeUnitAt(prefix.length - 1) + 1);
      final querySnapshot = await _productCol
          .where('name', isGreaterThanOrEqualTo: prefix)
          .where('name', isLessThan: endPrefix)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error al obtener productos que comienzan con: $prefix, Error: $e");
      throw Exception("Error al obtener productos que comienzan con: $prefix");
    }
  }

  Future<String?> uploadProductImage(File imageFile) async {
    try {
      final filePath =
          'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child(filePath);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error al subir la imagen: $e");
      }
      throw Exception("Error al subir la imagen");
    }
  }

  Future<void> addProduct(Product product, {File? imageFile}) async {
    try {
      if (!await isProductNameUnique(product.name)) {
        throw Exception("El nombre del producto ya existe.");
      }

      String? imageUrl = product.imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadProductImage(imageFile);
        if (imageUrl == null) throw Exception("Error al subir la imagen.");
      }

      final productData = product.toMap();
      productData['imageUrl'] = imageUrl;

      DocumentReference docRef = await _productCol.add(productData);
      String id = docRef.id; // Obtener el ID generado por Firestore
      // Crear una nueva instancia de producto con el ID generado
      Product newProduct = product.copyWith(id: id);
      // Actualizar el producto en Firestore con el ID generado
      await _productCol.doc(id).set(newProduct.toMap());
    } catch (e) {
      print("Error al agregar el producto: $e");
      throw Exception("Error al agregar el producto");
    }
  }

  Future<void> updateProduct(Product product, {File? imageFile}) async {
    try {
      if (!await isProductNameUnique(product.name, product.id)) {
        throw Exception(
            "El nombre del producto ya existe y no puede duplicarse.");
      }

      String? imageUrl = product.imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadProductImage(imageFile);
        if (imageUrl == null) throw Exception("Error al subir la imagen.");
      }

      final productData = product.toMap();
      productData['imageUrl'] = imageUrl;

      await _productCol.doc(product.id).set(productData);
    } catch (e) {
      print("Error al actualizar el producto: $e");
      throw Exception("Error al actualizar el producto");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productCol.doc(id).delete();
    } catch (e) {
      print("Error al eliminar el producto: $e");
      throw Exception("Error al eliminar el producto");
    }
  }

  Future<void> updateProductStatus(
      String productId, ProductStatus newStatus) async {
    try {
      final productRef = _productCol.doc(productId);
      await _db.runTransaction((transaction) async {
        transaction.update(productRef, {'status': newStatus.name});
      });
    } catch (e) {
      print("Error al actualizar el estado del producto: $e");
      throw Exception("Error al actualizar el estado del producto");
    }
  }

  void resetPagination() {
    _lastVisibleProductSnapshot = null;
  }
}
