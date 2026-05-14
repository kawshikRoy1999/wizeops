class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://rmsapi.uvanij.com';
  static const String authenticate = '/users/authenticate';

  /// Base path where uploaded checklist images are stored on the CDN
  static const String uploadImageBasePath =
      'https://assetrmsfiles.uvanij.com/Dev/Company/671DC7AE-18B2-4D0C-A02B-020B80135027/images/';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
