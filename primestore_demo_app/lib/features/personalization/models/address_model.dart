class AddressModel {
  final int id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.fullName,
    required this.phone, 
    required this.addressLine1, 
    required this.addressLine2, 
    required this.city, 
    required this.state, 
    required this.postalCode, 
    required this.country, 
    required this.id, 
    required this.isDefault, 
    required this.createdAt,
   
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      fullName: json['full_name'], 
      phone: json['phone'], 
      addressLine1: json['address_line_1'],
       addressLine2: json['address_line_2'] ?? '', 
       city: json['city'], 
       state: json['state'],
        postalCode: json['postal_code'], 
        country: json['country'], 
        isDefault: json['is_default'], 
        createdAt: DateTime.parse(json['created_at']),
    );
  }
}
