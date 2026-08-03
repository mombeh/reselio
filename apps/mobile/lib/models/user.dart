class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? businessName;
  final String? phone;
  final String? address;
  final String? currency;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.businessName,
    this.phone,
    this.address,
    this.currency,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      businessName: json['businessName'],
      phone: json['phone'],
      address: json['address'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'businessName': businessName,
      'phone': phone,
      'address': address,
      'currency': currency,
    };
  }
}
