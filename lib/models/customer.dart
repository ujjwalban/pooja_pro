class Customer {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;

  Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': fullName,
      'phone_number': phoneNumber,
      'email': email,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      fullName: map['name'],
      phoneNumber: map['phone_number'],
      email: map['email'],
    );
  }
}
