class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String photo;

  Customer(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.email,
      required this.photo});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'photo': photo,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      photo: map['photo'],
    );
  }
}
