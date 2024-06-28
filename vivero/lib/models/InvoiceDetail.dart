// ignore_for_file: file_names

class InvoiceDetail {
  final String productId;
  final String name;
  final String imageUrl;
  int quantity;
  final double price;

  InvoiceDetail({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
    };
  }

  factory InvoiceDetail.fromMap(Map<String, dynamic> map) {
    return InvoiceDetail(
      productId: map['productId'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
