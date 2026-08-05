class Store {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String phone;
  final String address;
  final String? logo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Store({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.phone,
    required this.address,
    this.logo,
    this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      logo: json['logo'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'phone': phone,
      'address': address,
      'logo': logo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}