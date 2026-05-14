import '../../domain/entities/user_entity.dart';

class LoginResponseModel {
  final bool status;
  final String message;
  final UserDataModel? data;

  const LoginResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UserDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserDataModel {
  final String id;
  final int companyId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String userEmail;
  final String phone;
  final String token;
  final String roles;
  final String userName;
  final bool isActive;
  final bool isCustomer;
  final String userPhoneCode;
  final String userPhoneCountryCode;
  final String? currencyCode;
  final String? dateFormat;
  final String posToken;
  final String imageFilePath;

  const UserDataModel({
    required this.id,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.userEmail,
    required this.phone,
    required this.token,
    required this.roles,
    required this.userName,
    required this.isActive,
    required this.isCustomer,
    required this.userPhoneCode,
    required this.userPhoneCountryCode,
    this.currencyCode,
    this.dateFormat,
    required this.posToken,
    this.imageFilePath = '',
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] as String? ?? '',
      companyId: json['companyId'] as int? ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      middleName: json['middleName'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      token: json['token'] as String? ?? '',
      roles: json['roles'] is String ? json['roles'] as String : (json['roles']?.toString() ?? ''),
      userName: json['userName'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      isCustomer: json['isCustomer'] as bool? ?? false,
      userPhoneCode: json['userPhoneCode'] as String? ?? '',
      userPhoneCountryCode: json['userPhoneCountryCode'] as String? ?? '',
      currencyCode: json['currencyCode'] as String?,
      dateFormat: json['dateFormat'] as String?,
      posToken: json['posToken'] as String? ?? '',
      imageFilePath: json['imagePath'] as String?
          ?? json['ImageFilePath'] as String?
          ?? json['imageFilePath'] as String?
          ?? '',
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        companyId: companyId,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        userEmail: userEmail,
        phone: phone,
        token: token,
        roles: roles,
        userName: userName,
        isActive: isActive,
        isCustomer: isCustomer,
        userPhoneCode: userPhoneCode,
        userPhoneCountryCode: userPhoneCountryCode,
        currencyCode: currencyCode,
        dateFormat: dateFormat,
        posToken: posToken,
        imageFilePath: imageFilePath,
      );
}
