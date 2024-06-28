enum ProductStatus { available, soldOut, notForSale }

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;
  final ProductStatus status;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.status,
  });

  // Convierte un objeto Product en un mapa de datos. Útil para enviar datos a una base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'status': status.toString().split('.').last, // Corrección aquí
    };
  }

static Product fromMap(Map<String, dynamic> map, String id) {
  return Product(
    id: id,
    name: map['name'] as String? ?? 'Unknown', // Provide default value if null
    price: (map['price'] as num?)?.toDouble() ?? 0.0, // Provide default value if null
    stock: map['stock'] is int ? map['stock'] : int.tryParse(map['stock'] as String? ?? '0') ?? 0, // Handle possible String to int conversion
    imageUrl: map['imageUrl'] as String? ?? 'assets/images/no_content.png', // Corrected asset path
    status: map['status'] != null
        ? ProductStatus.values.firstWhere(
            (e) => e.toString() == 'ProductStatus.${map['status']}',
            orElse: () => ProductStatus.available,
          )
        : ProductStatus.available, // Provide default value if null
  );
}

  // Copia el objeto Product con nuevos valores. Útil para actualizar solo ciertos campos.
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    ProductStatus? status, // Agregado status como parámetro opcional
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status, // Asegúrate de copiar el estado también
    );
  }
}
