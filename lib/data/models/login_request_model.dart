class LoginRequestModel {
  final int companyId;
  final String userName;
  final String password;
  final String businessType;
  final bool rememberMe;

  const LoginRequestModel({
    required this.companyId,
    required this.userName,
    required this.password,
    this.businessType = '',
    required this.rememberMe,
  });

  Map<String, dynamic> toJson() => {
        'CompanyId': companyId,
        'UserName': userName,
        'Password': password,
        'BusinessType': businessType,
        'RememberMe': rememberMe,
      };
}
