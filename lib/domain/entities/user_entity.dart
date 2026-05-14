import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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

  const UserEntity({
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

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        companyId,
        firstName,
        lastName,
        userEmail,
        token,
        roles,
        isActive,
      ];
}
