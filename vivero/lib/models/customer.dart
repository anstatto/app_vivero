class Customer {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final double creditLimit; // Límite de crédito del cliente

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.creditLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'creditLimit': creditLimit,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      creditLimit: map['creditLimit'] ?? 0.0,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    double? creditLimit,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }
}
