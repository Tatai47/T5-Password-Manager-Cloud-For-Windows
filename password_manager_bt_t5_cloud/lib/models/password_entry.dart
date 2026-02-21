class PasswordEntry {
  String id;
  String siteName;
  String siteAddress;
  String email;
  String number;
  String nickName;
  String password;
  bool isOtpEnabled;
  String additionalDetails;

  PasswordEntry({
    required this.id,
    required this.siteName,
    required this.siteAddress,
    required this.email,
    required this.number,
    required this.nickName,
    required this.password,
    this.isOtpEnabled = false,
    this.additionalDetails = '',
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'siteName': siteName,
      'siteAddress': siteAddress,
      'email': email,
      'number': number,
      'nickName': nickName,
      'password': password,
      'isOtpEnabled': isOtpEnabled,
      'additionalDetails': additionalDetails,
    };
  }

  // Create from Firebase Map
  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] ?? '',
      siteName: map['siteName'] ?? '',
      siteAddress: map['siteAddress'] ?? '',
      email: map['email'] ?? '',
      number: map['number'] ?? '',
      nickName: map['nickName'] ?? '',
      password: map['password'] ?? '',
      isOtpEnabled: map['isOtpEnabled'] ?? false,
      additionalDetails: map['additionalDetails'] ?? '',
    );
  }
}
