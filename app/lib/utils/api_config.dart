class ApiConfig {
  static const String baseUrl = 'http://192.168.0.21:8001/api';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String register = '/register';
  static const String login = '/login';
  static const String me = '/me';
  static const String logout = '/logout';

  static const String profile = '/profile';
  static const String profilePhotos = '/profile/photos';
  static const String requestEmailCode = '/profile/verify/email/request';
  static const String verifyEmail = '/profile/verify/email';
  static const String verifySelfie = '/profile/verify/selfie';

  static const String matchRequests = '/match-requests';
}
