class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? businessName;
  final String? phone;
  final String? address;
  final String? currency;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.businessName,
    this.phone,
    this.address,
    this.currency,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      businessName: json['businessName'],
      phone: json['phone'],
      address: json['address'],
      currency: json['currency'],
      isActive: json['isActive'] ?? true,
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
