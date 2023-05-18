class UserLogData {
  String countryCode;
  String phoneNumber;
  String email;
  String password;

  UserLogData({this.countryCode, this.phoneNumber,this.email, this.password});

  UserLogData.fromJson(Map<String, dynamic> json) {
    countryCode = json['country_code'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_code'] = this.countryCode;
    data['phone_number'] = this.phoneNumber;
    data['password'] = this.password;
    data['email'] = this.email;
    return data;
  }
}
