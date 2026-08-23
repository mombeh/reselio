class Customer {
  final String id;
  final String storeId;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? userEmail;

  Customer({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.userEmail,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      address: json['address'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      userEmail: json['userEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'userEmail': userEmail,
    };
  }
}