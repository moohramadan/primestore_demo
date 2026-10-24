class SellerProfile {
  const SellerProfile({required this.businessName, required this.accountType});

  final String businessName;
  final String accountType;

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    final businessName = json['business_name'];
    final accountType = json['account_type'];
    if (businessName is! String || accountType is! String) {
      throw const FormatException('The seller profile response is invalid.');
    }

    return SellerProfile(businessName: businessName, accountType: accountType);
  }

  String get formattedAccountType => switch (accountType) {
    'individual' => 'Individual',
    'private_business' => 'Private business',
    'public_business' => 'Public business',
    'non_profit' => 'Non-profit',
    _ => accountType,
  };
}
